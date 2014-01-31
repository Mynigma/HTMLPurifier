//
//  HTMLPurifier_AttrDef_Number.m
//  HTMLPurifier
//
//  Created by Roman Priebe on 11.01.14.


#import "HTMLPurifier_AttrDef_CSS_Number.h"
#import "BasicPHP.h"
#import "HTMLPurifier_Config.h"
#import "HTMLPurifier_Context.h"

@implementation HTMLPurifier_AttrDef_CSS_Number

- (id)init
{
    return [self initWithNonNegative:NO];
}

- (id)initWithNonNegative:(BOOL)newNonNegative
{
    self = [super init];
    if (self) {
        nonNegative = newNonNegative;
    }
    return self;
}
    /**
     * @param string $number
     * @param HTMLPurifier_Config $config
     * @param HTMLPurifier_Context $context
     * @return string|bool
     * @warning Some contexts do not pass $config, $context. These
     *          variables should not be used without checking HTMLPurifier_Length
     */
- (NSString*)validateWithString:(NSString *)string config:(HTMLPurifier_Config *)config context:(HTMLPurifier_Context *)context
    {
        string = [self parseCDATAWithString:string];

        if ([string isEqualTo:@""]) {
            return nil;
        }
        if ([string isEqualTo:@"0"]) {
            return @"0";
        }

        NSMutableString* sign = [@"" mutableCopy];
        switch ([string characterAtIndex:0])
        {
            case '-':
                if (self->nonNegative) {
                    return nil;
                }
                sign = [@"-" mutableCopy];
            case '+':
                string = substr(string, 1);
        }

        if (ctype_digit(string)) {
            string = ltrim_2(string, @"0");
            return string ? [sign stringByAppendingString:string] : @"0";
        }

        // Period is the only non-numeric character allowed
        if (strpos(string, @".") == NSNotFound) {
            return nil;
        }

        NSArray* components = explode(@".", string);

        NSString* left = @"";
        NSString* right = @"";

        if(components.count>0)
        {
            left = components[0];
            if(components.count>1)
            {
                NSArray* subArray = [components subarrayWithRange:NSMakeRange(1, components.count-1)];
                right = implode(@".", subArray);
            }
        }

        if ([left isEqualTo:@""] && [right isEqualTo:@""]) {
            return nil;
        }
        if (![left isEqualTo:@""] && !ctype_digit(left)) {
            return nil;
        }

        left = ltrim_2(left, @"0");
        right = rtrim_2(right, @"0");

        if ([right isEqualTo:@""])
        {
            return left ? [sign stringByAppendingString:string] : @"0";
        } else if (!ctype_digit(right)) {
            return nil;
        }
        return [NSString stringWithFormat:@"%@%@.%@", sign, left, right];
    }


@end
