//
//  HTMLPurifier_AttrDef_Percentage.m
//  HTMLPurifier
//
//  Created by Roman Priebe on 11.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_AttrDef_CSS_Percentage.h"
#import "HTMLPurifier_Config.h"
#import "HTMLPurifier_Context.h"
#import "HTMLPurifier_AttrDef_CSS_Number.h"


@implementation HTMLPurifier_AttrDef_CSS_Percentage
/**
 * @param bool $non_negative Whether to forbid negative values
 */
- (id)initWithNonNegative:(BOOL)nonNegative
{
    self = [super init];
    if (self) {
        numberDef = [[HTMLPurifier_AttrDef_CSS_Number alloc] initWithNonNegative:nonNegative];
    }
    return self;
}

- (id)init
{
    return [self initWithNonNegative:NO];
}

/**
 * @param string $string
 * @param HTMLPurifier_Config $config
 * @param HTMLPurifier_Context $context
 * @return bool|string
 */
- (NSString*)validateWithString:(NSString*)string config:(HTMLPurifier_Config*)config context:(HTMLPurifier_Context*)context
{
    string =[self parseCDATAWithString:string];

    if ([string isEqual:@""]) {
        return nil;
    }
    NSInteger length = string.length;
    if (length == 1) {
        return NO;
    }
    if ([string characterAtIndex:length - 1] != '%') {
        return NO;
    }

    NSString* number = [string substringWithRange:NSMakeRange(0, length-1)];
    number = [self->numberDef validateWithString:number config:config context:context];

    if (!number) {
        return NO;
    }
    return [NSString stringWithFormat:@"%@%%", number];
}

@end
