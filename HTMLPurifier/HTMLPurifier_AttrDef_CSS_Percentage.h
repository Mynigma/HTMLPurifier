//
//  HTMLPurifier_AttrDef_Percentage.h
//  HTMLPurifier
//
//  Created by Roman Priebe on 11.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_AttrDef.h"

@interface HTMLPurifier_AttrDef_CSS_Percentage : HTMLPurifier_AttrDef
{
    /**
     * Instance to defer number validation to.
     * @type HTMLPurifier_AttrDef_CSS_Number
     */
    HTMLPurifier_AttrDef_CSS_Number* numberDef;
}

/**
 * @param string $string
 * @param HTMLPurifier_Config $config
 * @param HTMLPurifier_Context $context
 * @return bool|string
 */
public function validate($string, $config, $context)
{
    $string = $this->parseCDATA($string);

    if ($string === '') {
        return false;
    }
    $length = strlen($string);
    if ($length === 1) {
        return false;
    }
    if ($string[$length - 1] !== '%') {
        return false;
    }

    $number = substr($string, 0, $length - 1);
    $number = $this->number_def->validate($number, $config, $context);

    if ($number === false) {
        return false;
    }
    return "$number%";
}

@end
