//
//  HTMLPurifier_HTMLModule_Name.m
//  HTMLPurifier
//
//  Created by Roman Priebe on 18.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_HTMLModule_Name.h"
#import "HTMLPurifier_ElementDef.h"
#import "HTMLPurifier_Config.h"
#import "HTMLPurifier_AttrTransform_NameSync.h"

@implementation HTMLPurifier_HTMLModule_Name

- (id)initWithConfig:(HTMLPurifier_Config*)config
{
    self = [super init];
    if (self)
    {
        self.name = @"Name";

        NSArray* elements = @[@"a", @"applet", @"form", @"frame", @"iframe", @"img", @"map"];

        for(NSString* name in elements)
        {
            HTMLPurifier_ElementDef* element = [self addBlankElement:name];
            element.attr[@"name"] = @"CDATA";
            if(![config get:@"HTML.Attr.Name.UseCDATA"])
            {
                [element.attr_transform_post addObject:[HTMLPurifier_AttrTransform_NameSync new]];
            }
        }
    }
    return self;
}




@end
