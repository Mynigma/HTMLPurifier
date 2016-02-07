//
//   HTMLPurifier_AttrDef_CSS_Color.m
//   HTMLPurifier
//
//  Created by Roman Priebe on 11.01.14.


#import "HTMLPurifier_AttrDef_CSS_Color.h"
#import "BasicPHP.h"
#import "HTMLPurifier_Config.h"

/**
 * Validates Color as defined by CSS.
 */
@implementation HTMLPurifier_AttrDef_CSS_Color




- (BOOL)isEqual:(id)other
{
    if (other == self)
        return YES;
    
    if (![super isEqual:other])
        return NO;
    
    if(![other isKindOfClass:[HTMLPurifier_AttrDef_CSS_Color class]])
        return NO;
    
    return YES;
}

    /**
     * @param string $color
     * @param HTMLPurifier_Config $config
     * @param HTMLPurifier_Context $context
     * @return bool|string
     */
- (NSString*)validateWithString:(NSString *)string config:(HTMLPurifier_Config *)config context:(HTMLPurifier_Context *)context
    {
        NSDictionary* colors = (NSDictionary*)[config get:@"Core.ColorKeywords"];

        NSString* color = trim(string);
        if ([color isEqual:@""]) {
            return nil;
        }

        NSString* lower = [color lowercaseString];
        if ([colors objectForKey:lower])
        {
            return [colors objectForKey:lower];
        }

        if (strpos(color, @"rgb(") != NSNotFound) {
            // rgb literal handling
            NSInteger length = color.length;
            if (strpos(color, @")") != length - 1) {
                return nil;
            }
            NSString* triad = [color substringWithRange:NSMakeRange(4, length - 4 -1)];
            NSArray* parts = explode(@",", triad);
            if (parts.count != 3) {
                return nil;
            }
            NSString* type = nil; // to ensure that they're all the same type
            NSMutableArray* new_parts = [NSMutableArray new];
            for(NSString* part in parts)
            {
                NSString* newPart = trim(part);
                if ([newPart isEqual:@""]) {
                    return nil;
                }
                NSInteger length = newPart.length;
                if ([newPart characterAtIndex:length - 1] == '%')
                {
                    // handle percents
                    if (!type) {
                        type = @"percentage";
                    } else if (![type isEqual:@"percentage"]) {
                        return nil;
                    }
                    NSString* num = [newPart substringWithRange:NSMakeRange(0, length-1)];
                    float floatNum = num.floatValue;
                    if (floatNum < 0) {
                        floatNum = 0;
                    }
                    if (floatNum > 100) {
                        floatNum = 100;
                    }
                    [new_parts addObject:[NSString stringWithFormat:@"%d%%", (int)floatNum]];
                } else {
                    // handle integers
                    if (!type) {
                        type = @"integer";
                    } else if (![type isEqual:@"integer"]) {
                        return nil;
                    }
                    NSString* num = newPart;//[newPart substringWithRange:NSMakeRange(0, length-1)];
                    float floatNum = num.floatValue;
                    if (floatNum < 0) {
                        floatNum = 0;
                    }
                    if (floatNum > 255) {
                        floatNum = 255;
                    }
                    [new_parts addObject:[NSString stringWithFormat:@"%d", (int)floatNum]];
                }
            }
            NSString* new_triad = implode(@",", new_parts);
            color = [NSString stringWithFormat:@"rgb(%@)", new_triad];
        } else {
            NSString* hex;
            // hexadecimal handling
            if ([color characterAtIndex:0] == '#')
            {
                hex = substr(color, 1);
            } else {
                hex = color;
                color = [NSString stringWithFormat:@"#%@",[color copy]];
            }
            NSInteger length = hex.length;
            if (length != 3 && length != 6) {
                return nil;
            }
            if (!ctype_xdigit(hex)) {
                return nil;
            }
        }
        return color;
    }


@end
