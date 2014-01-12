//
//  HTMLPurifier_AttrDef_HTML_Length.m
//  HTMLPurifier
//
//  Created by Lukas Neumann on 12.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_AttrDef_HTML_Length.h"
#import "BasicPHP.h"

@implementation HTMLPurifier_AttrDef_HTML_Length

/**
 * @param string $string
 * @param HTMLPurifier_Config $config
 * @param HTMLPurifier_Context $context
 * @return bool|string
 */
-(NSString*) validateWithString:(NSString *)string config:(HTMLPurifier_Config *)config context:(HTMLPurifier_Context *)context
{
    string = trim(string);
    if ([string  isEqual:@""])
    {
        return nil;
    }
    
    NSString* parent_result = [super validateWithString:string config:config context:context];
    if (parent_result)
    {
        return parent_result;
    }
    
    NSUInteger length = [string length];
    unichar last_char = [string characterAtIndex:length-1];
    
    if (last_char != '%')
    {
        return nil;
    }
    
    NSString* points =  [string substringToIndex:length-1];
    
    if (!is_numeric(points))
    {
        return nil;
    }
    
    int num = [points intValue];
    
    if (num < 0)
    {
        return @"0%";
    }
    if (num > 100)
    {
        return @"100%";
    }
    return [NSString stringWithFormat:@"%d%@",num,@"%"];
}

@end
