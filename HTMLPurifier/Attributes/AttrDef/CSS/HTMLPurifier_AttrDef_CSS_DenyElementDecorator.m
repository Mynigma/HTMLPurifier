//
//   HTMLPurifier_AttrDef_CSS_DenyElementDecorator.m
//   HTMLPurifier
//
//  Created by Lukas Neumann on 15.01.14.


/**
 * Decorator which enables CSS properties to be disabled for specific elements.
 */

#import "HTMLPurifier_AttrDef_CSS_DenyElementDecorator.h"
#import "HTMLPurifier_Token.h"

@implementation HTMLPurifier_AttrDef_CSS_DenyElementDecorator

/**
 * @type HTMLPurifier_AttrDef
 */
@synthesize def;

/**
 * @type string
 */
@synthesize element;

/**
 * @param HTMLPurifier_AttrDef def Definition to wrap
 * @param string element Element to deny
 */
-(id) initWithDef:(HTMLPurifier_AttrDef*)ndef Element:(NSString*) nelement
{
    self = [super init];
    def = ndef;
    element = nelement;
    return self;
}



- (instancetype)initWithCoder:(NSCoder*)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        def = [coder decodeObjectForKey:@"def"];
        element = [coder decodeObjectForKey:@"element"];
    }
    return self;
}



- (void)encodeWithCoder:(NSCoder*)encoder
{
    [super encodeWithCoder:encoder];
    [encoder encodeObject:def forKey:@"def"];
    [encoder encodeObject:element forKey:@"element"];
}


- (BOOL)isEqual:(id)other
{
    if (other == self) {
        return YES;
    } else if (![super isEqual:other]) {
        return NO;
    } else if(![other isKindOfClass:[HTMLPurifier_AttrDef_CSS_DenyElementDecorator class]])
    {
        return NO;
    }
    else
    {
        return ((!self.def && ![(HTMLPurifier_AttrDef_CSS_DenyElementDecorator*)other def]) || [self.def isEqual:[(HTMLPurifier_AttrDef_CSS_DenyElementDecorator*)other def]]) && ((!self.element && ![(HTMLPurifier_AttrDef_CSS_DenyElementDecorator*)other element]) || [self.element isEqual:[(HTMLPurifier_AttrDef_CSS_DenyElementDecorator*)other element]]);
    }
}

- (NSUInteger)hash
{
    return [def hash] ^ [element hash] ^ [super hash];
}
















/**
 * Checks if CurrentToken is set and equal to this->element
 * @param string string
 * @param HTMLPurifier_Config config
 * @param HTMLPurifier_Context context
 * @return bool|string
 */
-(NSString*) validateWithString:(NSString *)string config:(HTMLPurifier_Config *)config context:(HTMLPurifier_Context *)context
{
    HTMLPurifier_Token* token = (HTMLPurifier_Token*)[context getWithName:@"CurrentToken" ignoreError:YES];
    if (token && [[token valueForKey:@"name"] isEqual:element])
    {
        return nil;
    }
    return [def validateWithString:string config:config context:context];
}

@end
