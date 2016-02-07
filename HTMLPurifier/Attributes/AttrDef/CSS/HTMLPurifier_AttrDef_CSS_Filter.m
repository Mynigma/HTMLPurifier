//
//   HTMLPurifier_AttrDef_CSS_Filter.m
//   HTMLPurifier
//
//  Created by Lukas Neumann on 15.01.14.


#import "HTMLPurifier_AttrDef_CSS_Filter.h"
#import "HTMLPurifier_AttrDef_Integer.h"
#import "BasicPHP.h"

/**
 * Microsoft's proprietary filter: CSS property
 * @note Currently supports the alpha filter. In the future, this will
 *       probably need an extensible framework
 */

@implementation HTMLPurifier_AttrDef_CSS_Filter

/**
 * @type HTMLPurifier_AttrDef_Integer
 */
@synthesize  intValidator;

-(id) init
{
    self = [super init];
    intValidator = [HTMLPurifier_AttrDef_Integer new];
    return self;
}


- (instancetype)initWithCoder:(NSCoder*)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        intValidator = [coder decodeObjectForKey:@"intValidator"];
    }
    return self;
}



- (void)encodeWithCoder:(NSCoder*)encoder
{
    [super encodeWithCoder:encoder];
    [encoder encodeObject:intValidator forKey:@"intValidator"];
}


- (BOOL)isEqual:(id)other
{
    if (other == self) {
        return YES;
    } else if (![super isEqual:other]) {
        return NO;
    } else if(![other isKindOfClass:[HTMLPurifier_AttrDef_CSS_Filter class]])
    {
        return NO;
    }
    else
    {
        return (!self.intValidator && ![(HTMLPurifier_AttrDef_CSS_Filter*)other intValidator]) || [self.intValidator isEqual:[(HTMLPurifier_AttrDef_CSS_Filter*)other intValidator]];
    }
}

- (NSUInteger)hash
{
    return [intValidator hash] ^ [super hash];
}








/**
 * @param string value
 * @param HTMLPurifier_Config config
 * @param HTMLPurifier_Context context
 * @return bool|string
 */
- (NSString*) validateWithString:(NSString *)value config:(HTMLPurifier_Config *)config context:(HTMLPurifier_Context *)context
{
    value = [super parseCDATAWithString:value];
    if ([value isEqual:@"none"])
    {
        return value;
    }
    // if we looped this we could support multiple filters
    NSInteger function_length = strcspn_2(value, @"(");
    // strcspn is safe!!
    NSString* function = trim([value substringToIndex:function_length]);
    if (![function isEqual:@"alpha"] &&
        ![function isEqual:@"Alpha"] &&
        ![function isEqual:@"progid:DXImageTransform.Microsoft.Alpha"]
        )
    {
        return nil;
    }
    NSInteger cursor = function_length + 1;
    NSInteger parameters_length = strcspn_3(value, @")", cursor);
    if (parameters_length<=0)
        return nil;
    NSString* parameters = [value substringWithRange:NSMakeRange(cursor,parameters_length)];
    NSArray* params = explode(@",", parameters);
    NSMutableArray* ret_params = [NSMutableArray new];
    NSMutableDictionary* lookup = [NSMutableDictionary new];
    
    for (NSString* param in params)
    {
        // not clean for list(key,value) = explode(@"=",param)
        NSArray* temp = explode(@"=", param);
        NSString* key = temp[0];
        NSString* value = temp[1];
        
        key = trim(key);
        value = trim(value);
        
        if (lookup[key])
        {
            continue;
        }
        if (![key isEqual:@"opacity"]) {
            continue;
        }
        value = [intValidator validateWithString:value config:config context:context];
        if (!value) {
            continue;
        }
        
        NSInteger num = value.integerValue;
        
        if (num > 100) {
            value = @"100";
        }
        if (num < 0) {
            value = @"0";
        }
        [ret_params addObject:[NSString stringWithFormat:@"%@=%@",key,value]];
        lookup[key] = @YES;
    }
    
    NSString* ret_parameters = implode(@",",ret_params);
    NSString* ret_function = [NSString stringWithFormat:@"%@(%@)",function,ret_parameters];
    
    return ret_function;
}

@end
