//
//  HTMLPurifier_TagTransform.m
//  HTMLPurifier
//
//  Created by Roman Priebe on 16.01.14.


#import "HTMLPurifier_TagTransform.h"

@implementation HTMLPurifier_TagTransform

- (HTMLPurifier_Token_Tag*)transform:(HTMLPurifier_Token_Tag*)tag config:(HTMLPurifier_Config*)config context:(HTMLPurifier_Context*)context
{
    return nil;
}

/**
 * Prepends CSS properties to the style attribute, creating the
 * attribute if it doesn't exist.
 * @warning Copied over from AttrTransform, be sure to keep in sync
 * @param array $attr Attribute array to process (passed by reference)
 * @param string $css CSS to prepend
 */
- (void)prependCSS:(NSMutableDictionary*)attr css:(NSString*)css
{
    attr[@"style"] = attr[@"style"] ? attr[@"style"] : @"";
    attr[@"style"] = [NSString stringWithFormat:@"css%@", attr[@"style"]];
}


@end
