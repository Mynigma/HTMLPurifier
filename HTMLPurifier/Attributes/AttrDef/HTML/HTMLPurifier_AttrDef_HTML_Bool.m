//
//   HTMLPurifier_AttrDef_HTML_Bool.m
//   HTMLPurifier
//
//  Created by Lukas Neumann on 10.01.14.


#import "HTMLPurifier_AttrDef_HTML_Bool.h"

@implementation HTMLPurifier_AttrDef_HTML_Bool

@synthesize name;
@synthesize minimized;

-(id) init
{
    name = nil;
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
-(NSString*) validateWithString:(NSString*)string config:(HTMLPurifier_Config*)config context:(HTMLPurifier_Context*)context
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
-(HTMLPurifier_AttrDef_HTML_Bool*) make:(NSString*)string
{
    HTMLPurifier_AttrDef_HTML_Bool* end = [HTMLPurifier_AttrDef_HTML_Bool alloc];
    return [end initWithName:string];
}

/*
- (id)copyWithZone:(NSZone *)zone
{
    HTMLPurifier_AttrDef_HTML_Bool* newAttrDef = [super copyWithZone:zone];

    [newAttrDef setName:self.name];
    [newAttrDef setMinimized:self.minimized];

    return newAttrDef;
}*/


@end
