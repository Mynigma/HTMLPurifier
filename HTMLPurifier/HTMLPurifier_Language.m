//
//  HTMLPurifier_Language.m
//  HTMLPurifier
//
//  Created by Lukas Neumann on 10.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_Language.h"

@implementation HTMLPurifier_Language


- (id)init
{
    self = [super init];
    if (self) {
        _code = @"en";
        _fallback = nil;
        _messages = [NSMutableDictionary new];
        _errorNames = [NSMutableDictionary new];
        _error = NO;
        _loaded = NO;
    }
    return self;
}


@end
