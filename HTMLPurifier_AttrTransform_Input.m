//
//  HTMLPurifier_AttrTransform_Input.m
//  HTMLPurifier
//
//  Created by Lukas Neumann on 23.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_AttrTransform_Input.h"

/**
 * Performs miscellaneous cross attribute validation and filtering for
 * input elements. This is meant to be a post-transform.
 */
@implementation HTMLPurifier_AttrTransform_Input

/**
 * @type HTMLPurifier_AttrDef_HTML_Pixels
 */
protected $pixels;

public function __construct()
{
    $this->pixels = new HTMLPurifier_AttrDef_HTML_Pixels();
}

/**
 * @param array $attr
 * @param HTMLPurifier_Config $config
 * @param HTMLPurifier_Context $context
 * @return array
 */
public function transform($attr, $config, $context)
{
    if (!isset($attr['type'])) {
        $t = 'text';
    } else {
        $t = strtolower($attr['type']);
    }
    if (isset($attr['checked']) && $t !== 'radio' && $t !== 'checkbox') {
        unset($attr['checked']);
    }
    if (isset($attr['maxlength']) && $t !== 'text' && $t !== 'password') {
        unset($attr['maxlength']);
    }
    if (isset($attr['size']) && $t !== 'text' && $t !== 'password') {
        $result = $this->pixels->validate($attr['size'], $config, $context);
        if ($result === false) {
            unset($attr['size']);
        } else {
            $attr['size'] = $result;
        }
    }
    if (isset($attr['src']) && $t !== 'image') {
        unset($attr['src']);
    }
    if (!isset($attr['value']) && ($t === 'radio' || $t === 'checkbox')) {
        $attr['value'] = '';
    }
    return $attr;
}

@end
