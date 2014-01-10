//
//  HTMLPurifier_AttrDef.h
//  HTMLPurifier
//
//  Created by Roman Priebe on 10.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HTMLPurifier_AttrDef : NSObject

/**
 * Tells us whether or not an HTML attribute is minimized.
 * Has no meaning in other contexts.
 * @type bool
 */
@property BOOL minimized;

/**
 * Tells us whether or not an HTML attribute is required.
 * Has no meaning in other contexts
 * @type bool
 */
@property BOOL required;

/**
 * Validates and cleans passed string according to a definition.
 *
 * @param string $string String to be validated and cleaned.
 * @param HTMLPurifier_Config $config Mandatory HTMLPurifier_Config object.
 * @param HTMLPurifier_Context $context Mandatory HTMLPurifier_Context object.
 */
- (void)validateWithString:(NSString*)string config:(HTMLPurifier_Config*)config context:(HTMLPurifier_Context*)context;

/**
 * Convenience method that parses a string as if it were CDATA.
 *
 * This method process a string in the manner specified at
 * <http://www.w3.org/TR/html4/types.html#h-6.2> by removing
 * leading and trailing whitespace, ignoring line feeds, and replacing
 * carriage returns and tabs with spaces.  While most useful for HTML
 * attributes specified as CDATA, it can also be applied to most CSS
 * values.
 *
 * @note This method is not entirely standards compliant, as trim() removes
 *       more types of whitespace than specified in the spec. In practice,
 *       this is rarely a problem, as those extra characters usually have
 *       already been removed by HTMLPurifier_Encoder.
 *
 * @warning This processing is inconsistent with XML's whitespace handling
 *          as specified by section 3.3.3 and referenced XHTML 1.0 section
 *          4.7.  However, note that we are NOT necessarily
 *          parsing XML, thus, this behavior may still be correct. We
 *          assume that newlines have been normalized.
 */
public function parseCDATA($string)
{
    $string = trim($string);
    $string = str_replace(array("\n", "\t", "\r"), ' ', $string);
    return $string;
}

/**
 * Factory method for creating this class from a string.
 * @param string $string String construction info
 * @return HTMLPurifier_AttrDef Created AttrDef object corresponding to $string
 */
public function make($string)
{
    // default implementation, return a flyweight of this object.
    // If $string has an effect on the returned object (i.e. you
    // need to overload this method), it is best
    // to clone or instantiate new copies. (Instantiation is safer.)
    return $this;
}

/**
 * Removes spaces from rgb(0, 0, 0) so that shorthand CSS properties work
 * properly. THIS IS A HACK!
 * @param string $string a CSS colour definition
 * @return string
 */
protected function mungeRgb($string)
{
    return preg_replace('/rgb\((\d+)\s*,\s*(\d+)\s*,\s*(\d+)\)/', 'rgb(\1,\2,\3)', $string);
}

/**
 * Parses a possibly escaped CSS string and returns the "pure"
 * version of it.
 */
protected function expandCSSEscape($string)
{
    // flexibly parse it
    $ret = '';
    for ($i = 0, $c = strlen($string); $i < $c; $i++) {
        if ($string[$i] === '\\') {
            $i++;
            if ($i >= $c) {
                $ret .= '\\';
                break;
            }
            if (ctype_xdigit($string[$i])) {
                $code = $string[$i];
                for ($a = 1, $i++; $i < $c && $a < 6; $i++, $a++) {
                    if (!ctype_xdigit($string[$i])) {
                        break;
                    }
                    $code .= $string[$i];
                }
                // We have to be extremely careful when adding
                // new characters, to make sure we're not breaking
                // the encoding.
                $char = HTMLPurifier_Encoder::unichr(hexdec($code));
                if (HTMLPurifier_Encoder::cleanUTF8($char) === '') {
                    continue;
                }
                $ret .= $char;
                if ($i < $c && trim($string[$i]) !== '') {
                    $i--;
                }
                continue;
            }
            if ($string[$i] === "\n") {
                continue;
            }
        }
        $ret .= $string[$i];
    }
    return $ret;
}

@end
