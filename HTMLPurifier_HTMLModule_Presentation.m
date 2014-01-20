//
//  HTMLPurifier_HTMLModule_Presentation.m
//  HTMLPurifier
//
//  Created by Roman Priebe on 18.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_HTMLModule_Presentation.h"
#import "HTMLPurifier_ElementDef.h"

/**
 * XHTML 1.1 Presentation Module, defines simple presentation-related
 * markup. Text Extension Module.
 * @note The official XML Schema and DTD specs further divide this into
 *       two modules:
 *          - Block Presentation (hr)
 *          - Inline Presentation (b, big, i, small, sub, sup, tt)
 *       We have chosen not to heed this distinction, as content_sets
 *       provides satisfactory disambiguation.
 */
@implementation HTMLPurifier_HTMLModule_Presentation

- (id)init
{
    self = [super init];
    if (self) {

        self.name = @"Presentation";

        [self addElement:@"hr" type:@"Block" contents:@"Empty" attrIncludes:@"Common" attr:nil];
        [self addElement:@"sub" type:@"Inline" contents:@"Inline" attrIncludes:@"Common" attr:nil];
        [self addElement:@"sup" type:@"Inline" contents:@"Inline" attrIncludes:@"Common" attr:nil];

        HTMLPurifier_ElementDef* b = [self addElement:@"b" type:@"Inline" contents:@"Inline" attrIncludes:@"Common" attr:nil];
        b.formatting = YES;

        HTMLPurifier_ElementDef* big = [self addElement:@"big" type:@"Inline" contents:@"Inline" attrIncludes:@"Common" attr:nil];
        big.formatting = YES;

        HTMLPurifier_ElementDef* i = [self addElement:@"i" type:@"Inline" contents:@"Inline" attrIncludes:@"Common" attr:nil];
        i.formatting = YES;

        HTMLPurifier_ElementDef* small = [self addElement:@"small" type:@"Inline" contents:@"Inline" attrIncludes:@"Common" attr:nil];
        small.formatting = YES;

        HTMLPurifier_ElementDef* tt = [self addElement:@"tt" type:@"Inline" contents:@"Inline" attrIncludes:@"Common" attr:nil];
        tt.formatting = YES;

    }
    return self;
}

- (id)init
{
    return [self initWithConfig:nil];
}


@end
