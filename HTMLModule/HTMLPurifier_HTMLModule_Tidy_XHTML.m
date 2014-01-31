//
//  HTMLPurifier_HTMLModule_Tidy_XHTML.m
//  HTMLPurifier
//
//  Created by Roman Priebe on 25.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_HTMLModule_Tidy_XHTML.h"
#import "HTMLPurifier_AttrTransform_Lang.h"



@implementation HTMLPurifier_HTMLModule_Tidy_XHTML

- (id)initWithConfig:(HTMLPurifier_Config*)config
{
    self = [super initWithConfig:config];
    if (self) {
        self.name = @"Tidy_XHTML";
        self.defaultLevel = @"medium";
    }
    return self;
}


- (NSMutableDictionary*)makeFixes
    {
        NSMutableDictionary* r = [NSMutableDictionary new];
        r[@"@lang"] = [HTMLPurifier_AttrTransform_Lang new];
        return r;
    }

@end
