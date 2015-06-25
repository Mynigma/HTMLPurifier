//
//   HTMLPurifier_AttrTransform_ImgRequired.m
//   HTMLPurifier
//
//  Created by Roman Priebe on 18.01.14.


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
- (NSDictionary*)transform:(NSDictionary*)passedAttr sortedKeys:(NSMutableArray*)sortedKeys config:(HTMLPurifier_Config*)config context:(HTMLPurifier_Context*)context
    {
        BOOL src = YES;
        NSMutableDictionary* attr = [passedAttr mutableCopy];
        if (!attr[@"src"])
        {
            if ([[config get:@"Core.RemoveInvalidImg"] isEqual:@YES])
            {
                return attr;
            }
            if ([config get:@"Attr.DefaultInvalidImage"])
                attr[@"src"] = (NSString*)[config get:@"Attr.DefaultInvalidImage"];
            else
                attr[@"src"] = @"";
            if (![sortedKeys containsObject:@"src"])
                [sortedKeys addObject:@"src"];
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
                    attr[@"alt"] = [lastPathComponent substringWithRange:NSMakeRange(0, MIN(40, lastPathComponent.length))];
                    if (![sortedKeys containsObject:@"alt"])
                        [sortedKeys addObject:@"alt"];
                }
                else
                {
                    attr[@"alt"] = alt;
                    if (![sortedKeys containsObject:@"alt"])
                        [sortedKeys addObject:@"alt"];
                }
            }
            else {
                if ([config get:@"Attr.DefaultInvalidImageAlt"])
                    attr[@"alt"] = (NSString*)[config get:@"Attr.DefaultInvalidImageAlt"];
                else
                    attr[@"alt"] = @"";
                if (![sortedKeys containsObject:@"alt"])
                    [sortedKeys addObject:@"alt"];
            }
        }
        return attr;
    }




@end
