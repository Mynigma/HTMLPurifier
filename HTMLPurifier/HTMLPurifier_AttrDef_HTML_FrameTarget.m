//
//  HTMLPurifier_AttrDef_HTML_FrameTarget.m
//  HTMLPurifier
//
//  Created by Lukas Neumann on 11.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_AttrDef_HTML_FrameTarget.h"

@implementation HTMLPurifier_AttrDef_HTML_FrameTarget

/**
 * @type array
 */
@synthesize  valid_values;

/**
 * @type bool
 */
protected $case_sensitive = false;

public function __construct()
{
}

/**
 * @param string $string
 * @param HTMLPurifier_Config $config
 * @param HTMLPurifier_Context $context
 * @return bool|string
 */
public function validate($string, $config, $context)
{
    if ($this->valid_values === false) {
        $this->valid_values = $config->get('Attr.AllowedFrameTargets');
    }
    return parent::validate($string, $config, $context);
}



@end
