//
//  HTMLPurifier_HTMLModule_NonXMLCommonAttributes.m
//  HTMLPurifier
//
//  Created by Roman Priebe on 21.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_HTMLModule_NonXMLCommonAttributes.h"

@implementation HTMLPurifier_HTMLModule_NonXMLCommonAttributes

- (id)initWithConfig:config
{
    self = [super initWithConfig:config];
    if (self) {
        self.name = @"NonXMLCommonAttributes";
        self.attr_collections = [@{ @"Lang" : @{ @"lang" : @"LanguageCode" } } mutableCopy];
    }
    return self;
}


@end
