//
//  HTMLPurifier_AttrDef_URI_IPv4.m
//  HTMLPurifier
//
//  Created by Lukas Neumann on 12.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

/**
 * Validates an IPv4 address
 * @author Feyd @ forums.devnetwork.net (public domain)
 */

#import "HTMLPurifier_AttrDef_URI_IPv4.h"

@implementation HTMLPurifier_AttrDef_URI_IPv4

/**
 * IPv4 regex, protected so that IPv6 can reuse it.
 * @type string
 */
protected $ip4;

/**
 * @param string $aIP
 * @param HTMLPurifier_Config $config
 * @param HTMLPurifier_Context $context
 * @return bool|string
 */
public function validate($aIP, $config, $context)
{
    if (!$this->ip4) {
        $this->_loadRegex();
    }
    
    if (preg_match('#^' . $this->ip4 . '$#s', $aIP)) {
        return $aIP;
    }
    return false;
}

/**
 * Lazy load function to prevent regex from being stuffed in
 * cache.
 */
protected function _loadRegex()
{
    $oct = '(?:25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9][0-9]|[0-9])'; // 0-255
    $this->ip4 = "(?:{$oct}\\.{$oct}\\.{$oct}\\.{$oct})";
}


@end
