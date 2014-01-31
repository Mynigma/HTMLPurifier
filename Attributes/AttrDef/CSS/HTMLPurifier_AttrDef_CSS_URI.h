//
//  HTMLPurifier_AttrDef_CSS_URI.h
//  HTMLPurifier
//
//  Created by Roman Priebe on 11.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_AttrDef_URI.h"

@interface HTMLPurifier_AttrDef_CSS_URI : HTMLPurifier_AttrDef_URI

/*
 public function __construct()
 {
 parent::__construct(true); // always embedded
 }*/

/**
 * @param string $uri_string
 * @param HTMLPurifier_Config $config
 * @param HTMLPurifier_Context $context
 * @return bool|string
 */
- (NSString*)validateWithString:(NSString *)string config:(HTMLPurifier_Config *)config context:(HTMLPurifier_Context *)context;

@end
