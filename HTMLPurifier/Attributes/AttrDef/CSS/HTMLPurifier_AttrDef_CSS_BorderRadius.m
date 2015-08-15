//
//  HTMLPurifier_AttrDef_CSS_BorderRadius.m
//  HTMLPurifier
//
//  Created by Lukas Neumann on 15.08.15.
//  Copyright (c) 2015 Mynigma. All rights reserved.
//

#import "HTMLPurifier_AttrDef_CSS_BorderRadius.h"
#import "HTMLPurifier_AttrDef_Enum.h"
#import "HTMLPurifier_AttrDef_CSS_Composite.h"
#import "HTMLPurifier_AttrDef_CSS_Length.h"
#import "HTMLPurifier_AttrDef_CSS_Percentage.h"
#import "HTMLPurifier_AttrDef_CSS_Multiple.h"
#import "BasicPHP.h"


@implementation HTMLPurifier_AttrDef_CSS_BorderRadius

/**
 * @param string $string
 * @param HTMLPurifier_Config $config
 * @param HTMLPurifier_Context $context
 * @return bool|string
 */
- (NSString*)validateWithString:(NSString*)string config:(HTMLPurifier_Config*)config context:(HTMLPurifier_Context*)context
{
    string = [self parseCDATAWithString:string];
    
    if ([string isEqual:@"initial"]) {
        return @"initial";
    }
        
    NSArray* bits = explode(@"/",string);
    
    if (bits.count == 0) {
        return nil;
    }
    
    HTMLPurifier_AttrDef_CSS_Composite* validate = [[HTMLPurifier_AttrDef_CSS_Composite alloc] initWithDefs:@[[[HTMLPurifier_AttrDef_CSS_Multiple alloc] initWithSingle:[HTMLPurifier_AttrDef_CSS_Length new] max:4],[[HTMLPurifier_AttrDef_CSS_Multiple alloc] initWithSingle:[HTMLPurifier_AttrDef_CSS_Percentage new] max:4]]];
    
    if (bits.count == 1) {
        return [validate validateWithString:bits[0] config:config context:context];
    }
    
    if (bits.count == 2) {
        NSString* part1 = [validate validateWithString:bits[0] config:config context:context];
        NSString* part2 = [validate validateWithString:bits[1] config:config context:context];
        
        if (part1 != nil && part2 != nil) {
            return [NSString stringWithFormat:@"%@ / %@",part1,part2];
        }
    }
    
    return nil;
}


@end
