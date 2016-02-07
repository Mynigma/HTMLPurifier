//
//   HTMLPurifier_AttrDef_Percentage.m
//   HTMLPurifier
//
//  Created by Roman Priebe on 11.01.14.


#import "HTMLPurifier_AttrDef_CSS_Percentage.h"
#import "HTMLPurifier_Config.h"
#import "HTMLPurifier_Context.h"
#import "HTMLPurifier_AttrDef_CSS_Number.h"


@implementation HTMLPurifier_AttrDef_CSS_Percentage
/**
 * @param bool $non_negative Whether to forbid negative values
 */
- (id)initWithNonNegative:(NSNumber*)nonNegative
{
    self = [super init];
    if (self) {
        _numberDef = [[HTMLPurifier_AttrDef_CSS_Number alloc] initWithNonNegative:nonNegative];
    }
    return self;
}

- (id)init
{
    return [self initWithNonNegative:@NO];
}


- (instancetype)initWithCoder:(NSCoder*)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        _numberDef = [coder decodeObjectForKey:@"numberDef"];
    }
    return self;
}



- (void)encodeWithCoder:(NSCoder*)encoder
{
    [super encodeWithCoder:encoder];
    [encoder encodeObject:_numberDef forKey:@"numberDef"];
}


- (BOOL)isEqual:(id)other
{
    if (other == self) {
        return YES;
    } else if (![super isEqual:other]) {
        return NO;
    } else if(![other isKindOfClass:[HTMLPurifier_AttrDef_CSS_Percentage class]])
    {
        return NO;
    }
    else
    {
        return (!self.numberDef && ![(HTMLPurifier_AttrDef_CSS_Percentage*)other numberDef]) || [self.numberDef isEqual:[(HTMLPurifier_AttrDef_CSS_Percentage*)other numberDef]];
    }
}

- (NSUInteger)hash
{
    return [_numberDef hash] ^ [super hash];
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
        return nil;
    }
    if ([string characterAtIndex:length - 1] != '%') {
        return nil;
    }

    NSString* number = [string substringWithRange:NSMakeRange(0, length-1)];
    number = [self.numberDef validateWithString:number config:config context:context];

    if (!number) {
        return nil;
    }
    return [NSString stringWithFormat:@"%@%%", number];
}

@end
