//
//  HTMLPurifier_HTMLModule_Edit.m
//  HTMLPurifier
//
//  Created by Roman Priebe on 18.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_HTMLModule_Edit.h"
#import "HTMLPurifier_ElementDef.h"
#import "BasicPHP.h"
#import "HTMLPurifier_ChildDef_Chameleon.h"


/**
 * XHTML 1.1 Edit Module, defines editing-related elements. Text Extension
 * Module.
 */
@implementation HTMLPurifier_HTMLModule_Edit


- (id)initWithConfig:(HTMLPurifier_Config*)config
{
    self = [super init];
    if (self) {
        self.name = @"Edit";
        NSString* contents = @"Chameleon: #PCDATA | Inline ! #PCDATA | Flow";
        NSMutableDictionary* attr = [@{@"cite":@"URI"} mutableCopy];
        [self addElement:@"del" type:@"Inline" contents:contents attrIncludes:@"Common" attr:attr];
        [self addElement:@"ins" type:@"Inline" contents:contents attrIncludes:@"Common" attr:attr];

        self.defines_child_def = YES;
    }
    return self;
}

/*
- (HTMLPurifier_ChildDef_Chameleon*)getChildDef:(HTMLPurifier_ElementDef*)def
    {
        if ([def.content_model_type isEqual:@"chameleon"])
        {
            return nil;
        }
        NSArray* value = explode(@"!", def.content_model);
        return [[HTMLPurifier_ChildDef_Chameleon alloc] initWit
                :value[0], value[1]];
    }
*/



@end
