//
//  HTMLPurifier_Strategy_FixNesting.m
//  HTMLPurifier
//
//  Created by Roman Priebe on 12.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_Strategy_FixNesting.h"
#import "HTMLPurifier_Arborize.h"
#import "HTMLPurifier_Node.h"
#import "HTMLPurifier_Definition.h"
#import "HTMLPurifier_Config.h"
#import "HTMLPurifier_Token.h"
#import "BasicPHP.h"
#import "HTMLPurifier_Context.h"
#import "HTMLPurifier_HTMLDefinition.h"
#import "HTMLPurifier_ElementDef.h"
#import "HTMLPurifier_Node_Element.h"
#import "HTMLPurifier_ChildDef.h"


@implementation HTMLPurifier_Strategy_FixNesting




- (NSMutableArray*)execute:(NSMutableArray*)tokens config:(HTMLPurifier_Config*)config context:(HTMLPurifier_Context*)context;
{
    //####################################################################//
    // Pre-processing

    // O(n) pass to convert to a tree, so that we can efficiently
    // refer to substrings
    HTMLPurifier_Node_Element* topNode = (HTMLPurifier_Node_Element*)[HTMLPurifier_Arborize arborizeTokens:tokens config:config context:context];

    // get a copy of the HTML definition
    HTMLPurifier_HTMLDefinition* definition = [config getHTMLDefinition];

    BOOL excludesEnabled = ![(NSNumber*)[config get:@"Core.DisableExcludes"] boolValue];

    // setup the context variable 'IsInline', for chameleon processing
    // is 'false' when we are not inline, 'true' when it must always
    // be inline, and an integer when it is inline for a certain
    // branch of the document tree
    BOOL isInline = [[definition info_parent_def] descendants_are_inline];
    [context registerWithName:@"IsInline" ref:@(isInline)];

    //####################################################################//
    // Loop initialization

    // stack that contains all elements that are excluded
    // it is organized by parent elements, similar to $stack,
    // but it is only populated when an element with exclusions is
    // processed, i.e. there won't be empty exclusions.


    //NSMutableDictionary* excludeStack = [[definition info_parent_def] excludes];

    // variable that contains the start token while we are processing
    // nodes. This enables error reporting to do its job
    HTMLPurifier_Node_Element* node = topNode;
    // dummy token
    NSArray* pair = [node toTokenPair];
    HTMLPurifier_Token* token = nil;
    HTMLPurifier_Token* d = nil;
    if(pair.count>0)
        token = pair[0];
    if(pair.count>1)
        d = pair[1];

    [context registerWithName:@"CurrentNode" ref:node];
    [context registerWithName:@"CurrentToken" ref:token];

    //####################################################################//
    // Loop

    // We need to implement a post-order traversal iteratively, to
    // avoid running into stack space limits.  This is pretty tricky
    // to reason about, so we just manually stack-ify the recursive
    // variant:
    //
    //  function f($node) {
    //      foreach ($node->children as $child) {
    //          f($child);
    //      }
    //      validate($node);
    //  }
    //
    // Thus, we will represent a stack frame as array($node,
    // $is_inline, stack of children)
    // e.g. array_reverse($node->children) - already processed
    // children.

    HTMLPurifier_ElementDef* parentDef = [definition info_parent_def];
    NSMutableArray* stack = [@[@[topNode, @([parentDef descendants_are_inline]), [parentDef excludes], @0]] mutableCopy];

    NSInteger ix = 0;

    NSMutableDictionary* excludes = [NSMutableDictionary new];

    while (stack.count>0)
    {
        NSArray* stackObject = (NSArray*)array_pop(stack);
        if(stackObject.count>0)
            node = stackObject[0];
        if(stackObject.count>1)
            isInline = [stackObject[1] boolValue];
        if(stackObject.count>2)
            excludes = stackObject[2];
        if(stackObject.count>3)
            ix = [stackObject[3] integerValue];

        // recursive call
        BOOL go = NO;
        HTMLPurifier_ElementDef* def = stack.count==0 ? [definition info_parent_def] : definition.info[[node valueForKey:@"name"]];
        while (node.children[ix])
        {
            HTMLPurifier_Node_Element* child = node.children[ix++];
            if ([child isKindOfClass:[HTMLPurifier_Node_Element class]])
            {
                go = YES;
                [stack addObject:@[node, @(isInline), excludes, @(ix)]];
                [stack addObject:@[child,
                                   // ToDo: I don't think it matters if it's def or
                                   // child_def, but double check this...
                                   @(isInline || [def descendants_are_inline]),
                                   ([[def excludes] count]==0) ? excludes
                                   : dict_merge_2(excludes, [def excludes]),
                                   @0]];
                break;
            }
        };
        if (go) continue;
        NSArray* pair = [node toTokenPair];
        HTMLPurifier_Token* token = nil;
        HTMLPurifier_Token* d = nil;
        if(pair.count>0)
            token = pair[0];
        if(pair.count>1)
            d = pair[1];


        // base case
        if (excludesEnabled && [excludes[node.name] isEqual:@YES])
        {
            node.dead = true;
            NSLog(@"Strategy_FixNesting: Node excluded: %@", node);
        }
        else
        {
            // XXX I suppose it would be slightly more efficient to
            // avoid the allocation here and have children
            // strategies handle it
            NSMutableArray* children = [NSMutableArray new];
            for(HTMLPurifier_Node* child in node.children)
            {
                if (![child dead])
                    [children addObject:child];
            }

            NSObject* result = [[def child] validateChildren:children config:config context:context];
            if ([result isEqual:@YES])
            {
                // nop
                [node setChildren:children];
            } else if ([result isEqual:@NO])
            {
                [node setDead:YES];
                NSLog(@"Strategy_FixNesting: Node removed");
            }
            else if(result)
            {
                [node setChildren:[(NSArray*)result mutableCopy]];
                // XXX This will miss mutations of internal nodes. Perhaps defer to the child validators
                if ([(NSArray*)result count]==0 && children.count==0)
                {
                    NSLog(@"Strategy_FixNesting: Node contents removed");
                }
                else if (![result isEqual:children])
                {
                    NSLog(@"Strategy_FixNesting: Node reorganized");
                }
            }
        }
    }

    //####################################################################//
    // Post-processing

    // remove context variables
    [context destroy:@"IsInline"];
    [context destroy:@"CurrentNode"];
    [context destroy:@"CurrentToken"];

    //####################################################################//
    // Return

    return [[HTMLPurifier_Arborize flattenNode:node config:config context:context] mutableCopy];
}

@end
