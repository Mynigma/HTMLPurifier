//
//  HTMLPurifier_HTMLModule_List.m
//  HTMLPurifier
//
//  Created by Roman Priebe on 18.01.14.


#import "HTMLPurifier_HTMLModule_List.h"
#import "HTMLPurifier_ChildDef_List.h"
#import "HTMLPurifier_ElementDef.h"

/**
 * XHTML 1.1 List Module, defines list-oriented elements. Core Module.
 */
@implementation HTMLPurifier_HTMLModule_List

- (id)initWithConfig:(HTMLPurifier_Config*)config
{
    self = [super initWithConfig:config];
    if (self) {
        self.name = @"List";

        self.content_sets = [@{@"Flow":@"List"} mutableCopy];

        HTMLPurifier_ElementDef* ol = [self addElement:@"ol" type:@"List" contents:[HTMLPurifier_ChildDef_List new] attrIncludes:@"Common" attr:nil];
        HTMLPurifier_ElementDef* ul = [self addElement:@"ul" type:@"List" contents:[HTMLPurifier_ChildDef_List new] attrIncludes:@"Common" attr:nil];

        ol.wrap = @"li";
        ul.wrap = @"li";

        [self addElement:@"dl" type:@"List" contents:@"Required: dt | dd" attrIncludes:@"Common" attr:nil];

        [self addElement:@"li" type:nil contents:@"Flow" attrIncludes:@"Common" attr:nil];
        [self addElement:@"dd" type:nil contents:@"Flow" attrIncludes:@"Common" attr:nil];
        [self addElement:@"dt" type:nil contents:@"Inline" attrIncludes:@"Common" attr:nil];
    }
    return self;
}


@end
