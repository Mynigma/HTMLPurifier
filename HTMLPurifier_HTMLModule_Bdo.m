//
//  HTMLPurifier_HTMLModule_Bdo.m
//  HTMLPurifier
//
//  Created by Roman Priebe on 18.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_HTMLModule_Bdo.h"
#import "HTMLPurifier_Config.h"

/**
 * XHTML 1.1 Bi-directional Text Module, defines elements that
 * declare directionality of content. Text Extension Module.
 */
@implementation HTMLPurifier_HTMLModule_Bdo

- (id)initWithConfig:(HTMLPurifier_Config*)config
{
    self = [super init];
    if (self) {
        self.name = @"Bdo";
        self.attr_collections = [@{@"I8N" : @{@"dir" : @NO}} mutableCopy];
        [self addElement:@"bdo" type:@"Inline" contents:@"Inline" attrIncludes:@[@"Core", @"Lang"] attr:@{@"dir":@"Enum#ltr,rtl"}];

        //TO DO: add post transform: HTMLPurifier_AttrTransform_BdsDir

        if(self.attr_collections && self.attr_collections[@"I18N"] && self.attr_collections[@"I18N"][@"dir"])
            self.attr_collections[@"I18N"][@"dir"] = @"Enum#ltr,rtl";
    }
    return self;
}

- (id)init
{
    return [self initWithConfig:nil];
}


@end
