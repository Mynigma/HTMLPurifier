//
//  HTMLPurifier_Strategy_Composite.m
//  HTMLPurifier
//
//  Created by Roman Priebe on 12.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_Strategy_Composite.h"
#import "HTMLPurifier_Config.h"
#import "HTMLPurifier_Context.h"

/**
 * Composite strategy that runs multiple strategies on tokens.
 */
@implementation HTMLPurifier_Strategy_Composite

- (id)init
{
    self = [super init];
    if (self) {
        strategies = [NSMutableArray new];
    }
    return self;
}

- (NSMutableArray*)execute:(NSMutableArray*)tokens config:(HTMLPurifier_Config*)config context:(HTMLPurifier_Context*)context
    {
        for(HTMLPurifier_Strategy* strategy in strategies)
            tokens = [strategy execute:tokens config:config context:context];
        return tokens;
    }



@end
