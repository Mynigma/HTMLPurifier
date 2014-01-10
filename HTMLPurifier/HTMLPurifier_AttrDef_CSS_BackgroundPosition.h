//
//  HTMLPurifier_AttrDef_CSS_BackgroundPosition.h
//  HTMLPurifier
//
//  Created by Roman Priebe on 10.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_AttrDef.h"

@interface HTMLPurifier_AttrDef_CSS_BackgroundPosition : HTMLPurifier_AttrDef
{
    /**
     * @type HTMLPurifier_AttrDef_CSS_Length
     */
    HTMLPurifier_AttrDef_CSS_Length* length;

    /**
     * @type HTMLPurifier_AttrDef_CSS_Percentage
     */
    HTMLPurifier_AttrDef_CSS_Percentage* percentage;
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
        $bits = explode(' ', $string);

        $keywords = array();
        $keywords['h'] = false; // left, right
        $keywords['v'] = false; // top, bottom
        $keywords['ch'] = false; // center (first word)
        $keywords['cv'] = false; // center (second word)
        $measures = array();

        $i = 0;

        $lookup = array(
                        'top' => 'v',
                        'bottom' => 'v',
                        'left' => 'h',
                        'right' => 'h',
                        'center' => 'c'
                        );

        foreach ($bits as $bit) {
            if ($bit === '') {
                continue;
            }

            // test for keyword
            $lbit = ctype_lower($bit) ? $bit : strtolower($bit);
            if (isset($lookup[$lbit])) {
                $status = $lookup[$lbit];
                if ($status == 'c') {
                    if ($i == 0) {
                        $status = 'ch';
                    } else {
                        $status = 'cv';
                    }
                }
                $keywords[$status] = $lbit;
                $i++;
            }

            // test for length
            $r = $this->length->validate($bit, $config, $context);
            if ($r !== false) {
                $measures[] = $r;
                $i++;
            }

            // test for percentage
            $r = $this->percentage->validate($bit, $config, $context);
            if ($r !== false) {
                $measures[] = $r;
                $i++;
            }
        }

        if (!$i) {
            return false;
        } // no valid values were caught

        $ret = array();

        // first keyword
        if ($keywords['h']) {
            $ret[] = $keywords['h'];
        } elseif ($keywords['ch']) {
            $ret[] = $keywords['ch'];
            $keywords['cv'] = false; // prevent re-use: center = center center
        } elseif (count($measures)) {
            $ret[] = array_shift($measures);
        }

        if ($keywords['v']) {
            $ret[] = $keywords['v'];
        } elseif ($keywords['cv']) {
            $ret[] = $keywords['cv'];
        } elseif (count($measures)) {
            $ret[] = array_shift($measures);
        }
        
        if (empty($ret)) {
            return false;
        }
        return implode(' ', $ret);
    }
}

@end
