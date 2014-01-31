//
//  HTMLPurifier_HTMLModule_XMLCommonAttributes.m
//  HTMLPurifier
//
//  Created by Roman Priebe on 21.01.14.


#import "HTMLPurifier_HTMLModule_XMLCommonAttributes.h"

@implementation HTMLPurifier_HTMLModule_XMLCommonAttributes


- (id)initWithConfig:config
{
    self = [super initWithConfig:config];
    if (self) {
        self.name = @"XMLCommonAttributes";
        self.attr_collections = [@{ @"Lang" : @{ @"xml:lang" : @"LanguageCode" } } mutableCopy];
    }
    return self;
}


@end
