//
//  HTMLPurifier_Injector.m
//  HTMLPurifier
//
//  Created by Roman Priebe on 13.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_Injector.h"
#import "HTMLPurifier_Token.h"
#import "HTMLPurifier_Config.h"
#import "HTMLPurifier_Context.h"
#import "HTMLPurifier_Zipper.h"
#import "HTMLPurifier_HTMLDefinition.h"
#import "BasicPHP.h"
#import "HTMLPurifier_ElementDef.h"
#import "HTMLPurifier_Token_Start.h"
#import "HTMLPurifier_Token_End.h"
#import "HTMLPurifier_ChildDef.h"

@implementation HTMLPurifier_Injector



- (id)init
{
    self = [super init];
    if (self) {
        _needed = [NSMutableDictionary new];
        rewindOffset = -1;
    }
    return self;
}


- (void)rewindOffset:(NSInteger)offset
{
    rewindOffset = offset;
}

-(NSInteger)getRewindOffset
    {
        NSInteger r = rewindOffset;
        rewindOffset = -1;
        return r;
    }

    /**
     * Prepares the injector by giving it the config and context objects:
     * this allows references to important variables to be made within
     * the injector. This function also checks if the HTML environment
     * will work with the Injector (see checkNeeded()).
     * @param HTMLPurifier_Config $config
     * @param HTMLPurifier_Context $context
     * @return bool|string Boolean false if success, string of missing needed element/attribute if failure
     */
- (NSString*)prepare:(HTMLPurifier_Config*)config context:(HTMLPurifier_Context*)context
    {
        self->htmlDefinition = [config getHTMLDefinition];
        // Even though this might fail, some unit tests ignore this and
        // still test checkNeeded, so be careful. Maybe get rid of that
        // dependency.
        NSString* result = [self checkNeeded:config];
        if (result)
        {
            return result;
        }
        currentNesting = (NSMutableArray*)[[context getWithName:@"CurrentNesting"] mutableCopy];
        currentToken = (HTMLPurifier_Token*)[context getWithName:@"CurrentToken"];
        inputZipper = (HTMLPurifier_Zipper*)[context getWithName:@"InputZipper"];
        return nil;
    }

    /**
     * This function checks if the HTML environment
     * will work with the Injector: if p tags are not allowed, the
     * Auto-Paragraphing injector should not be enabled.
     * @param HTMLPurifier_Config $config
     * @return bool|string Boolean false if success, string of missing needed element/attribute if failure
     */
- (NSString*)checkNeeded:(HTMLPurifier_Config*)config
    {
        HTMLPurifier_HTMLDefinition* def = [config getHTMLDefinition];
        for(NSString* element in self.needed.allKeys)
        {
            NSObject* newElement = element;
            NSArray* attributes = self.needed[element];
            if ([element isKindOfClass:[NSNumber class]])
            {
                newElement = attributes;
            }
            if (!def.info[newElement])
            {
                return (NSString*)newElement;
            }
            if (![attributes isKindOfClass:[NSArray class]])
            {
                continue;
            }
            for(NSString* name in attributes)
            {
                if (![(NSObject*)def.info[newElement] valueForKey:@"attr"][name])
                {
                    return [NSString stringWithFormat:@"%@.%@", newElement, name];
                }
            }
        }
        return nil;
    }

    /**
     * Tests if the context node allows a certain element
     * @param string $name Name of element to test for
     * @return bool True if element is allowed, false if it is not
     */
- (BOOL)allowsElement:(NSString*)name
    {
        return NO;
//        HTMLPurifier_ElementDef* parent = nil;
//        if (currentNesting.count!=0) {
//            HTMLPurifier_Token* parent_token = (HTMLPurifier_Token*)array_pop(currentNesting);
//            [currentNesting addObject:parent_token];
//            parent = htmlDefinition.info[[parent_token valueForKey:@"name"]];
//        } else {
//            parent = htmlDefinition.info_parent_def;
//        }
//        if (!parent.child.elements[name]) || parent.excludes[name])) {
//            return NO;
//        }
//        // check for exclusion
//        for (NSInteger i = currentNesting.count - 2; i >= 0; i--) {
//            HTMLPurifier_Node* node = currentNesting[i];
//            def  = htmlDefinition->info[node->name];
//            if (def->excludes[name]) {
//                return NO;
//            }
//        }
//        return YES;
    }

    /**
     * Iterator function, which starts with the next token and continues until
     * you reach the end of the input tokens.
     * @warning Please prevent previous references from interfering with this
     *          functions by setting $i = null beforehand!
     * @param int $i Current integer index variable for inputTokens
     * @param HTMLPurifier_Token $current Current token variable.
     *          Do NOT use $token, as that variable is also a reference
     * @return bool
     */
- (BOOL)forward:(NSInteger*)i current:(HTMLPurifier_Token**)current
    {
        if (!i) {
            *i = [inputZipper.back count] - 1;
        } else {
            (*i)--;
        }
        if (*i < 0) {
            return NO;
        }
        *current = inputZipper.back[*i];
        return YES;
    }

    /**
     * Similar to _forward, but accepts a third parameter $nesting (which
     * should be initialized at 0) and stops when we hit the end tag
     * for the node $this->inputIndex starts in.
     * @param int $i Current integer index variable for inputTokens
     * @param HTMLPurifier_Token $current Current token variable.
     *          Do NOT use $token, as that variable is also a reference
     * @param int $nesting
     * @return bool
     */
- (BOOL)forwardUntilEndToken:(NSInteger*)i current:(HTMLPurifier_Token**)current nesting:(NSInteger*)nesting
    {
        BOOL result = [self forward:i current:current];
        if (!result) {
            return NO;
        }
        if (nesting<0) {
            nesting = 0;
        }
        if ([*current isKindOfClass:[HTMLPurifier_Token_Start class]])
        {
            (*nesting)++;
        } else if ([*current isKindOfClass:[HTMLPurifier_Token_End class]])
        {
            if (*nesting <= 0) {
                return false;
            }
            (*nesting)--;
        }
        return true;
    }

    /**
     * Iterator function, starts with the previous token and continues until
     * you reach the beginning of input tokens.
     * @warning Please prevent previous references from interfering with this
     *          functions by setting $i = null beforehand!
     * @param int $i Current integer index variable for inputTokens
     * @param HTMLPurifier_Token $current Current token variable.
     *          Do NOT use $token, as that variable is also a reference
     * @return bool
     */
- (BOOL)backward:(NSInteger*)i current:(HTMLPurifier_Token**)current
    {
        if (!i) {
            *i = [inputZipper.front count] - 1;
        } else {
            (*i)--;
        }
        if (*i < 0) {
            return NO;
        }
        *current = inputZipper.front[*i];
        return YES;
    }

    /**
     * Handler that is called when a text token is processed
     */
- (void)handleText:(HTMLPurifier_Token**)token
    {
    }

    /**
     * Handler that is called when a start or empty token is processed
     */
- (void)handleElement:(HTMLPurifier_Token**)token
    {
    }

    /**
     * Handler that is called when an end token is processed
     */
- (void)handleEnd:(HTMLPurifier_Token**)token
    {
        [self notifyEnd:*token];
    }

    /**
     * Notifier that is called when an end token is processed
     * @param HTMLPurifier_Token $token Current token variable.
     * @note This differs from handlers in that the token is read-only
     * @deprecated
     */
- (void)notifyEnd:(HTMLPurifier_Token*)token
    {
    }



@end
