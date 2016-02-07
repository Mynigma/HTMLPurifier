//
//  HTMLPurifier_AttrDef_CSS_Shape.m
//  HTMLPurifier
//
//  Created by Lukas Neumann on 13.08.15.
//  Copyright (c) 2015 Mynigma. All rights reserved.
//

#import "HTMLPurifier_AttrDef_CSS_Shape.h"
#import "HTMLPurifier_CSSDefinition.h"
#import "BasicPHP.h"
#import "HTMLPurifier_AttrDef_CSS_Composite.h"
#import "HTMLPurifier_AttrDef_CSS_Length.h"
#import "HTMLPurifier_AttrDef_Enum.h"

@implementation HTMLPurifier_AttrDef_CSS_Shape



- (BOOL)isEqual:(id)other
{
    if (other == self)
        return YES;
    
    if (![super isEqual:other])
        return NO;
    
    if(![other isKindOfClass:[HTMLPurifier_AttrDef_CSS_Shape class]])
        return NO;
    
    return YES;
}





/**
 * Valid: rect(25px,5em,auto,7px)
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
    
    if ([string characterAtIndex:string.length - 1] != ')') {
        return nil;
    }
    
    //remove closing bracket
    string = [string substringToIndex:(string.length - 1)];
    
    NSArray* bits = explode(@"(",string);
    
    if (bits.count != 2) {
        return nil;
    }
    
    NSString* shape = bits[0];
    
    // they plan to add more shapes in the future!
    if (![shape isEqual:@"rect"]) {
        return nil;
    }
    
    // we "may also support separation without commas" but we wont
    NSArray* coordinates = explode(@",",bits[1]);
    
    if (coordinates.count != 4) {
        return nil;
    }
    
    HTMLPurifier_AttrDef_CSS_Composite* validation = [[HTMLPurifier_AttrDef_CSS_Composite alloc] initWithDefs:@[[[HTMLPurifier_AttrDef_Enum alloc] initWithValidValues:@[@"auto"]],[HTMLPurifier_AttrDef_CSS_Length new]]];
    
    NSMutableArray* newCoordinates = [NSMutableArray new];
    for (int i = 0; i<4; i++) {
        
        NSString* coord = [validation validateWithString:coordinates[i] config:config context:context];
        if (coord == nil) {
            return nil;
        }
        [newCoordinates addObject:coord];
    }
    
    return [NSString stringWithFormat:@"%@(%@)",shape,implode(@",",newCoordinates)];
}


@end
