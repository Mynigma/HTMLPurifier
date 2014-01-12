//
//  HTMLPurifier_AttrDef_HTML_LinkTypes.m
//  HTMLPurifier
//
//  Created by Lukas Neumann on 12.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_AttrDef_HTML_LinkTypes.h"

@implementation HTMLPurifier_AttrDef_HTML_LinkTypes

/**
 * Name config attribute to pull.
 * @type string
 */
protected $name;

/**
 * @param string $name
 */
public function __construct($name)
{
    $configLookup = array(
                          'rel' => 'AllowedRel',
                          'rev' => 'AllowedRev'
                          );
    if (!isset($configLookup[$name])) {
        trigger_error(
                      'Unrecognized attribute name for link ' .
                      'relationship.',
                      E_USER_ERROR
                      );
        return;
    }
    $this->name = $configLookup[$name];
}

/**
 * @param string $string
 * @param HTMLPurifier_Config $config
 * @param HTMLPurifier_Context $context
 * @return bool|string
 */
public function validate($string, $config, $context)
{
    $allowed = $config->get('Attr.' . $this->name);
    if (empty($allowed)) {
        return false;
    }
    
    $string = $this->parseCDATA($string);
    $parts = explode(' ', $string);
    
    // lookup to prevent duplicates
    $ret_lookup = array();
    foreach ($parts as $part) {
        $part = strtolower(trim($part));
        if (!isset($allowed[$part])) {
            continue;
        }
        $ret_lookup[$part] = true;
    }
    
    if (empty($ret_lookup)) {
        return false;
    }
    $string = implode(' ', array_keys($ret_lookup));
    return $string;
}

@end
