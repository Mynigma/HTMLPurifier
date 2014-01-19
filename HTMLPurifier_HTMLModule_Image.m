//
//  HTMLPurifier_HTMLModule_Image.m
//  HTMLPurifier
//
//  Created by Roman Priebe on 18.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_HTMLModule_Image.h"
#import "HTMLPurifier_Config.h"
#import "HTMLPurifier_ElementDef.h"
#import "HTMLPurifier_AttrDef_URI.h"
#import "HTMLPurifier_AttrTransform_ImgRequired.h"

@implementation HTMLPurifier_HTMLModule_Image


- (id)initWithConfig:(HTMLPurifier_Config*)config
{
    self = [super init];
    if (self) {
        self.name = @"Image";
        NSNumber* max = (NSNumber*)[config get:@"HTML.MaxImgLength"];
        HTMLPurifier_ElementDef* img = [self addElement:@"img" type:@"Inline" contents:@"Empty" attrIncludes:@"Common" attr:@{@"alt*":@"Text", @"height":[NSString stringWithFormat:@"Pixels#%@", max], @"width":[NSString stringWithFormat:@"Pixels#%@", max], @"longdesc":@"URI", @"src*":[[HTMLPurifier_AttrDef_URI alloc] initWithNumber:@YES]}];
        HTMLPurifier_AttrTransform_ImgRequired* transform = [HTMLPurifier_AttrTransform_ImgRequired new];
        [img.attr_transform_post setObject:transform forKey:@(img.attr_transform_post.allKeys.count)];
        [img.attr_transform_pre setObject:transform forKey:@(img.attr_transform_pre.allKeys.count)];
    }
    return self;
}


@end
