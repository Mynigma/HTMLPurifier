//
//  HTMLPurifier_EntityParser.m
//  HTMLPurifier
//
//  Created by Roman Priebe on 14.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_EntityParser.h"
#import "BasicPHP.h"
#import "HTMLPurifier_Encoder.h"
#import "HTMLPurifier_EntityLookup.h"

@implementation HTMLPurifier_EntityParser


- (id)init
{
    self = [super init];
    if (self) {
        
        _substituteEntitiesRegex = @"/&(?:[#]x([a-fA-F0-9]+)|[#]0*(\\d+)|([A-Za-z_:][A-Za-z0-9.\\-_:]*));?/";
        //    //     1. hex             2. dec      3. string (XML style)

        _specialDec2Str = @{@34 : @"\"",
                            @38 : @"&",
                            @39 : @"'",
                            @60 : @"<",
                            @62 : @">"};

        _specialEnt2Dec = @{@"quot" : @34,
                            @"amp" : @38,
                            @"lt" : @60,
                            @"gt" : @62};
    }
    return self;
}



- (NSString*)substituteNonSpecialEntities:(NSString*)string;
    {
        // it will try to detect missing semicolons, but don't rely on it
        return preg_replace_callback_3(_substituteEntitiesRegex, ^(NSArray* matches){
            return [self nonSpecialEntityCallback:matches];
        }, string);
    }


/**
 * Callback function for substituteNonSpecialEntities() that does the work.
 *
 * @param array $matches  PCRE matches array, with 0 the entire match, and
 *                  either index 1, 2 or 3 set with a hex value, dec value,
 *                  or string (respectively).
 * @return string Replacement string.
 */
- (NSString*)nonSpecialEntityCallback:(NSArray*)matches
{
    if(matches.count<4)
    {
        TRIGGER_ERROR(@"Error: nonSpecialEntityCallback called with invalid matches array!!");
        return @"";
    }
    // replaces all but big five
    NSString* entity = matches[0];
    NSString* hexVal = matches[1];
    NSString* decVal = matches[2];
    NSString* stringVal = matches[3];

    BOOL isNum = NO;
    if([[entity substringWithRange:NSMakeRange(1, 1)] isEqualToString:@"#"])
        isNum = YES;
    if(isNum)
    {
        BOOL isHex = ([hexVal isEqualToString:@"x"]);

        NSNumber* code = (isHex ? @(hexdec(matches[1])) : matches[2]);

        // abort for special characters
        if (code && _specialDec2Str[code])
        {
            return (NSString*)entity;
        }
        return [HTMLPurifier_Encoder unichr:code.intValue];
    }
    else
    {
        if (_specialEnt2Dec[stringVal])
        {
            return entity;
        }
        if (!_entityLookup) {
            _entityLookup = [HTMLPurifier_EntityLookup instance];
        }
        if (_entityLookup.table[stringVal])
        {
            return _entityLookup.table[matches[3]];
        }
        else
        {
            return entity;
        }
    }
}


//// if want to implement error collecting here, we'll need to use some sort
//// of global data (probably trigger_error) because it's impossible to pass
//// $config or $context to the callback functions.
//
///**
// * Handles referencing and derefencing character entities
// */
//class HTMLPurifier_EntityParser
//{
//
//    /**
//     * Reference to entity lookup table.
//     * @type HTMLPurifier_EntityLookup
//     */
//    protected $_entity_lookup;
//
//    /**
//     * Callback regex string for parsing entities.
//     * @type string
//     */
//    protected $_substituteEntitiesRegex =
//    '/&(?:[#]x([a-fA-F0-9]+)|[#]0*(\d+)|([A-Za-z_:][A-Za-z0-9.\-_:]*));?/';
//    //     1. hex             2. dec      3. string (XML style)
//
//    /**
//     * Decimal to parsed string conversion table for special entities.
//     * @type array
//     */
//    protected $_special_dec2str =
//    array(
//          34 => '"',
//          38 => '&',
//          39 => "'",
//          60 => '<',
//          62 => '>'
//          );
//
//    /**
//     * Stripped entity names to decimal conversion table for special entities.
//     * @type array
//     */
//    protected $_special_ent2dec =
//    array(
//          'quot' => 34,
//          'amp'  => 38,
//          'lt'   => 60,
//          'gt'   => 62
//          );
//
//    /**
//     * Substitutes non-special entities with their parsed equivalents. Since
//     * running this whenever you have parsed character is t3h 5uck, we run
//     * it before everything else.
//     *
//     * @param string $string String to have non-special entities parsed.
//     * @return string Parsed string.
//     */
//    public function substituteNonSpecialEntities($string)
//    {
//        // it will try to detect missing semicolons, but don't rely on it
//        return preg_replace_callback(
//                                     $this->_substituteEntitiesRegex,
//                                     array($this, 'nonSpecialEntityCallback'),
//                                     $string
//                                     );
//    }
//
//    /**
//     * Callback function for substituteNonSpecialEntities() that does the work.
//     *
//     * @param array $matches  PCRE matches array, with 0 the entire match, and
//     *                  either index 1, 2 or 3 set with a hex value, dec value,
//     *                  or string (respectively).
//     * @return string Replacement string.
//     */
//
//    protected function nonSpecialEntityCallback($matches)
//    {
//        // replaces all but big five
//        $entity = $matches[0];
//        $is_num = (@$matches[0][1] === '#');
//        if ($is_num) {
//            $is_hex = (@$entity[2] === 'x');
//            $code = $is_hex ? hexdec($matches[1]) : (int) $matches[2];
//            // abort for special characters
//            if (isset($this->_special_dec2str[$code])) {
//                return $entity;
//            }
//            return HTMLPurifier_Encoder::unichr($code);
//        } else {
//            if (isset($this->_special_ent2dec[$matches[3]])) {
//                return $entity;
//            }
//            if (!$this->_entity_lookup) {
//                $this->_entity_lookup = HTMLPurifier_EntityLookup::instance();
//            }
//            if (isset($this->_entity_lookup->table[$matches[3]])) {
//                return $this->_entity_lookup->table[$matches[3]];
//            } else {
//                return $entity;
//            }
//        }
//    }
//
//    /**
//     * Substitutes only special entities with their parsed equivalents.
//     *
//     * @notice We try to avoid calling this function because otherwise, it
//     * would have to be called a lot (for every parsed section).
//     *
//     * @param string $string String to have non-special entities parsed.
//     * @return string Parsed string.
//     */
//    public function substituteSpecialEntities($string)
//    {
//        return preg_replace_callback(
//                                     $this->_substituteEntitiesRegex,
//                                     array($this, 'specialEntityCallback'),
//                                     $string
//                                     );
//    }
//
//    /**
//     * Callback function for substituteSpecialEntities() that does the work.
//     *
//     * This callback has same syntax as nonSpecialEntityCallback().
//     *
//     * @param array $matches  PCRE-style matches array, with 0 the entire match, and
//     *                  either index 1, 2 or 3 set with a hex value, dec value,
//     *                  or string (respectively).
//     * @return string Replacement string.
//     */
//    protected function specialEntityCallback($matches)
//    {
//        $entity = $matches[0];
//        $is_num = (@$matches[0][1] === '#');
//        if ($is_num) {
//            $is_hex = (@$entity[2] === 'x');
//            $int = $is_hex ? hexdec($matches[1]) : (int) $matches[2];
//            return isset($this->_special_dec2str[$int]) ?
//            $this->_special_dec2str[$int] :
//            $entity;
//        } else {
//            return isset($this->_special_ent2dec[$matches[3]]) ?
//            $this->_special_ent2dec[$matches[3]] :
//            $entity;
//        }
//    }
//}


@end
