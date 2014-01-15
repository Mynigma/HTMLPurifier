//
//  HTMLPurifier_Strategy_MakeWellFormed.m
//  HTMLPurifier
//
//  Created by Roman Priebe on 13.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_Strategy_MakeWellFormed.h"
#import "HTMLPurifier_Context.h"
#import "HTMLPurifier_Config.h"
#import "HTMLPurifier_HTMLDefinition.h"
#import "BasicPHP.h"
#import "HTMLPurifier_Injector.h"
#import "HTMLPurifier_Token_Empty.h"
#import "HTMLPurifier_Token_Start.h"
#import "HTMLPurifier_Token_End.h"
#import "HTMLPurifier_Token_Text.h"
#import "HTMLPurifier_Zipper.h"
#import "HTMLPurifier_Generator.h"
#import "HTMLPurifier_ElementDef.h"
#import "HTMLPurifier_ChildDef.h"


@implementation HTMLPurifier_Strategy_MakeWellFormed

- (NSMutableArray*)execute:(NSMutableArray*)tokens config:(HTMLPurifier_Config *)config context:(HTMLPurifier_Context *)context
{
    HTMLPurifier_HTMLDefinition* definition = [config getHTMLDefinition];

    // local variables
    HTMLPurifier_Generator* generator = [[HTMLPurifier_Generator alloc] initWithConfig:config context:context];
    BOOL escape_invalid_tags = [(NSNumber*)[config get:@"Core.EscapeInvalidTags"] boolValue];
    // used for autoclose early abortion
    NSArray* global_parent_allowed_elements = [[[definition info_parent_def] child] getAllowedElements:config];
    //$e = $context->get('ErrorCollector', true);
    NSInteger i = -1; // injector index

    NSArray* pair = [HTMLPurifier_Zipper fromArray:tokens];

    if(pair.count<2)
        return [@[] mutableCopy];

    HTMLPurifier_Zipper* zipper = (HTMLPurifier_Zipper*)pair[0];
    HTMLPurifier_Token* token = (HTMLPurifier_Token*)pair[1];

    BOOL reprocess = NO; // whether or not to reprocess the same token
    NSMutableArray* stack = [NSMutableArray new];

    // member variables
    _stack = stack;
    _tokens = tokens;
    _token = token;
    _zipper = zipper;
    _config = config;
    _context = context;

    // context variables
    [context registerWithName:@"CurrentNesting" ref:stack];
    [context registerWithName:@"InputZipper" ref:zipper];
    [context registerWithName:@"CurrentToken" ref:token];

    // -- begin INJECTOR --

    NSMutableDictionary* injectors = [[config getBatch:@"AutoFormat"] mutableCopy];
    NSMutableArray* def_injectors = [definition info_injector];
    NSMutableDictionary* custom_injectors = injectors[@"Custom"];
    [injectors removeObjectForKey:@"Custom"];
    for(NSString* injectorName in injectors)
    {
        // XXX: Fix with a legitimate lookup table of enabled filters
        if (strpos(injectorName, @".") != NSNotFound) {
            continue;
        }
        NSString* newInjectorName = [NSString stringWithFormat:@"HTMLPurifier_Injector_%@", injectorName];
        if (!injectors[injectorName]) {
            continue;
        }
        [_injectors addObject:[NSClassFromString(newInjectorName) new]];
    }

    for(HTMLPurifier_Injector* injector in def_injectors)
    {
        // assumed to be objects
        [_injectors addObject:injector];
    }
    for(HTMLPurifier_Injector* injector in custom_injectors)
    {
        HTMLPurifier_Injector* newInjector = injector;
        if ([injector isKindOfClass:[NSString class]])
        {
            NSString* newInjectorName = [NSString stringWithFormat:@"HTMLPurifier_Injector_%@", injector];
            newInjector = [NSClassFromString(newInjectorName) new];
        }
        [_injectors addObject:injector];
    }

    // give the injectors references to the definition and context
    // variables for performance reasons
    NSMutableArray* injectorsToBeRemoved = [NSMutableArray new];
    for(HTMLPurifier_Injector* injector in _injectors)
    {
        NSString* string = [injector prepare:config context:context];
        if (!string)
        {
            continue;
        }
        [injectorsToBeRemoved addObject:injector];
        TRIGGER_ERROR(@"Cannot enable {%@} injector because %@ is not allowed", [injector name], string);
    }
    [_injectors removeObjectsInArray:injectorsToBeRemoved];

    // -- end INJECTOR --

    // a note on reprocessing:
    //      In order to reduce code duplication, whenever some code needs
    //      to make HTML changes in order to make things "correct", the
    //      new HTML gets sent through the purifier, regardless of its
    //      status. This means that if we add a start token, because it
    //      was totally necessary, we don't have to update nesting; we just
    //      punt ($reprocess = true; continue;) and it does that for us.

    BOOL firstTimeLoop = YES;
    // isset is in loop because $tokens size changes during loop exec
    for (;;
         // only increment if we don't need to reprocess
)
    {
        if(!firstTimeLoop)
        {
            if(reprocess)
                reprocess = NO;
            else
                token = (HTMLPurifier_Token*)[_zipper next:token];
        }
        else
            firstTimeLoop = NO;

        // check for a rewind
        if (i>=0) {
            // possibility: disable rewinding if the current token has a
            // rewind set on it already. This would offer protection from
            // infinite loop, but might hinder some advanced rewinding.
            NSInteger rewind_offset = [_injectors[i] getRewindOffset];
            if (rewind_offset>=0) {
                for (NSInteger j = 0; j < rewind_offset; j++) {
                    if (![zipper front]) break;
                    token = (HTMLPurifier_Token*)[_zipper prev:token];
                    // indicate that other injectors should not process this token,
                    // but we need to reprocess it
                    [(NSMutableArray*)[token skip] removeObjectAtIndex:i];
                    [token setRewind:@(i)];
                    if ([token isKindOfClass:[HTMLPurifier_Token_Start class]])
                    {
                        array_pop(_stack);
                    } else if ([token isKindOfClass:[HTMLPurifier_Token_End class]])
                    {
                        [_stack addObject:[(HTMLPurifier_Token_End*)token start]];
                    }
                }
            }
            i = -1;
        }

        // handle case of document end
        if (!token) {
            // kill processing if stack is empty
            if (!_stack) {
                break;
            }

            // peek
            HTMLPurifier_Token* top_nesting = (HTMLPurifier_Token*)array_pop(_stack);
            [_stack addObject:top_nesting];

            /*
             // send error [TagClosedSuppress]
             if ($e && !isset($top_nesting->armor['MakeWellFormed_TagClosedError'])) {
             $e->send(E_NOTICE, 'Strategy_MakeWellFormed: Tag closed by document end', $top_nesting);
             }*/

            // append, don't splice, since this is the end
            token = [[HTMLPurifier_Token_End alloc] initWithName:[top_nesting valueForKey:@"name"]];

            // punt!
            reprocess = YES;
            continue;
        }

        //echo '<br>'; printZipper($zipper, $token);//printTokens($this->stack);
        //flush();

        // quick-check: if it's not a tag, no need to process
        if (![token is_tag])
        {
            if ([token isKindOfClass:[HTMLPurifier_Token_Text class]])
            {
                for(NSInteger i=0; i<injectors.count; i++)
                {
                    if([token skip][i])
                    {
                        continue;
                    }
                    if ([token rewind] && ![[token rewind] isEqual:@(i)])
                    {
                        continue;
                    }
                    // XXX fuckup
                    HTMLPurifier_Token* r = token;
                    [injector handleText:r];
                    token = [self processToken:r i];
                    reprocess = YES;
                    break;
                }
            }
            // another possibility is a comment
            continue;
        }
        NSString* type;
        if (definition.info[token.name])) {
            type = [[definition.info[token.name] child] type];
        } else {
            type = nil; // Type is unknown, treat accordingly
        }

        // quick tag checks: anything that's *not* an end tag
        BOOL ok = NO;
        if ([type isEqual:@"empty"] && [token isKindOfClass:[HTMLPurifier_Token_Start class]]) {
            // claims to be a start tag but is empty
            token = [[HTMLPurifier_Token_Empty alloc] initWithName:token.name attr:token.attr line:token.line col:token.col armor:token.armor];
            ok = YES;
        } else if (type && ![type isEqualToString:@"empty"] && [token isKindOfClass: [HTMLPurifier_Token_Empty class]])
        {
            // claims to be empty but really is a start tag
            // NB: this assignment is required
            HTMLPurifier_Token* old_token = token;
            token = [[HTMLPurifier_Token_End alloc] initWithName:token.name];

            token = [self insertBefore:[[HTMLPurifier_Token_Start alloc initWithName:token.name attr:token.attr line:token.line col:token.col armor:token.armor]]];

            // punt (since we had to modify the input stream in a non-trivial way)
            reprocess = YES;
            continue;
        } else if ([token isKindOfClass:[HTMLPurifier_Token_Empty class]]) {
            // real empty token
            ok = YES;
        } else if ([token isKindOfClass:[HTMLPurifier_Token_Start class]]) {
            // start tag

            // ...unless they also have to close their parent
            if (_stack.count>0) {

                // Performance note: you might think that it's rather
                // inefficient, recalculating the autoclose information
                // for every tag that a token closes (since when we
                // do an autoclose, we push a new token into the
                // stream and then /process/ that, before
                // re-processing this token.)  But this is
                // necessary, because an injector can make an
                // arbitrary transformations to the autoclosing
                // tokens we introduce, so things may have changed
                // in the meantime.  Also, doing the inefficient thing is
                // "easy" to reason about (for certain perverse definitions
                // of "easy")

                parent = array_pop(_stack);
                [_stack addObject:parent];

                parent_def = nil;
                parent_elements = nil;
                autoclose = NO;
                if (definition.info[parent.name])) {
                    parent_def = definition.info[parent.name];
                    parent_elements = [[parent_def child] getAllowedElements:config];
                    autoclose = parent_elements[token.name]==nil;
                }

                if (autoclose && [definition.info[token.name] wrap]) {
                    // Check if an element can be wrapped by another
                    // element to make it valid in a context (for
                    // example, <ul><ul> needs a <li> in between)
                    wrapname = [definition.info[token.name] wrap];
                    wrapdef = [definition.info[wrapname] wrap];
                    elements = [[wrapdef child] getAllowedElements:config];
                    if (elements[token.name]) && parent_elements[wrapname])) {
                        newtoken = [[HTMLPurifier_Token_Start alloc] initWith:wrapname];
                        token = [self insertBefore:newtoken];
                        reprocess = YES;
                        continue;
                    }
                }

                carryover = NO;
                if (autoclose && [parent_def formatting]) {
                    carryover = NO;
                }

                if (autoclose) {
                    // check if this autoclose is doomed to fail
                    // (this rechecks $parent, which his harmless)
                    BOOL autoclose_ok = global_parent_allowed_elements[token.name]!= nil;
                    if (!autoclose_ok) {
                        for(NSObject* ancestor in _stack)
                        {
                            elements = [[definition.info[ancestor.name] child]getAllowedElements:config];
                            if (elements[token.name]) {
                                autoclose_ok = YES;
                                break;
                            }
                            if ([definition.info[token.name] wrap]) {
                                wrapname = [definition.info[token.name] wrap];
                                wrapdef = definition.info[wrapname];
                                wrap_elements = [[wrapdef child] getAllowedElements:config];
                                if (wrap_elements[token.name]) && elements[wrapname])) {
                                    autoclose_ok = YES;
                                    break;
                                }
                            }
                        }
                    }
                    if (autoclose_ok) {
                        // errors need to be updated
                        new_token = [[HTMLPurifier_Token_End alloc] initWithName:parent.name];
                        [new_token setStart:parent];

                        /*
                         // [TagClosedSuppress]
                         if ($e && !isset($parent->armor['MakeWellFormed_TagClosedError'])) {
                         if (!$carryover) {
                         $e->send(E_NOTICE, 'Strategy_MakeWellFormed: Tag auto closed', $parent);
                         } else {
                         $e->send(E_NOTICE, 'Strategy_MakeWellFormed: Tag carryover', $parent);
                         }
                         }
                         */
                        if (carryover) {
                            element = [parent copy];
                            // [TagClosedAuto]
                            //$element->armor['MakeWellFormed_TagClosedError'] = true;
                            [element setCarryover:YES];
                            token = [self processToken:@[new_token, token, element]];
                        } else {
                            token = [self insertBefore:new_token];
                        }
                    } else {
                        token = [self remove];
                    }
                    reprocess = YES;
                    continue;
                }

            }
            ok = YES;
        }

        if(ok)
        {
            for(NSInteger i=0; i<self.injectors.count; i++)
            {
                if ([token skip][i])) {
                    continue;
                }
                if ([token rewind] && ![[token rewind] isEqual:@(i)]) {
                    continue;
                }
                HTMLPurifier_Token* r = token;
                [injector handleElement:r];
                token = [self processToken:r i];
                reprocess = YES;
                break;
            }
            if (!reprocess) {
                // ah, nothing interesting happened; do normal processing
                if ([token isKindOfClass:[HTMLPurifier_Token_Start class]]) {
                    [_stack addObject:token];
                } else if ([token isKindOfClass:[HTMLPurifier_Token_End class]]) {
                    throw [NSException exceptionWithName:@"End tag handling exception" reason:@"Improper handling of end tag in start code; possible error in MakeWellFormed" userInfo:nil];
                }
            }
            continue;
        }

        // sanity check: we should be dealing with a closing tag
        if (![token isKindOfClass:[HTMLPurifier_Token_End class]]) {
            throw [NSException exceptionWithName:@"Unaccounted for tag exception" reason:@"Unaccounted for tag token in input stream, bug in HTML Purifier" userInfo:nil];
        }

        // make sure that we have something open
        if (_stack.count==0) {
            if (escape_invalid_tags)
            {
                token = [[HTMLPurifier_Token_Text alloc] initWithData:[generator generateFromToken:token]];
            } else {
                token = [self remove];
            }
            reprocess = YES;
            continue;
        }

        // first, check for the simplest case: everything closes neatly.
        // Eventually, everything passes through here; if there are problems
        // we modify the input stream accordingly and then punt, so that
        // the tokens get processed again.
        current_parent = array_pop(_stack);
        if ([[current_parent name] isEqual:[token name]])
        {
            [token setStart:current_parent];
            for(NSInteger i=0; i<_injectors.count; i++)
            {
                if ([token skip][i]))
                {
                    continue;
                }
                if ([token rewind] && ![[token rewind] isEqual:@(i)])
                {
                    continue;
                }
                HTMLPurifier_Token* r = token;
                [injector handleEnd:r];
                token = [self processToken:r, $i];
                [_stack addObject:current_parent];
                reprocess = YES;
                break;
            }
            continue;
        }

        // okay, so we're trying to close the wrong tag

        // undo the pop previous pop
        [_stack addObject:current_parent];

        // scroll back the entire nest, trying to find our tag.
        // (feature could be to specify how far you'd like to go)
        NSInteger size = _stack.count;
        // -2 because -1 is the last element, but we already checked that
        NSMutableArray* skipped_tags = nil;
        for (NSInteger j = size - 2; j >= 0; j--) {
            if ([[_stack[j] name] isEqual:[token name]])
            {
                skipped_tags = array_slice(_stack, j);
                break;
            }
        }

        // we didn't find the tag, so remove
        if (skipped_tags == NO) {
            if (escape_invalid_tags) {
                token = [[HTMLPurifier_Token_Text alloc] initWith:[generator generateFromToken:token]];
            } else {
                if ($e) {
                    $e->send(E_WARNING, 'Strategy_MakeWellFormed: Stray end tag removed');
                }
                token = [self remove];
            }
            reprocess = YES;
            continue;
        }

        /*
         // do errors, in REVERSE $j order: a,b,c with </a></b></c>
         NSInteger c = skipped_tags.count;
         if ($e) {
         for ($j = $c - 1; $j > 0; $j--) {
         // notice we exclude $j == 0, i.e. the current ending tag, from
         // the errors... [TagClosedSuppress]
         if (!isset($skipped_tags[$j]->armor['MakeWellFormed_TagClosedError'])) {
         $e->send(E_NOTICE, 'Strategy_MakeWellFormed: Tag closed by element end', $skipped_tags[$j]);
         }
         }
         }*/

        // insert tags, in FORWARD $j order: c,b,a with </a></b></c>
        NSMutableArray* replace = @[token];
        for (NSInteger j = 1; j < c; j++)
        {
            // ...as well as from the insertions
            new_token = [[HTMLPurifier_Token_End alloc] initWith:[skipped_tags[j] name]];
            [new_token setStart:skipped_tags[j]];
            array_unshift(replace, new_token);
            if(definition.info[new_token.name] && [definition.info[new_token.name] formatting])
            {
                // [TagClosedAuto]
                element = [skipped_tags[j] copy];
                [element setCarryover:YES];
                [element.armor setObject:@YES forKey:@"MakeWellFormed_TagClosedError"];
                [replace addObject:element];
            }
        }
        token = [self processToken:replace];
        reprocess = YES;
        continue;
    }

    [context destroy:@"CurrentToken"];
    [context destroy:@"CurrentNesting"];
    [context destroy:@"InputZipper"];

    [self setInjectors: nil];
    [self setStack:nil];
    [self setTokens:nil];
    return [zipper toArray:token];
}

/**
 * Processes arbitrary token values for complicated substitution patterns.
 * In general:
 *
 * If $token is an array, it is a list of tokens to substitute for the
 * current token. These tokens then get individually processed. If there
 * is a leading integer in the list, that integer determines how many
 * tokens from the stream should be removed.
 *
 * If $token is a regular token, it is swapped with the current token.
 *
 * If $token is false, the current token is deleted.
 *
 * If $token is an integer, that number of tokens (with the first token
 * being the current one) will be deleted.
 *
 * @param HTMLPurifier_Token|array|int|bool $token Token substitution value
 * @param HTMLPurifier_Injector|int $injector Injector that performed the substitution; default is if
 *        this is not an injector related operation.
 * @throws HTMLPurifier_Exception
 */
- (void)processToken:(NSObject*)token injector:(HTMLPurifier_Injector*)injector
{
    // normalize forms of token
    if(![token isKindOfClass:[NSNumber class]])
    {
        if([token isEqual:@NO])
        {
            token = @[@1];
        }
        else
        {
            token = @[token];
        }
    }

    if (![token isKindOfClass:[NSObject class]]) {
        token = @[@1, token];
    }
    if (![token[0] isKindOfClass:[NSNumber class]])
    {
        array_unshift(token, 1);
    }
    if ([token[0] isEqual:@0])
    {
        throw [NSException exceptionWithName:@"MakeWellFormed exception" reason:@"Deleting zero tokens is not valid" userInfo:nil];
    }
    
    // $token is now an array with the following form:
    // array(number nodes to delete, new node 1, new node 2, ...)
    
    delete = array_shift(token);
    NSArray* pair = [self.zipper splice:self.token delete:delete token:token];
    NSArray* old = nil;
    NSArray* r = nil;
    if(pair.count>0)
        old = pair[0];
    if(pair.count>1)
        r = pair[1];
    
    if (injector > -1) {
        // determine appropriate skips
        NSArray* oldskip = old[0] ? [old[0] skip] : @[];
        for(NSObject* object in token)
        {
            [object setSkip:oldskip];
            [object.skip setObject:@YES forKey:injector];
        }
    }
    
    return r;
    
}

/**
 * Inserts a token before the current token. Cursor now points to
 * this token.  You must reprocess after this.
 * @param HTMLPurifier_Token $token
 */
- (void)insertBefore:(HTMLPurifier_Token*)token
{
    // NB not $this->zipper->insertBefore(), due to positioning
    // differences
    splice = [self.zipper splice:self.token , 0, array($token)];
    
    return splice[1];
}

/**
 * Removes current token. Cursor now points to new token occupying previously
 * occupied space.  You must reprocess after this.
 */
- (void)remove
{
    return [[self zipper] delete];
}




@end
