//
//   HTMLPurifier_AttrDef_CSS_BackgroundPosition.h
//   HTMLPurifier
//
//  Created by Roman Priebe on 10.01.14.


#import "HTMLPurifier_AttrDef.h"

@class HTMLPurifier_AttrDef_CSS_Length, HTMLPurifier_AttrDef_CSS_Percentage;

@interface HTMLPurifier_AttrDef_CSS_BackgroundPosition : HTMLPurifier_AttrDef

@property HTMLPurifier_AttrDef_CSS_Length* length;
@property HTMLPurifier_AttrDef_CSS_Percentage* percentage;


    /**
     * @param string $string
     * @param HTMLPurifier_Config $config
     * @param HTMLPurifier_Context $context
     * @return bool|string
     */
- (NSString*)validateWithString:(NSString *)string config:(HTMLPurifier_Config *)config context:(HTMLPurifier_Context *)context;



@end
