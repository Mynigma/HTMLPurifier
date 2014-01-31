//
//  HTMLPurifier_AttrTransform_SafeEmbed.m
//  HTMLPurifier
//
//  Created by Lukas Neumann on 23.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_AttrTransform_SafeEmbed.h"

@implementation HTMLPurifier_AttrTransform_SafeEmbed

/**
 * @type string
 */
@synthesize name; // = "SafeEmbed";


-(id) init
{
    self = [super init];
    name = @"SafeEmbed";
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
    NSMutableDictionary* attr_m = [attr mutableCopy];
    
    if (![sortedKeys containsObject:@"allowscriptaccess"])
        [sortedKeys addObject:@"allowscriptaccess"];
    [attr_m setObject:@"never" forKey:@"allowscriptaccess"];
    
    if (![sortedKeys containsObject:@"allownetworking"])
        [sortedKeys addObject:@"allownetworking"];
    [attr_m setObject:@"internal" forKey:@"allownetworking"];
    
    if (![sortedKeys containsObject:@"type"])
        [sortedKeys addObject:@"type"];
    [attr_m setObject:@"application/x-shockwave-flash" forKey:@"type"];

    return attr_m;
}

@end
