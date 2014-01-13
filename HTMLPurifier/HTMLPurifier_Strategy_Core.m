//
//  HTMLPurifier_Strategy_Core.m
//  HTMLPurifier
//
//  Created by Lukas Neumann on 10.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_Strategy_Core.h"
#import "HTMLPurifier_Strategy_FixNesting.h"
#import "HTMLPurifier_Strategy_ValidateAttributes.h"
#import "HTMLPurifier_Strategy_RemoveForeignElements.h"
#import "HTMLPurifier_Strategy_MakeWellFormed.h"

@implementation HTMLPurifier_Strategy_Core

- (id)init
{
    self = [super init];
    if (self) {
        [strategies addObject:[HTMLPurifier_Strategy_RemoveForeignElements new]];
        [strategies addObject:[HTMLPurifier_Strategy_MakeWellFormed new]];
        [strategies addObject:[HTMLPurifier_Strategy_FixNesting new]];
        [strategies addObject:[HTMLPurifier_Strategy_ValidateAttributes new]];
    }
    return self;
}


@end
