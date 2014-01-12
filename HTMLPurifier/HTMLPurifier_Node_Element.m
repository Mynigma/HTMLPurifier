//
//  HTMLPurifier_Node_Element.m
//  HTMLPurifier
//
//  Created by Roman Priebe on 12.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_Node_Element.h"
#import "HTMLPurifier_Token_Empty.h"

@implementation HTMLPurifier_Node_Element


- (id)initWithName:(NSString*)n attr:(NSMutableDictionary*)att line:(NSInteger)l col:(NSInteger)c armor:(NSMutableDictionary*)arm
{
    self = [super init];
    if (self) {
        _name = n;
        _attr = att;
        self.line = l;
        self.col = c;
        self.armor = arm;
        _empty = NO;
        _children = [NSMutableArray new];
    }
    return self;
}

- (NSArray*)toTokenPair
{
        // XXX inefficiency here, normalization is not necessary
        if (self.empty)
        {
            return @[[[HTMLPurifier_Token_Empty alloc] initWithName:self.name attr:self.attr line:self.line col:self.col armor:self.armor], [NSNull null]];
        }
        else
        {
            NSObject* start = [[HTMLPurifier_Token_Start alloc] initWithName:self.name attr:self.attr line:self.line col:self.col armor:self.armor];

            , $this->attr, $this->line, $this->col, $this->armor);
            NSObject* $end = [[HTMLPurifier_Token_End initWithName:self.name attr:@[] self.endLine col:self.endCol armor:self.endArmor];
            return @[start, end];
        }
    }


@end
