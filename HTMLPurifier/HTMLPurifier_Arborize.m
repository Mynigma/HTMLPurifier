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

@implementation HTMLPurifier_Arborize


- (NSArray*)arborizeTokens:(NSArray*)tokens config:(HTMLPurifier_Config*)config context:(HTMLPurifier_Context*)context
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
            [token setStart:nil];
            HTMLPurifier_Token* r = array_pop(stack);
            assert([r->name isEqual:[token name]]);
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

public static function flatten($node, $config, $context) {
    $level = 0;
    $nodes = array($level => new HTMLPurifier_Queue(array($node)));
    $closingTokens = array();
    $tokens = array();
    do {
        while (!$nodes[$level]->isEmpty()) {
            $node = $nodes[$level]->shift(); // FIFO
            list($start, $end) = $node->toTokenPair();
            if ($level > 0) {
                $tokens[] = $start;
            }
            if ($end !== NULL) {
                $closingTokens[$level][] = $end;
            }
            if ($node instanceof HTMLPurifier_Node_Element) {
                $level++;
                $nodes[$level] = new HTMLPurifier_Queue();
                foreach ($node->children as $childNode) {
                    $nodes[$level]->push($childNode);
                }
            }
        }
        $level--;
        if ($level && isset($closingTokens[$level])) {
            while ($token = array_pop($closingTokens[$level])) {
                $tokens[] = $token;
            }
        }
    } while ($level > 0);
    return $tokens;
}
}

@end
