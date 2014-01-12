//
//  HTMLPurifier_AttrDef_Switch.m
//  HTMLPurifier
//
//  Created by Roman Priebe on 11.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_AttrDef_Switch.h"
#import "HTMLPurifier_Token.h"

/**
 * Decorator that, depending on a token, switches between two definitions.
 */
@implementation HTMLPurifier_AttrDef_Switch


/**
 * @param string $tag Tag name to switch upon
 * @param HTMLPurifier_AttrDef $with_tag Call if token matches tag
 * @param HTMLPurifier_AttrDef $without_tag Call if token doesn't match, or there is no token
 */
- (id)initWithTag:(NSString*)newTag withTag:(HTMLPurifier_AttrDef*)newWithTag  withoutTag:(HTMLPurifier_AttrDef*)newWithoutTag
{
    self = [super init];
    if (self) {
        tag = newTag;
        withTag = newWithTag;
        withoutTag = newWithoutTag;
    }
    return self;
}

/**
 * @param string $string
 * @param HTMLPurifier_Config $config
 * @param HTMLPurifier_Context $context
 * @return bool|string
 */
- (NSString*)validateWithString:(NSString *)string config:(HTMLPurifier_Config *)config context:(HTMLPurifier_Context *)context
{
    NSObject* token = [context getWithName:@"CurrentToken" ignoreError:YES];
    if (!token || ![[token name] isEqual:self.tag]) {
        return [withoutTag validateWithString:string config:config context:context];
    } else {
        return [withTag validateWithString:string config:config context:context];
    }
}

@end
