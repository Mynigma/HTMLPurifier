//
//   HTMLPurifier_AttrTransform_Nofollow.m
//   HTMLPurifier
//
//  Created by Lukas Neumann on 23.01.14.


#import "HTMLPurifier_AttrTransform_Nofollow.h"
#import "HTMLPurifier_URIParser.h"
#import "HTMLPurifier_URI.h"
#import "HTMLPurifier_URIScheme.h"
#import "BasicPHP.h"

/**
 * Adds rel="nofollow" to all outbound links.  This transform is
 * only attached if Attr.Nofollow is TRUE.
 */
@implementation HTMLPurifier_AttrTransform_Nofollow

/**
 * @type HTMLPurifier_URIParser
 */
@synthesize parser;

-(id) init
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
    
    NSMutableDictionary* attr_m = [attr mutableCopy];
    
    if ([scheme browsable] && ![url isLocal:config context:context])
    {
        if (attr[@"rel"])
        {
            NSMutableArray* rels = [explode(@" ", attr[@"rel"]) mutableCopy];
            if (! [rels containsObject:@"nofollow"])
            {
                [rels addObject:@"nofollow"];
            }
            [attr_m setObject:implode(@" ",rels) forKey:@"rel"];
        }
        else
        {
            [attr_m setObject:@"nofollow" forKey:@"rel"];
            [sortedKeys addObject:@"rel"];
        }
    }
    return attr_m;
}


@end
