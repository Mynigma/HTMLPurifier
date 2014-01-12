//
//  HTMLPurifier_Arborize.m
//  HTMLPurifier
//
//  Created by Roman Priebe on 12.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_Arborize.h"
#import "HTMLPurifier_Token_Start.h"
#import "HTMLPurifier_Token_End.h"
#import "BasicPHP.h"
#import "HTMLPurifier_Definition.h"
#import "HTMLPurifier_Context.h"
#import "HTMLPurifier_Token.h"

@implementation HTMLPurifier_Arborize


+ (NSArray*)arborizeTokens:(NSArray*)tokens config:(HTMLPurifier_Config*)config context:(HTMLPurifier_Context*)context
{
    HTMLPurifier_Definition* definition = [config getHTMLDefinition];
    HTMLPurifier_Token_Start* parent = [[HTMLPurifier_Token_Start alloc] initWith:definition->info_parent];
    NSMutableArray* stack = [[NSMutableArray alloc] initWithObject:[parent toNode]];
    for(HTMLPurifier_Token* token in tokens)
    {
        [token setSkip:nil];
        [token setCarryover:nil];
        if([token isKindOfClass:[HTMLPurifier_Token_End class]])
        {
            [(HTMLPurifier_Token_End*)token setStart:nil];
            HTMLPurifier_Token* r = array_pop(stack);
            assert([[r name] isEqual:[token name]]);
            assert([[token attr] count]==0);
            [r setEndCol:[token col]];
            [r setEndLine:[token line]];
            [r setEndArmor:[token armor]];
            continue;
        }
        HTMLPurifier_Node* node = [token toNode];
        [[[stack objectAtIndex:stack.count-1] children] addObject:node];
        if ([token isKindOfClass:[HTMLPurifier_Token_Start class]]) {
            [stack addObject:node];
        }
    }
    assert(count(stack) == 1);
    return stack[0];
}

+ (NSArray*)flattenNode:(HTMLPurifier_Node*)node config:(HTMLPurifier_Config*)config context:(HTMLPurifier_Context*)context
{
    NSNumber* level = @0;
    NSMutableDictionary* nodes = [NSMutableDictionary dictionaryWithObject:[[HTMLPurifier_Queue alloc] initWith:@[node]] forKey:level];
    NSMutableArray* closingTokens = [NSMutableArray new];
    NSMutableArray* tokens = [NSMutableArray new];
    do {
        while ([nodes objectForKey:level]) {
            HTMLPurifier_Node* node = [[nodes objectForKey:level] shift]; // FIFO
            NSArray* pair = [node toTokenPair];
            HTMLPurifier_Token* start, end;
            if(pair.count>0)
                start = pair[0];
            if(pair.count>1)
                end = pair[1];
            if (level.intValue > 0) {
                [tokens addObject:start];
            }
            if (end) {
                [[closingTokens objectForKey:level] addObject:end];
            }
            if ([node isKindOfClass:[HTMLPurifier_Node_Element class]]) {
                level = @(level.integerValue+1);
                [nodes setObject:[HTMLPurifier_Queue new] forKey:level];
                for(HTMLPurifier_Node* childNode)
                    [[nodes objectForKey:level] push:childNode];
           }
        }
        level = @(level.integerValue-1);
        if (level && closingTokens[level]) {
            while (token = array_pop(closingTokens[level]))
            {
                [tokens addObject:token];
            }
        }
    } while ($level > 0);
    return tokens;
}

@end
