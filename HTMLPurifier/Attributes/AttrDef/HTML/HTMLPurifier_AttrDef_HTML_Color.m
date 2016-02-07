//
//   HTMLPurifier_AttrDef_HTML_Color.m
//   HTMLPurifier
//
//  Created by Lukas Neumann on 11.01.14.


#import "HTMLPurifier_AttrDef_HTML_Color.h"
#import "BasicPHP.h"

@implementation HTMLPurifier_AttrDef_HTML_Color


- (BOOL)isEqual:(id)other
{
    if (other == self)
        return YES;
    
    if (![super isEqual:other])
        return NO;
    
    if(![other isKindOfClass:[HTMLPurifier_AttrDef_HTML_Color class]])
        return NO;
    
    return YES;
}


/**
 * @param string $string
 * @param HTMLPurifier_Config $config
 * @param HTMLPurifier_Context $context
 * @return bool|string
 */
-(NSString*)validateWithString:string config:(HTMLPurifier_Config *)config context:(HTMLPurifier_Context *)context
{
    NSDictionary* colors = [NSDictionary new];
    if ([colors count] == 0)
    {
        colors = (NSDictionary*)[config get:@"Core.ColorKeywords"];
    }
    
    string = trim(string);
    
    if ([string length] == 0)
    {
        return nil;
    }
    
    NSString* lower =  [string lowercaseString];
    NSString* known_color = [colors objectForKey:lower];
    if (known_color)
    {
        return known_color;
    }
    
    NSString* hex;
    
    if ([string characterAtIndex:0] == '#')
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
        hex = [NSString stringWithFormat:@"%c%c%c%c%c%c",[hex.copy characterAtIndex:0],[hex.copy characterAtIndex:0],[hex.copy characterAtIndex:1],[hex.copy characterAtIndex:1],[hex.copy characterAtIndex:2],[hex.copy characterAtIndex:2]];
    }
    return [@"#" stringByAppendingString:hex];
}

@end
