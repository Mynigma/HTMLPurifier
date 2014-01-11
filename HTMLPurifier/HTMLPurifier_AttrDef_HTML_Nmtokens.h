//
//  HTMLPurifier_AttrDef_HTML_Nmtokens.h
//  HTMLPurifier
//
//  Created by Lukas Neumann on 10.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTMLPurifier_AttrDef.h"


/**
 * Validates contents based on NMTOKENS attribute type.
 */
@interface HTMLPurifier_AttrDef_HTML_Nmtokens : HTMLPurifier_AttrDef

/**
 * @param string $string
 * @param HTMLPurifier_Config $config
 * @param HTMLPurifier_Context $context
 * @return bool|string
 */
- (BOOL) validateWithString:(NSString*)string Config:(HTMLPurifier_Config*)config Context:(HTMLPurifier_Context*)context;


/**
 * Splits a space separated list of tokens into its constituent parts.
 * @param string $string
 * @param HTMLPurifier_Config $config
 * @param HTMLPurifier_Context $context
 * @return array
 */
-(NSMutableArray*) splitWithString:(NSString*)string Config:(HTMLPurifier_Config*)config Context:(HTMLPurifier_Context*)context;

/**
 * Template method for removing certain tokens based on arbitrary criteria.
 * @note If we wanted to be really functional, we'd do an array_filter
 *       with a callback. But... we're not.
 * @param array $tokens
 * @param HTMLPurifier_Config $config
 * @param HTMLPurifier_Context $context
 * @return array
 */
- (NSMutableArray*) filterWithTokens:(NSMutableArray*)tokens Config:(HTMLPurifier_Config*)config Context:(HTMLPurifier_Context*)context;


@end
