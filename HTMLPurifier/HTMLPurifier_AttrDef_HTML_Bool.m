//
//  HTMLPurifier_AttrDef_HTML_Bool.m
//  HTMLPurifier
//
//  Created by Lukas Neumann on 10.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_AttrDef_HTML_Bool.h"

@implementation HTMLPurifier_AttrDef_HTML_Bool

@synthesize name;
@synthesize minimized;

-(id) init
{
    name = NO;
    return self;
}

-(id)initWithName:(NSString*)newName
{
    if (!newName)
    {
        name = nil;
        return self;
    }
    name = newName;
    return self;
}

/**
 * @param string $string
 * @param HTMLPurifier_Config $config
 * @param HTMLPurifier_Context $context
 * @return bool|string
 */
-(NSString*) validateWithString:(NSString*)string Config:(HTMLPurifier_Config*)config Context:(HTMLPurifier_Context*)context
{
    if([string isEqual:@""])
    {
        return nil;
    }
    return name;
}

/**
 * @param string $string Name of attribute  
 * @return HTMLPurifier_AttrDef_HTML_Bool
 */
-(HTMLPurifier_AttrDef_HTML_Bool*) makeWithString:(NSString*)string
{
    HTMLPurifier_AttrDef_HTML_Bool* end = [HTMLPurifier_AttrDef_HTML_Bool alloc];
    return [end initWithName:string];
}


@end
