//
//  HTMLPurifier_AttrDef_HTML_Color.m
//  HTMLPurifier
//
//  Created by Lukas Neumann on 11.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_AttrDef_HTML_Color.h"
#import "BasicPHP.h"

@implementation HTMLPurifier_AttrDef_HTML_Color

/**
 * @param string $string
 * @param HTMLPurifier_Config $config
 * @param HTMLPurifier_Context $context
 * @return bool|string
 */

-(NSString*)validateWithString:string config:(HTMLPurifier_Config *)config context:(HTMLPurifier_Context *)context
{
    NSMutableArray* colors = [NSMutableArray new];
    if ([colors count] == 0)
    {
        colors = [config get:@"Core.ColorKeywords"];
    }
    
    string = trim(string);
    
    if ([string isEmpty])
    {
        return nil;
    }
    
    NSString* lower =  [string lowercaseString];
    if ([colors containsObject:lower])
    {
        return lower;
    }
    
    NSString* hex = [NSString new];
    
    if ([string[0] isEqual:@"#"])
    {
      hex = substr(string, 1);
    }
    else
    {
      hex = string;
    }
    
    NSInteger length = [hex length];
    
    if (length != 3 && length != 6)
    {
        return nil;
    }
    if (!ctype_xdigit(hex))
    {
        return nil;
    }
    if (length == 3)
    {
        hex = [NSString stringWithFormat:@"%hu%hu%hu%hu%hu%hu",[hex characterAtIndex:0],[hex characterAtIndex:0],[hex characterAtIndex:1],[hex characterAtIndex:1],[hex characterAtIndex:2],[hex characterAtIndex:2]];
    }
    return [@"#" stringByAppendingString:hex];
}

@end
