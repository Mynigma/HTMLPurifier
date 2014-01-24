//
//  HTMLPurifier_AttrTransform_NameSync.m
//  HTMLPurifier
//
//  Created by Roman Priebe on 18.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_AttrTransform_NameSync.h"
#import "HTMLPurifier_AttrDef_HTML_ID.h"


/**
 * Post-transform that performs validation to the name attribute; if
 * it is present with an equivalent id attribute, it is passed through;
 * otherwise validation is performed.
 */
@implementation HTMLPurifier_AttrTransform_NameSync

@synthesize idDef;

-(id) init
{
    self = [super init];
    idDef = [HTMLPurifier_AttrDef_HTML_ID new];
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
    if (!attr[@"name"])
    {
        return attr;
    }
    
    NSString* name = attr[@"name"];
    
    if (attr[@"id"] && [attr[@"id"] isEqual:name])
    {
        return attr;
    }
    
    NSString* result = [idDef validateWithString:name config:config context:context];
    
    NSMutableDictionary* attr_m = [attr mutableCopy];
    
    if (!result)
    {
        [attr_m removeObjectForKey:@"name"];
    }
    else
    {
        [attr_m setObject:result forKey:@"name"];
    }
    return attr_m;
}

@end
