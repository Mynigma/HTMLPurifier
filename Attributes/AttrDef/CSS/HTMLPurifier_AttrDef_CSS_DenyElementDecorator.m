//
//  HTMLPurifier_AttrDef_CSS_DenyElementDecorator.m
//  HTMLPurifier
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
