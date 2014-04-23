//
//   HTMLPurifier_AttrDef_HTML_FrameTarget.m
//   HTMLPurifier
//
//  Created by Lukas Neumann on 11.01.14.


#import "HTMLPurifier_AttrDef_HTML_FrameTarget.h"

@implementation HTMLPurifier_AttrDef_HTML_FrameTarget

/**
 * @type array
 */

/**
 * @type bool
 */

-(id) init
{
    self = [super init];
    return self;
}

/**
 * @param string $string
 * @param HTMLPurifier_Config $config
 * @param HTMLPurifier_Context $context
 * @return bool|string
 */
-(NSString*) validateWithString:(NSString *)string config:(HTMLPurifier_Config *)config context:(HTMLPurifier_Context *)context
{
    if (!self.validValues)
    {
        NSObject* allowedFrameTargets = [(NSMutableDictionary*)[config get:@"Attr.AllowedFrameTargets"] mutableCopy];
        if(![allowedFrameTargets isKindOfClass:[NSArray class]])
            allowedFrameTargets = [NSMutableArray new];
        [self setValidValues:(NSMutableArray*)allowedFrameTargets];
    }
    return [super validateWithString:string config:config context:context];
}

@end
