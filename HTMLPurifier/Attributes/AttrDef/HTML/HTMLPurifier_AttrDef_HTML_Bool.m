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

- (instancetype)initWithCoder:(NSCoder*)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        name = [coder decodeObjectForKey:@"name"];
    }
    return self;
}



- (void)encodeWithCoder:(NSCoder*)encoder
{
    [super encodeWithCoder:encoder];
    [encoder encodeObject:name forKey:@"name"];
}


- (BOOL)isEqual:(HTMLPurifier_AttrDef_HTML_Bool*)other
{
    if (other == self)
        return YES;
    
    if (![super isEqual:other])
        return NO;
    
    if(![other isKindOfClass:[HTMLPurifier_AttrDef_HTML_Bool class]])
        return NO;
    
    BOOL nameEqual = (!self.name && ![other name]) || [self.name isEqual:[other name]];
    
    return nameEqual;
}

- (NSUInteger)hash
{
    return [name hash] ^ [super hash];
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
