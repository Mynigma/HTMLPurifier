//
//  HTMLPurifier_HTMLModule_Text.m
//  HTMLPurifier
//
//  Created by Roman Priebe on 19.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_HTMLModule_Text.h"
#import "HTMLPurifier_Config.h"
#import "HTMLPurifier_ElementDef.h"


/**
 * XHTML 1.1 Text Module, defines basic text containers. Core Module.
 * @note In the normative XML Schema specification, this module
 *       is further abstracted into the following modules:
 *          - Block Phrasal (address, blockquote, pre, h1, h2, h3, h4, h5, h6)
 *          - Block Structural (div, p)
 *          - Inline Phrasal (abbr, acronym, cite, code, dfn, em, kbd, q, samp, strong, var)
 *          - Inline Structural (br, span)
 *       This module, functionally, does not distinguish between these
 *       sub-modules, but the code is internally structured to reflect
 *       these distinctions.
 */
@implementation HTMLPurifier_HTMLModule_Text

- (id)initWithConfig:(HTMLPurifier_Config*)config
{
    self = [super init];
    if (self) {
        self.name = @"Text";
        self.content_sets = [@{@"Flow":@"Heading | Block | Inline"} mutableCopy];

        [self addElement:@"abbr" type:@"Inline" contents:@"Inline" attrIncludes:@"Common" attr:nil];
        [self addElement:@"acronym" type:@"Inline" contents:@"Inline" attrIncludes:@"Common" attr:nil];
        [self addElement:@"cite" type:@"Inline" contents:@"Inline" attrIncludes:@"Common" attr:nil];
        [self addElement:@"dfn" type:@"Inline" contents:@"Inline" attrIncludes:@"Common" attr:nil];
        [self addElement:@"kbd" type:@"Inline" contents:@"Inline" attrIncludes:@"Common" attr:nil];
        [self addElement:@"q" type:@"Inline" contents:@"Inline" attrIncludes:@"Common" attr:@{@"cite":@"URI"}];
        [self addElement:@"samp" type:@"Inline" contents:@"Inline" attrIncludes:@"Common" attr:nil];
        [self addElement:@"var" type:@"Inline" contents:@"Inline" attrIncludes:@"Common" attr:nil];
        HTMLPurifier_ElementDef* em = [self addElement:@"em" type:@"Inline" contents:@"Inline" attrIncludes:@"Common" attr:nil];
        em.formatting = YES;

        HTMLPurifier_ElementDef* strong = [self addElement:@"strong" type:@"Inline" contents:@"Inline" attrIncludes:@"Common" attr:nil];
        strong.formatting = YES;

        HTMLPurifier_ElementDef* code = [self addElement:@"code" type:@"Inline" contents:@"Inline" attrIncludes:@"Common" attr:nil];
        code.formatting = YES;

        [self addElement:@"span" type:@"Inline" contents:@"Inline" attrIncludes:@"Common" attr:nil];
        [self addElement:@"br" type:@"Inline" contents:@"Empty" attrIncludes:@"Core" attr:nil];

        [self addElement:@"address" type:@"Block" contents:@"Inline" attrIncludes:@"Common" attr:nil];
        [self addElement:@"blockquote" type:@"Block" contents:@"Optional: Heading | Block | List" attrIncludes:@"Common" attr:@{@"cite":@"URI"}];

        HTMLPurifier_ElementDef* pre = [self addElement:@"pre" type:@"Block" contents:@"Inline" attrIncludes:@"Common" attr:nil];
        pre.excludes = [@{@"img":@YES, @"big":@YES, @"small":@YES, @"object":@YES, @"applet":@YES, @"font":@YES, @"basefont":@YES} mutableCopy];

        [self addElement:@"h1" type:@"Heading" contents:@"Inline" attrIncludes:@"Common" attr:nil];
        [self addElement:@"h2" type:@"Heading" contents:@"Inline" attrIncludes:@"Common" attr:nil];
        [self addElement:@"h3" type:@"Heading" contents:@"Inline" attrIncludes:@"Common" attr:nil];
        [self addElement:@"h4" type:@"Heading" contents:@"Inline" attrIncludes:@"Common" attr:nil];
        [self addElement:@"h5" type:@"Heading" contents:@"Inline" attrIncludes:@"Common" attr:nil];
        [self addElement:@"h6" type:@"Heading" contents:@"Inline" attrIncludes:@"Common" attr:nil];

        // Block Structural -----------------------------------------------
        HTMLPurifier_ElementDef* p = [self addElement:@"p" type:@"Block" contents:@"Inline" attrIncludes:@"Common" attr:nil];
        p.autoclose = [@{@"address":@1, @"blockquote":@2, @"center":@3, @"dir":@4, @"div":@5, @"dl":@6, @"fieldset":@7, @"ol":@8, @"p":@9, @"ul":@10} mutableCopy];
        [self addElement:@"div" type:@"Block" contents:@"Flow" attrIncludes:@"Common" attr:nil];

    }
    return self;
}



- (id)init
{
    return [self initWithConfig:nil];
}

@end
