//
//   HTMLPurifier_AttrDef_CSS_Font.h
//   HTMLPurifier
//
//  Created by Roman Priebe on 14.01.14.


#import "HTMLPurifier_AttrDef.h"

/**
 * Validates shorthand CSS property font.
 */
@interface HTMLPurifier_AttrDef_CSS_Font : HTMLPurifier_AttrDef


@property NSDictionary* info;




/**
     * @param HTMLPurifier_Config $config
     */
- (id)initWithConfig:(HTMLPurifier_Config*)config;

    /**
     * @param string $string
     * @param HTMLPurifier_Config $config
     * @param HTMLPurifier_Context $context
     * @return bool|string
     */
- (NSString*)validateWithString:(NSString *)theString config:(HTMLPurifier_Config *)config context:(HTMLPurifier_Context *)context;


@end
