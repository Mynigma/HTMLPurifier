//
//  HTMLPurifier_AttrDef_HTML_MultiLength.m
//  HTMLPurifier
//
//  Created by Lukas Neumann on 12.01.14.


#import "HTMLPurifier_AttrDef_HTML_MultiLength.h"
#import "BasicPHP.h"

@implementation HTMLPurifier_AttrDef_HTML_MultiLength

/**
 * @param string $string
 * @param HTMLPurifier_Config $config
 * @param HTMLPurifier_Context $context
 * @return bool|string
 */
-(NSString*) validateWithString:(NSString *)string config:(HTMLPurifier_Config *)config context:(HTMLPurifier_Context *)context
{
    string = trim(string);
    if ([string isEqual:@""])
    {
        return nil;
    }
    
    NSString* parent_result = [super validateWithString:string config:config context:context];
    if (parent_result)
    {
        return parent_result;
    }
    
    NSUInteger length = [string length];
    unichar last_char = [string characterAtIndex:length - 1];
    
    if (last_char != '*') {
        return nil;
    }
    
    //should be safe
    NSString* sub = [string substringToIndex:length - 1];
    
    if ([sub isEqual:@""])
    {
        return @"*";
    }
    if (!stringIsNumeric(sub))
    {
        return nil;
    }
    
    int subnum = [sub intValue];
    if (subnum < 0) {
        return nil;
    }
    if (subnum == 0) {
        return @"0";
    }
    if (subnum == 1) {
        return @"*";
    }
    return [NSString stringWithFormat:@"%d%@",subnum,@"*"];
}

@end
