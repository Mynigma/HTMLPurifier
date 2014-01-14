//
//  HTMLPurifier_AttrDef_CSS.m
//  HTMLPurifier
//
//  Created by Lukas Neumann on 13.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

/**
 * Validates the HTML attribute style, otherwise known as CSS.
 * @note We don't implement the whole CSS specification, so it might be
 *       difficult to reuse this component in the context of validating
 *       actual stylesheet declarations.
 * @note If we were really serious about validating the CSS, we would
 *       tokenize the styles and then parse the tokens. Obviously, we
 *       are not doing that. Doing that could seriously harm performance,
 *       but would make these components a lot more viable for a CSS
 *       filtering solution.
 */

#import "HTMLPurifier_AttrDef_CSS.h"
#import "BasicPHP.h"

@implementation HTMLPurifier_AttrDef_CSS

/**
 * @param string $css
 * @param HTMLPurifier_Config $config
 * @param HTMLPurifier_Context $context
 * @return bool|string
 */
-(NSString*) validateWithString:(NSString *)css config:(HTMLPurifier_Config *)config context:(HTMLPurifier_Context *)context
{
    css = [super parseCDATAWithString:css];
    
    definition = [config getCSSDefinition];
    
    // we're going to break the spec and explode by semicolons.
    // This is because semicolon rarely appears in escaped form
    // Doing this is generally flaky but fast
    // IT MIGHT APPEAR IN URIs, see HTMLPurifier_AttrDef_CSSURI
    // for details
    
    NSArray* declarations = explode(@";",css);
    NSMutableArray* propvalues = [NSMutableArray new];
    
    /**
     * Name of the current CSS property being validated.
     */
    NSNumber* property = @(NO);
    [context registerWithName:@"CurrentCSSProperty" ref:property];
    
    for (NSString* declaration in declarations)
    {
        if (!declaration)
        {
            continue;
        }
        if (!strpos(declaration, @":"))
        {
            continue;
        }
        //list(property, $value) = explode(':', $declaration, 2);
        NSArray* temp = explodeWithLimit(@":",declaration,2);
    
        property_array = trim(property_array);
        $value = trim($value);
        $ok = false;
        do {
            if (isset($definition->info[$property])) {
                $ok = true;
                break;
            }
            if (ctype_lower($property)) {
                break;
            }
            $property = strtolower($property);
            if (isset($definition->info[$property])) {
                $ok = true;
                break;
            }
        } while (0);
        if (!$ok) {
            continue;
        }
        // inefficient call, since the validator will do this again
        if (strtolower(trim($value)) !== 'inherit') {
            // inherit works for everything (but only on the base property)
            $result = $definition->info[$property]->validate(
                                                             $value,
                                                             $config,
                                                             $context
                                                             );
        } else {
            $result = 'inherit';
        }
        if ($result === false) {
            continue;
        }
        $propvalues[$property] = $result;
    }
    
    $context->destroy('CurrentCSSProperty');
    
    // procedure does not write the new CSS simultaneously, so it's
    // slightly inefficient, but it's the only way of getting rid of
    // duplicates. Perhaps config to optimize it, but not now.
    
    $new_declarations = '';
    foreach ($propvalues as $prop => $value) {
        $new_declarations .= "$prop:$value;";
    }
    
    return $new_declarations ? $new_declarations : false;
    
}

@end
