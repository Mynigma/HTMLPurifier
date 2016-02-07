//
//   HTMLPurifier_AttrDef_CSS.m
//   HTMLPurifier
//
//  Created by Lukas Neumann on 13.01.14.


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
#import "BasicPHP.h"
#import "HTMLPurifier_AttrDef_CSS.h"
#import "HTMLPurifier_CSSDefinition.h"


@implementation HTMLPurifier_AttrDef_CSS


- (BOOL)isEqual:(id)other
{
    if (other == self)
        return YES;
    
    if (![super isEqual:other])
        return NO;
    
    if(![other isKindOfClass:[HTMLPurifier_AttrDef_CSS class]])
        return NO;

    return YES;
}




/**
 * @param string $css
 * @param HTMLPurifier_Config $config
 * @param HTMLPurifier_Context $context
 * @return bool|string
 */
-(NSString*) validateWithString:(NSString *)css config:(HTMLPurifier_Config *)config context:(HTMLPurifier_Context *)context
{
    css = [super parseCDATAWithString:css];
    
    HTMLPurifier_CSSDefinition* definition = [config getCSSDefinition];
    
    // we're going to break the spec and explode by semicolons.
    // This is because semicolon rarely appears in escaped form
    // Doing this is generally flaky but fast
    // IT MIGHT APPEAR IN URIs, see HTMLPurifier_AttrDef_CSSURI
    // for details
    
    NSArray* declarations = explode(@";",css);
    NSMutableDictionary* propvalues = [NSMutableDictionary new];

    //array of propvalue_keys (for preserving sort order)
    NSMutableArray* propvalue_keys = [NSMutableArray new];
    /**
     * Name of the current CSS property being validated.
     */
    NSNumber* property = @(NO);
    [context registerWithName:@"CurrentCSSProperty" ref:property];
    
    for (NSString* declaration in declarations)
    {
        if (declaration.length==0)
        {
            continue;
        }
        if (!strpos(declaration, @":"))
        {
            continue;
        }


        //list(property, $value) = explode(':', $declaration, 2);
        NSArray* temp = explodeWithLimit(@":",declaration,2);
        NSString* property_string = nil;
        if(temp.count>0)
            property_string = [temp objectAtIndex:0];
        else
            continue;
        NSString*  value = nil;
        if(temp.count>1)
            value = [temp objectAtIndex:1];
        else
            continue;
        
        property_string = trim(property_string);
        value = trim(value);
        
        NSNumber* ok = @(NO);
        do {
            if ([definition info][property_string])
            {
                ok = @(YES);
                break;
            }
            property_string = [property_string lowercaseString];
            if ([definition info][property_string])
            {
                ok = @(YES);
                break;
            }
        } while (0);
        if (![ok boolValue]) {
            continue;
        }
        // inefficient call, since the validator will do this again
        NSString* result;
        // inefficient call, since the validator will do this again
        if (![[value lowercaseString] isEqual:@"inherit"])
        {
            // inherit works for everything (but only on the base property)
            HTMLPurifier_AttrDef* attrDef = definition.info[property_string];
            result = [attrDef validateWithString:value config:config context:context];
        }
        else
        {
            result = @"inherit";
        }
        if (!result)
        {
            continue;
        }
        if([propvalue_keys containsObject:property_string])
            [propvalue_keys removeObject:property_string];
        propvalues[property_string] = result;
        [propvalue_keys addObject:property_string];
    }
    
    [context destroy:@"CurrentCSSProperty"];
    
    // procedure does not write the new CSS simultaneously, so it's
    // slightly inefficient, but it's the only way of getting rid of
    // duplicates. Perhaps config to optimize it, but not now.
    
    NSString* new_declarations = @"";
    for (NSString* key in propvalue_keys)
    {
        new_declarations = [new_declarations stringByAppendingString:[NSString stringWithFormat:@"%@:%@;",key,propvalues[key]]];
    }
    
    return [new_declarations isEqual:@""] ?  nil : new_declarations;
    
}

@end
