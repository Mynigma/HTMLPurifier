//
//  HTMLPurifier_EntityLookup.m
//  HTMLPurifier
//
//  Created by Roman Priebe on 16.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_EntityLookup.h"


static HTMLPurifier_EntityLookup* commonLookup;

@implementation HTMLPurifier_EntityLookup


- (id)init
{
    if(commonLookup)
        return commonLookup;

    self = [super init];
    if (self) {
        NSURL* plistURL = [[NSBundle mainBundle] URLForResource:@"entities" withExtension:@"plist"];

        _table = [NSDictionary dictionaryWithContentsOfURL:plistURL];

        commonLookup = self;
    }
    return self;
}

+ (HTMLPurifier_EntityLookup*)instance
{
    return [self instanceWithPrototype:nil];
}

+ (HTMLPurifier_EntityLookup*)instanceWithPrototype:(HTMLPurifier_EntityLookup*)prototype;
{
    //all moved to init
    return [HTMLPurifier_EntityLookup new];
}


@end
