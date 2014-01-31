//
//  HTMLPurifier_Node.m
//  HTMLPurifier
//
//  Created by Roman Priebe on 12.01.14.


#import "HTMLPurifier_Node.h"

@implementation HTMLPurifier_Node

- (id)init
{
    self = [super init];
    if (self) {
        _isWhitespace = NO;
    }
    return self;
}

- (NSArray*)toTokenPair
{
    return nil;
}


@end
