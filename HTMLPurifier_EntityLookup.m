//
//  HTMLPurifier_EntityLookup.m
//  HTMLPurifier
//
//  Created by Roman Priebe on 16.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_EntityLookup.h"

@implementation HTMLPurifier_EntityLookup


- (void)setup
{
    return [self setup:nil];
}

- (void)setup:(NSString*)file_name;
{
    NSString* fileName = file_name;
    if (!fileName)
        fileName = @"entities.plist";

    _table = unserialize(file_get_contents(fileName));
}

@end
