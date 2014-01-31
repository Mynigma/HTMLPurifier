//
//  HTMLPurifier_HTMLModule_Hypertext.m
//  HTMLPurifier
//
//  Created by Roman Priebe on 18.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_HTMLModule_Hypertext.h"
#import "HTMLPurifier_AttrDef_HTML_LinkTypes.h"
#import "HTMLPurifier_ElementDef.h"
#import "HTMLPurifier_Config.h"

@implementation HTMLPurifier_HTMLModule_Hypertext

- (id)initWithConfig:(HTMLPurifier_Config*)config
{
    self = [super initWithConfig:config];
    if (self) {
        self.name = @"Hypertext";
        HTMLPurifier_ElementDef* a = [self addElement:@"a" type:@"Inline" contents:@"Inline" attrIncludes:@"Common" attr:@{@"href":@"URI",@"rel":[[HTMLPurifier_AttrDef_HTML_LinkTypes alloc] initWithName:@"rel"], @"rev":[[HTMLPurifier_AttrDef_HTML_LinkTypes alloc] initWithName:@"rev"]}];
        a.formatting = YES;
        a.excludes = [NSMutableDictionary dictionaryWithDictionary:@{@"a":@YES}];
    }
    return self;
}



@end
