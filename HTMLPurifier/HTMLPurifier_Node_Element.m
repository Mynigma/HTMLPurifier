//
//  HTMLPurifier_Node_Element.m
//  HTMLPurifier
//
//  Created by Roman Priebe on 12.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_Node_Element.h"
#import "HTMLPurifier_Token_Empty.h"
#import "HTMLPurifier_Token_Start.h"
#import "HTMLPurifier_Token_End.h"

@implementation HTMLPurifier_Node_Element

- (id)initWithName:(NSString*)n
{
    return [self initWithName:n attr:nil line:nil col:nil armor:nil];
}


- (id)initWithName:(NSString*)n attr:(NSMutableDictionary*)att line:(NSNumber*)l col:(NSNumber*)c armor:(NSMutableDictionary*)arm
{
    self = [super init];
    if (self) {
        self.name = n;
        _attr = att;
        self.line = l;
        self.col = c;
        self.armor = arm;
        self.empty = NO;
        self.children = [NSMutableArray new];
        _endArmor = [NSMutableDictionary new];
        _endCol = nil;
        _endLine = nil;
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
            NSObject* end = [[HTMLPurifier_Token_End alloc] initWithName:self.name attr:@[] line:_endLine col:_endCol armor:self.endArmor];
            return @[start, end];
        }
    }


@end
