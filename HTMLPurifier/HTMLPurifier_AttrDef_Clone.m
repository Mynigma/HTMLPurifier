//
//  HTMLPurifier_AttrDef_Clone.m
//  HTMLPurifier
//
//  Created by Lukas Neumann on 13.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

/**
 * Dummy AttrDef that mimics another AttrDef, BUT it generates clones
 * with make.
 */

#import "HTMLPurifier_AttrDef_Clone.h"

@implementation HTMLPurifier_AttrDef_Clone

/**
 * What we're cloning.
 * @type HTMLPurifier_AttrDef
 */
protected $clone;

/**
 * @param HTMLPurifier_AttrDef $clone
 */
public function __construct($clone)
{
    $this->clone = $clone;
}

/**
 * @param string $v
 * @param HTMLPurifier_Config $config
 * @param HTMLPurifier_Context $context
 * @return bool|string
 */
public function validate($v, $config, $context)
{
    return $this->clone->validate($v, $config, $context);
}

/**
 * @param string $string
 * @return HTMLPurifier_AttrDef
 */
public function make($string)
{
    return clone $this->clone;
}

@end
