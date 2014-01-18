//
//  HTMLPurifier_AttrTransform_ImgRequired.m
//  HTMLPurifier
//
//  Created by Roman Priebe on 18.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_AttrTransform_ImgRequired.h"
#import "HTMLPurifier_Context.h"
#import "HTMLPurifier_Config.h"

// must be called POST validation

/**
 * Transform that supplies default values for the src and alt attributes
 * in img tags, as well as prevents the img tag from being removed
 * because of a missing alt tag. This needs to be registered as both
 * a pre and post attribute transform.
 */
@implementation HTMLPurifier_AttrTransform_ImgRequired



/**
     * @param array $attr
     * @param HTMLPurifier_Config $config
     * @param HTMLPurifier_Context $context
     * @return array
     */
- (NSDictionary*)transform:(NSDictionary*)passedAttr config:(HTMLPurifier_Config*)config context:(HTMLPurifier_Context*)context
    {
        BOOL src = YES;
        NSMutableDictionary* attr = [passedAttr mutableCopy];
        if (!attr[@"src"])
        {
            if ([config get:@"Core.RemoveInvalidImg"])
            {
                return attr;
            }
            attr[@"src"] = (NSString*)[config get:@"Attr.DefaultInvalidImage"];
            src = NO;
        }

        if (!attr[@"alt"])
        {
            if (src)
            {
                NSString* alt = (NSString*)[config get:@"Attr.DefaultImageAlt"];
                if (!alt)
                {
                    // truncate if the alt is too long
                    NSString* lastPathComponent = [(NSString*)attr[@"src"] lastPathComponent];
                    attr[@"alt"] = [lastPathComponent substringWithRange:NSMakeRange(0, 40)];
                }
                else
                {
                    attr[@"alt"] = alt;
                }
            } else {
                attr[@"alt"] = (NSString*)[config get:@"Attr.DefaultInvalidImageAlt"];
            }
        }
        return attr;
    }




@end
