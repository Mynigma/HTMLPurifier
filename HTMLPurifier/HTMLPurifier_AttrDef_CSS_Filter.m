//
//  HTMLPurifier_AttrDef_CSS_Filter.m
//  HTMLPurifier
//
//  Created by Lukas Neumann on 15.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_AttrDef_CSS_Filter.h"
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
    NSInteger function_length = strcspn(value, @"(");
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
    NSString* parameters = [value substringWithRange:NSMakeRange(cursor,parameters_length)];
    NSArray* params = explode(@",", parameters);
    NSMutableArray* ret_params = [NSMutableArray new];
    NSMutableArray* lookup = [NSMutableArray new];
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
        value = this->intValidator->validate(value, config, context);
        if (value === false) {
            continue;
        }
        int = (int)value;
        if (int > 100) {
            value = '100';
        }
        if (int < 0) {
            value = '0';
        }
        ret_params[] = "key=value";
        lookup[key] = true;
    }
    ret_parameters = implode(',', ret_params);
    ret_function = "function(ret_parameters)";
    return ret_function;
}

@end
