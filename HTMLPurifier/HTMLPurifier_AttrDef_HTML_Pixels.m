//
//  HTMLPurifier_AttrDef_HTML_Pixels.m
//  HTMLPurifier
//
//  Created by Lukas Neumann on 11.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//


/**
 * Validates an integer representation of pixels according to the HTML spec.
 */
#import "HTMLPurifier_AttrDef_HTML_Pixels.h"
#import "BasicPHP.h"

@implementation HTMLPurifier_AttrDef_HTML_Pixels

@synthesize max;

/**
 * @param int $max
 */
-(id) initWithMax:(NSNumber*)newMax
{
    self = [super init];
    if (newMax)
    {
        max = newMax;
    }
    else
    {
        max = nil;
    }
    return self;
}

/**
 * @param string $string
 * @param HTMLPurifier_Config $config
 * @param HTMLPurifier_Context $context
 * @return bool|string
 */
-(NSString*) validateWithString:(NSString*)string config:(HTMLPurifier_Config *)config context:(HTMLPurifier_Context *)context
{
    string = trim(string);
    if ([string isEqual:@"0"])
    {
        return string;
    }
    if ([string isEqual:@""])
    {
        return nil;
    }
    NSUInteger length = string.length;
    
    if ([substr(string,length - 2) isEqual:@"px"])
    {
        string = [string substringToIndex:(length - 2)];
    }
    if ([string isKindOfClass:[NSNumber class]])
    {
        return nil;
    }
    NSNumber* num = @([string intValue]);
    
    if (num < 0)
    {
        return @"0";
    }
    
    // upper-bound value, extremely high values can
    // crash operating systems, see <http://ha.ckers.org/imagecrash.html>
    // WARNING, above link WILL crash you if you're using Windows
    
    if (max && (num > max))
    {
        return [NSString stringWithFormat:@"%@",max];
    }
    return [NSString stringWithFormat:@"%@",num];
}

/**
 * @param string $string
 * @return HTMLPurifier_AttrDef
 */
-(HTMLPurifier_AttrDef*) makeWithString:(NSString*)string
{
    if ([string isEqual:@""])
    {
        max = nil;
    } else {
        max = @([string intValue]);
    }
    
    HTMLPurifier_AttrDef_HTML_Pixels* class = [HTMLPurifier_AttrDef_HTML_Pixels alloc];
    
    return [class initWithMax:max];
}

@end
