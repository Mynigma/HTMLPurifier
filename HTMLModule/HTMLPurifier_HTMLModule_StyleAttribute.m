//
//  HTMLPurifier_HTMLModule_StyleAttribute.m
//  HTMLPurifier
//
//  Created by Roman Priebe on 18.01.14.


#import "HTMLPurifier_HTMLModule_StyleAttribute.h"
#import "HTMLPurifier_AttrDef_CSS.h"

/**
 * XHTML 1.1 Edit Module, defines editing-related elements. Text Extension
 * Module.
 */
@implementation HTMLPurifier_HTMLModule_StyleAttribute


- (id)initWithConfig:(HTMLPurifier_Config*)config
{
    self = [super initWithConfig:config];
    if (self) {
        self.name = @"StyleAttribute";
        self.attr_collections = [@{@"Style":@{@"style":[HTMLPurifier_AttrDef_CSS new]},@"Core":@{@0:@[@"Style"]}} mutableCopy];
        //self.attr_collections[@"Style"][@"style"] = [HTMLPurifier_AttrDef_CSS new];

    }
    return self;
}


@end
