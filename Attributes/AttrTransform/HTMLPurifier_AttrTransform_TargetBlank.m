//
//   HTMLPurifier_AttrTransform_TargetBlank.m
//   HTMLPurifier
//
//  Created by Lukas Neumann on 23.01.14.


#import "HTMLPurifier_AttrTransform_TargetBlank.h"
#import "HTMLPurifier_URIParser.h"
#import "HTMLPurifier_URI.h"
#import "HTMLPurifier_URIScheme.h"

/**
 * Adds target="blank" to all outbound links.  This transform is
 * only attached if Attr.TargetBlank is TRUE.  This works regardless
 * of whether or not Attr.AllowedFrameTargets
 */
@implementation HTMLPurifier_AttrTransform_TargetBlank

/**
 * @type HTMLPurifier_URIParser
 */
@synthesize parser;

- (id)init
{
    self = [super init];
    parser = [HTMLPurifier_URIParser new];
    return self;
}

/**
 * @param array $attr
 * @param HTMLPurifier_Config $config
 * @param HTMLPurifier_Context $context
 * @return array
 */
- (NSDictionary*)transform:(NSDictionary*)attr sortedKeys:(NSMutableArray*)sortedKeys config:(HTMLPurifier_Config*)config context:(HTMLPurifier_Context*)context
{
    if (!attr[@"href"])
    {
        return attr;
    }
    
    // XXX Kind of inefficient
    HTMLPurifier_URI* url = [parser parse:attr[@"href"]];
    HTMLPurifier_URIScheme* scheme = [url getSchemeObj:config context:context];
    
    if ([scheme browsable] && ![url isBenign:config context:context])
    {
        NSMutableDictionary* attr_m = [attr mutableCopy];
        [attr_m setObject:@"_blank" forKey:@"target"];
        if (![sortedKeys containsObject:@"target"])
            [sortedKeys addObject:@"target"];
        return attr_m;
    }
    return attr;
}

@end
