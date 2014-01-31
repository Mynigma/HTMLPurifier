//
//   HTMLPurifier_VarParser_Flexible.m
//   HTMLPurifier
//
//  Created by Roman Priebe on 13.01.14.


#import "HTMLPurifier_VarParser_Flexible.h"

@implementation HTMLPurifier_VarParser_Flexible




/**
 * @param mixed $var
 * @param int $type
 * @param bool $allow_null
 * @return array|bool|float|int|mixed|null|string
 * @throws HTMLPurifier_VarParserException
 */
- (NSObject*)parseImplementation:var type:(NSNumber*)type allowNull:(BOOL)allow_null
{
    return nil;
    /*
    if (allow_null && !var) {
        return nil;
    }
    switch (type.integerValue) {
            // Note: if code "breaks" from the switch, it triggers a generic
            // exception to be thrown. Specific errors can be specifically
            // done here.
        case 11: //mixed
        case 2: //istring
        case 1: //string
        case 3: //text
        case 4: //itext
            return var;
        case 5: //int
            if ([var isKindOfClass:[NSNumber class]] && ctype_digit((NSString*)var))
            {
                return var;
            }
            return var;
        case self::FLOAT:
            if ([var isKindOfClass:[NSString class]] && var || is_int($var)) {
                $var = (float)$var;
            }
            return $var;
        case self::BOOL:
            if (is_int($var) && ($var === 0 || $var === 1)) {
                $var = (bool)$var;
            } elseif (is_string($var)) {
                if ($var == 'on' || $var == 'true' || $var == '1') {
                    $var = true;
                } elseif ($var == 'off' || $var == 'false' || $var == '0') {
                    $var = false;
                } else {
                    throw new HTMLPurifier_VarParserException("Unrecognized value '$var' for $type");
                }
            }
            return $var;
        case self::ALIST:
        case self::HASH:
        case self::LOOKUP:
            if (is_string($var)) {
                // special case: technically, this is an array with
                // a single empty string item, but having an empty
                // array is more intuitive
                if ($var == '') {
                    return array();
                }
                if (strpos($var, "\n") === false && strpos($var, "\r") === false) {
                    // simplistic string to array method that only works
                    // for simple lists of tag names or alphanumeric characters
                    $var = explode(',', $var);
                } else {
                    $var = preg_split('/(,|[\n\r]+)/', $var);
                }
                // remove spaces
                foreach ($var as $i => $j) {
                    $var[$i] = trim($j);
                }
                if ($type === self::HASH) {
                    // key:value,key2:value2
                    $nvar = array();
                    foreach ($var as $keypair) {
                        $c = explode(':', $keypair, 2);
                        if (!isset($c[1])) {
                            continue;
                        }
                        $nvar[trim($c[0])] = trim($c[1]);
                    }
                    $var = $nvar;
                }
            }
            if (!is_array($var)) {
                break;
            }
            $keys = array_keys($var);
            if ($keys === array_keys($keys)) {
                if ($type == self::ALIST) {
                    return $var;
                } elseif ($type == self::LOOKUP) {
                    $new = array();
                    foreach ($var as $key) {
                        $new[$key] = true;
                    }
                    return $new;
                } else {
                    break;
                }
            }
            if ($type === self::ALIST) {
                trigger_error("Array list did not have consecutive integer indexes", E_USER_WARNING);
                return array_values($var);
            }
            if ($type === self::LOOKUP) {
                foreach ($var as $key => $value) {
                    if ($value !== true) {
                        trigger_error(
                                      "Lookup array has non-true value at key '$key'; " .
                                      "maybe your input array was not indexed numerically",
                                      E_USER_WARNING
                                      );
                    }
                    $var[$key] = true;
                }
            }
            return $var;
        default:
            $this->errorInconsistent(__CLASS__, $type);
    }
    $this->errorGeneric($var, $type);
}*/
}



@end
