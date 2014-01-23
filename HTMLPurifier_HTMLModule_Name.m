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
            if(![(NSNumber*)[config get:@"HTML.Attr.Name.UseCDATA"] boolValue])
            {
                NSString* newKey = [NSString stringWithFormat:@"%ld", element.attr_transform_post.count];
                [element.attr_transform_post setObject:[HTMLPurifier_AttrTransform_NameSync new] forKey:newKey];
            }
        }
    }
    return self;
}

- (id)init
{
    return [self initWithConfig:nil];
}



@end
