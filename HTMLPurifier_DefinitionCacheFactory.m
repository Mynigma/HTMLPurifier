//
//  HTMLPurifier_DefinitionCacheFactory.m
//  HTMLPurifier
//
//  Created by Roman Priebe on 15.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_DefinitionCacheFactory.h"

@implementation HTMLPurifier_DefinitionCacheFactory

- (id)init
{
    self = [super init];
    if (self) {
        caches = [@{@"Serializer":@[]} mutableCopy];
        implementations = [NSMutableDictionary new];
        decorators = [NSMutableDictionary new];
    }
    return self;
}

@end
