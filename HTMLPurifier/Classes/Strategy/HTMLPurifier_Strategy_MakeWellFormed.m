//
//   HTMLPurifier_Strategy_MakeWellFormed.m
//   HTMLPurifier
//
//  Created by Roman Priebe on 13.01.14.


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
    NSDictionary* global_parent_allowed_elements = [[[definition info_parent_def] child] getAllowedElements:config];
    //$e = $context->get('ErrorCollector', true);
    NSNumber* index = nil; // injector index

    NSArray* pair = [HTMLPurifier_Zipper fromArray:tokens];

    if(pair.count<2)
        return [@[] mutableCopy];

    HTMLPurifier_Zipper* zipper = (HTMLPurifier_Zipper*)pair[0];
    _token = (HTMLPurifier_Token*)pair[1];

    NSMutableArray* stack = [NSMutableArray new];

    // member variables
    _stack = stack;
    _tokens = tokens;
    _zipper = zipper;
    _config = config;
    _context = context;

    // context variables
    [context registerWithName:@"CurrentNesting" ref:stack];
    [context registerWithName:@"InputZipper" ref:zipper];
    [context registerWithName:@"CurrentToken" ref:_token];

    // -- begin INJECTOR --

    self->_injectors = [NSMutableArray new];

    NSMutableDictionary* injectors = [[config getBatch:@"AutoFormat"] mutableCopy];
    NSMutableDictionary* def_injectors = [definition info_injector];
    NSMutableArray* custom_injectors = [injectors[@"Custom"] isKindOfClass:[NSArray class]]?injectors[@"Custom"]:nil;
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
        NSObject* newInjector = [NSClassFromString(newInjectorName) new];
        if(newInjector)
            [_injectors addObject:newInjector];
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
        [_injectors addObject:newInjector];
    }

    // give the injectors references to the definition and context
    // variables for performance reasons
    NSArray* injectorsList = [_injectors copy];
    for(HTMLPurifier_Injector* injector in injectorsList)
    {
        NSString* string = [injector prepare:config context:context];
        if (!string)
        {
            continue;
        }
        [_injectors removeObject:injector];
        TRIGGER_ERROR(@"Cannot enable {%@} injector because %@ is not allowed", [injector name], string);
    }

    // -- end INJECTOR --

    // a note on reprocessing:
    //      In order to reduce code duplication, whenever some code needs
    //      to make HTML changes in order to make things "correct", the
    //      new HTML gets sent through the purifier, regardless of its
    //      status. This means that if we add a start token, because it
    //      was totally necessary, we don't have to update nesting; we just
    //      punt ($reprocess = true; continue;) and it does that for us.

    // isset is in loop because $tokens size changes during loop exec
    BOOL reprocess = NO; // whether or not to reprocess the same token
                         //token = (HTMLPurifier_Token*)[_zipper next:token];

    BOOL isFirstLoop = YES;

    while(YES)
    {
        if(!isFirstLoop)
        {
            if(reprocess)
            {
                reprocess = NO;
            }
            else
            {
                _token = (HTMLPurifier_Token*)[_zipper next:_token];
            }
        }
        isFirstLoop = NO;



        // only increment if we don't need to reprocess
        

        // check for a rewind
        if ([index isKindOfClass:[NSNumber class]])
        {
            // possibility: disable rewinding if the current token has a
            // rewind set on it already. This would offer protection from
            // infinite loop, but might hinder some advanced rewinding.
            NSInteger injectorIndex = index.intValue;
            NSInteger rewind_offset = injectorIndex<_injectors.count?[_injectors[injectorIndex] getRewindOffset]:0;
            if (rewind_offset>=0) {
                for (NSInteger j = 0; j < rewind_offset; j++) {
                    if (![zipper front]) break;
                    _token = (HTMLPurifier_Token*)[_zipper prev:_token];
                    // indicate that other injectors should not process this token,
                    // but we need to reprocess it
                    //HTMLPurifier_Injector* injector = _injectors[index.intValue];
                    if([(HTMLPurifier_Token*)_token skip][index])
                        [[(HTMLPurifier_Token*)_token skip] removeObjectForKey:index];
                    [(HTMLPurifier_Token*)_token setRewind:index];
                    if ([_token isKindOfClass:[HTMLPurifier_Token_Start class]])
                    {
                        array_pop(_stack);
                    } else if ([_token isKindOfClass:[HTMLPurifier_Token_End class]])
                    {
                        [_stack addObject:[(HTMLPurifier_Token_End*)_token start]];
                    }
                }
            }
            index = nil;
        }

        // handle case of document end
        if (!_token) {
            // kill processing if stack is empty
            if ([_stack count] == 0) {
                break;
            }

            // peek
            HTMLPurifier_Token* top_nesting = (HTMLPurifier_Token*)array_pop(_stack);
            if (top_nesting)
                [_stack addObject:top_nesting];

            /*
             // send error [TagClosedSuppress]
             if ($e && !isset($top_nesting->armor['MakeWellFormed_TagClosedError'])) {
             $e->send(E_NOTICE, 'Strategy_MakeWellFormed: Tag closed by document end', $top_nesting);
             }*/

            // append, don't splice, since this is the end
            _token = [[HTMLPurifier_Token_End alloc] initWithName:top_nesting.name];

            // punt!
            reprocess = YES;
            continue;
        }

        //echo '<br>'; printZipper($zipper, $token);//printTokens($this->stack);
        //flush();

        // quick-check: if it's not a tag, no need to process
        if (![(HTMLPurifier_Token*)_token isTag])
        {
            if ([_token isKindOfClass:[HTMLPurifier_Token_Text class]])
            {
                for(NSInteger i=0; i<_injectors.count; i++)
                {
                    HTMLPurifier_Injector* injector = _injectors[i];
                    if([(HTMLPurifier_Token*)_token skip][@(i)])
                    {
                        index = @(i);
                        continue;
                    }
                    if ([(HTMLPurifier_Token*)_token rewind] && ![[(HTMLPurifier_Token*)_token rewind] isEqual:@(i)])
                    {
                        index = @(i);
                        continue;
                    }
                    
                    // XXX fuckup
                    HTMLPurifier_Token* r = (HTMLPurifier_Token*)_token;
                    [injector handleText:&r];

                    //
                    //  TO DO: clean up
                    //  in PHP the index i, not the injector is passed along!?!
                    //


                    _token = [self processToken:r remove:@1 injector:@(i)];
                    reprocess = YES;
                    index = @(i);
                    break;
                }
            }
            // another possibility is a comment
            continue;
        }
        NSString* type;
        if (definition.info[[(HTMLPurifier_Token*)_token name]])
        {
            type = [[definition.info[[(HTMLPurifier_Token*)_token name]] child] typeString];
        } else {
            type = nil; // Type is unknown, treat accordingly
        }

        // quick tag checks: anything that's *not* an end tag
        BOOL ok = NO;
        if ([type isEqual:@"empty"] && [_token isKindOfClass:[HTMLPurifier_Token_Start class]]) {
            // claims to be a start tag but is empty
            _token = [[HTMLPurifier_Token_Empty alloc] initWithName:[(HTMLPurifier_Token*)_token name] attr:[(HTMLPurifier_Token*)_token attr] sortedAttrKeys:[(HTMLPurifier_Token*)_token sortedAttrKeys] line:[(HTMLPurifier_Token*)_token line] col:[(HTMLPurifier_Token*)_token col] armor:[(HTMLPurifier_Token*)_token armor]];
            ok = YES;
        } else if (type && ![type isEqualToString:@"empty"] && [_token isKindOfClass: [HTMLPurifier_Token_Empty class]])
        {
            // claims to be empty but really is a start tag
            // NB: this assignment is required
            HTMLPurifier_Token* old_token = (HTMLPurifier_Token*)_token;
            _token = [[HTMLPurifier_Token_End alloc] initWithName:[(HTMLPurifier_Token*)_token name]];

            _token = [self insertBefore:[[HTMLPurifier_Token_Start alloc] initWithName:old_token.name attr:old_token.attr sortedAttrKeys:old_token.sortedAttrKeys line:old_token.line col:old_token.col armor:old_token.armor]];

            // punt (since we had to modify the input stream in a non-trivial way)
            reprocess = YES;
            continue;
        } else if ([_token isKindOfClass:[HTMLPurifier_Token_Empty class]]) {
            // real empty token
            ok = YES;
        } else if ([_token isKindOfClass:[HTMLPurifier_Token_Start class]]) {
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

                HTMLPurifier_Token* parent = (HTMLPurifier_Token*)array_pop(_stack);
                if (parent)
                    [_stack addObject:parent];

                HTMLPurifier_ElementDef* parent_def = nil;
                NSMutableDictionary* parent_elements = nil;
                BOOL autoclose = NO;
                if (definition.info[parent.name]) {
                    parent_def = definition.info[parent.name];
                    parent_elements = [[parent_def child] getAllowedElements:config];
                    autoclose = (parent_elements[[(HTMLPurifier_Token*)_token name]]==nil);
                }

                if (autoclose && [definition.info[[(HTMLPurifier_Token*)_token name]] wrap]) {
                    // Check if an element can be wrapped by another
                    // element to make it valid in a context (for
                    // example, <ul><ul> needs a <li> in between)
                    NSString* wrapname = [definition.info[[(HTMLPurifier_Token*)_token name]] wrap];
                    HTMLPurifier_ElementDef* wrapdef = definition.info[wrapname];
                    NSMutableDictionary* elements = [[wrapdef child] getAllowedElements:config];
                    if (elements[[(HTMLPurifier_Token*)_token name]] && parent_elements[wrapname])
                    {
                        HTMLPurifier_Token_Start* newtoken = [[HTMLPurifier_Token_Start alloc] initWithName:wrapname];
                        _token = [self insertBefore:newtoken];
                        reprocess = YES;
                        continue;
                    }
                }

                BOOL carryover = NO;
                // Useless like this
                if (autoclose && [parent_def formatting]) {
                    carryover = NO;
                }

                if (autoclose) {
                    // check if this autoclose is doomed to fail
                    // (this rechecks $parent, which his harmless)
                    BOOL autoclose_ok = global_parent_allowed_elements[[(HTMLPurifier_Token*)_token name]]!= nil;
                    if (!autoclose_ok) {
                        NSArray* stackCopy = [_stack copy];
                        for(NSObject* ancestor in stackCopy)
                        {
                            NSMutableDictionary* elements = [[definition.info[[ancestor valueForKey:@"name"]] child]getAllowedElements:config];
                            if (elements[[(HTMLPurifier_Token*)_token name]]) {
                                autoclose_ok = YES;
                                break;
                            }
                            if ([definition.info[[(HTMLPurifier_Token*)_token name]] wrap]) {
                                NSString* wrapname = [definition.info[[(HTMLPurifier_Token*)_token name]] wrap];
                                HTMLPurifier_ElementDef* wrapdef = definition.info[wrapname];
                                NSMutableDictionary* wrap_elements = [[wrapdef child] getAllowedElements:config];
                                if (wrap_elements[[(HTMLPurifier_Token*)_token name]] && elements[wrapname]) {
                                    autoclose_ok = YES;
                                    break;
                                }
                            }
                        }
                    }
                    if (autoclose_ok) {
                        // errors need to be updated
                        HTMLPurifier_Token_End* new_token = [[HTMLPurifier_Token_End alloc] initWithName:[parent valueForKey:@"name"]];
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
                            HTMLPurifier_Token* element = [parent copy];
                            // [TagClosedAuto]
                            element.armor[@"MakeWellFormed_TagClosedError"] = @YES;
                            element.carryover = @YES;
                            _token = [self processToken:@[new_token, _token, element]];
                        } else {
                            _token = [self insertBefore:new_token];
                        }
                    } else {
                        _token = (HTMLPurifier_Token*)[self removeObject];
                    }
                    reprocess = YES;
                    continue;
                }

            }
            ok = YES;
        }

        if(ok)
        {
            for(NSInteger i=0; i<_injectors.count; i++)
            {
                HTMLPurifier_Injector* injector = _injectors[i];
                if ([(HTMLPurifier_Token*)_token skip][@(i)]) {
                    index = @(i);
                    continue;
                }
                if ([(HTMLPurifier_Token*)_token rewind] && ![[(HTMLPurifier_Token*)_token rewind] isEqual:@(i)]) {
                    index = @(i);
                    continue;
                }
                HTMLPurifier_Token* r = (HTMLPurifier_Token*)_token;
                [injector handleElement:&r];
                _token = [self processToken:r remove:@1 injector:@(i)];
                reprocess = YES;
                index = @(i);
                break;
            }
            if (!reprocess) {
                // ah, nothing interesting happened; do normal processing
                if ([_token isKindOfClass:[HTMLPurifier_Token_Start class]]) {
                    [_stack addObject:_token];
                } else if ([_token isKindOfClass:[HTMLPurifier_Token_End class]]) {
                    @throw [NSException exceptionWithName:@"End tag handling exception" reason:@"Improper handling of end tag in start code; possible error in MakeWellFormed" userInfo:nil];
                }
            }
            continue;
        }

        // sanity check: we should be dealing with a closing tag
        if (![_token isKindOfClass:[HTMLPurifier_Token_End class]]) {
            @throw [NSException exceptionWithName:@"Unaccounted for tag exception" reason:@"Unaccounted for tag token in input stream, bug in HTML Purifier" userInfo:nil];
        }

        // make sure that we have something open
        if (_stack.count==0) {
            if (escape_invalid_tags)
            {
                _token = [[HTMLPurifier_Token_Text alloc] initWithData:[generator generateFromToken:(HTMLPurifier_Token*)_token]];
            } else {
                _token = (HTMLPurifier_Token*)[self removeObject];
            }
            reprocess = YES;
            continue;
        }

        // first, check for the simplest case: everything closes neatly.
        // Eventually, everything passes through here; if there are problems
        // we modify the input stream accordingly and then punt, so that
        // the tokens get processed again.
        HTMLPurifier_Token* current_parent = (HTMLPurifier_Token*)array_pop(_stack);
        if ([[current_parent valueForKey:@"name"] isEqual:[_token valueForKey:@"name"]])
        {
            [(HTMLPurifier_Token_End*)_token setStart:current_parent];
            for(NSInteger i=0; i<_injectors.count; i++)
            {
                HTMLPurifier_Injector* injector = _injectors[i];
                if ([(HTMLPurifier_Token*)_token skip][@(i)])
                {
                    index = @(i);
                    continue;
                }
                if ([(HTMLPurifier_Token*)_token rewind] && ![[(HTMLPurifier_Token*)_token rewind] isEqual:@(i)])
                {
                    index = @(i);
                    continue;
                }
                HTMLPurifier_Token* r = (HTMLPurifier_Token*)_token;
                [injector handleEnd:&r];
                _token = [self processToken:r remove:@1 injector:@(i)];
                [_stack addObject:current_parent];
                reprocess = YES;
                index = @(i);
                break;
            }
            continue;
        }

        // okay, so we're trying to close the wrong tag

        // undo the pop previous pop
        if (current_parent)
            [_stack addObject:current_parent];

        // scroll back the entire nest, trying to find our tag.
        // (feature could be to specify how far you'd like to go)
        NSInteger size = _stack.count;
        // -2 because -1 is the last element, but we already checked that
        NSMutableArray* skipped_tags = nil;
        for (NSInteger j = size - 2; j >= 0; j--) {
            if ([[_stack[j] valueForKey:@"name"] isEqual:[_token valueForKey:@"name"]])
            {
                skipped_tags = array_slice_2(_stack, j);
                break;
            }
        }

        // we didn't find the tag, so remove
        if (skipped_tags.count==0) {
            if (escape_invalid_tags) {
                _token = [[HTMLPurifier_Token_Text alloc] initWithData:[generator generateFromToken:(HTMLPurifier_Token*)_token]];
            } else {
                TRIGGER_ERROR(@"Strategy_MakeWellFormed: Stray end tag removed");
                _token = (HTMLPurifier_Token*)[self removeObject];
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
        NSMutableArray* replace = [@[_token] mutableCopy];
        NSInteger c = skipped_tags.count;
        for (NSInteger j = 1; j < c; j++)
        {
            // ...as well as from the insertions
            HTMLPurifier_Token_End* new_token = [[HTMLPurifier_Token_End alloc] initWithName:[skipped_tags[j] name]];
            [new_token setStart:skipped_tags[j]];
            array_unshift_2(replace, new_token);
            if(definition.info[[new_token valueForKey:@"name"]] && [definition.info[[new_token valueForKey:@"name"]] formatting])
            {
                // [TagClosedAuto]
                HTMLPurifier_Token* element = [skipped_tags[j] copy];
                element.carryover = @YES;
                NSMutableDictionary* armorDict = [element.armor mutableCopy];
                armorDict[@"MakeWellFormed_TagClosedError"] = @YES;
                [element setArmor:armorDict];
                [replace addObject:element];
            }
        }
        _token = [self processToken:replace];
        reprocess = YES;
        continue;
    }

    [context destroy:@"CurrentToken"];
    [context destroy:@"CurrentNesting"];
    [context destroy:@"InputZipper"];

    _injectors = nil;
    _stack = nil;
    _tokens = nil;
    return [[_zipper toArray:_token] mutableCopy];
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
- (HTMLPurifier_Token*)processToken:(NSObject*)passedToken
{
    return [self processToken:passedToken remove:@1 injector:@(-1)];
}

- (HTMLPurifier_Token*)processToken:(NSObject*)passedToken remove:(NSNumber*)remove injector:(NSNumber*)injectorIndex
{
    if([passedToken isKindOfClass:[HTMLPurifier_Token class]])
    {
        passedToken = @[passedToken];
    }

    /*if([passedToken isKindOfClass:[NSArray class]])
    {
        passedToken = passedToken;
    }*/

    if(!remove)
        remove = @1;

    if([passedToken isEqual:@NO])
    {
        remove = @1;
        _token = nil;
    }


    if (![passedToken isKindOfClass:[NSArray class]])
    {
        @throw [NSException exceptionWithName:@"MakeWellFormed exception" reason:@"Invalid token" userInfo:nil];
    }

    if ([remove isEqual:@0])
    {
        @throw [NSException exceptionWithName:@"MakeWellFormed exception" reason:@"Deleting zero tokens is not valid" userInfo:nil];
    }


    NSArray* pair = (NSArray*)[_zipper splice:_token delete:remove.integerValue replacement:(NSArray*)passedToken];
    NSArray* old = nil;
    HTMLPurifier_Token* r = nil;
    if(pair.count>0)
        old = pair[0];
    if(pair.count>1)
        r = pair[1];


    if (injectorIndex.integerValue > -1)
    {
        // determine appropriate skips
        NSMutableDictionary* oldskip = [old[0] skip] ? (NSMutableDictionary*)[[old[0] skip] mutableCopy] : [NSMutableDictionary new];
        NSArray* enumArray = [passedToken isKindOfClass:[NSArray class]]?(NSArray*)passedToken:@[passedToken];
        for(HTMLPurifier_Token* object in enumArray)
        {
            [object setSkip:oldskip];
            if (injectorIndex)
                [object.skip setObject:@YES forKey:injectorIndex];
        }
    }

    return r;
    
}

/**
 * Inserts a token before the current token. Cursor now points to
 * this token.  You must reprocess after this.
 * @param HTMLPurifier_Token $token
 */
- (HTMLPurifier_Token*)insertBefore:(HTMLPurifier_Token*)token
{
    // NB not $this->zipper->insertBefore(), due to positioning
    // differences
    NSArray* splice = (NSArray*)[_zipper splice:_token delete:0 replacement:@[token]];
    
    return splice[1];
}

/**
 * Removes current token. Cursor now points to new token occupying previously
 * occupied space.  You must reprocess after this.
 */
- (NSObject*)removeObject
{
    return [_zipper delete];
}




@end
