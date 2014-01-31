//
//  HTMLPurifier_AttrTransform.m
//  HTMLPurifier
//
//  Created by Roman Priebe on 18.01.14.


#import "HTMLPurifier_AttrTransform.h"
#import "HTMLPurifier_Config.h"
#import "HTMLPurifier_Context.h"

/**
 * Processes an entire attribute array for corrections needing multiple values.
 *
 * Occasionally, a certain attribute will need to be removed and popped onto
 * another value.  Instead of creating a complex return syntax for
 * HTMLPurifier_AttrDef, we just pass the whole attribute array to a
 * specialized object and have that do the special work.  That is the
 * family of HTMLPurifier_AttrTransform.
 *
 * An attribute transformation can be assigned to run before or after
 * HTMLPurifier_AttrDef validation.  See HTMLPurifier_HTMLDefinition for
 * more details.
 */
@implementation HTMLPurifier_AttrTransform





/**
 * Abstract: makes changes to the attributes dependent on multiple values.
 *
 * @param array $attr Assoc array of attributes, usually from
 *              HTMLPurifier_Token_Tag::$attr
 * @param HTMLPurifier_Config $config Mandatory HTMLPurifier_Config object.
 * @param HTMLPurifier_Context $context Mandatory HTMLPurifier_Context object
 * @return array Processed attribute array.
 */

- (NSDictionary*)transform:(NSDictionary*)attr sortedKeys:(NSMutableArray*)sortedKeys config:(HTMLPurifier_Config*)config context:(HTMLPurifier_Context*)context
{
    return attr;
}

- (void)prependCSS:(NSMutableDictionary*)attr sortedKeys:(NSMutableArray*)sortedKeys css:(NSString*)css
{
    attr[@"style"] = attr[@"style"] ? attr[@"style"] : @"";
    attr[@"style"] = [css stringByAppendingString:attr[@"style"]];
    if (![sortedKeys containsObject:@"style"])
        [sortedKeys addObject:@"style"];
}

   /**
     * Retrieves and removes an attribute
     * @param array &$attr Attribute array to process (passed by reference)
     * @param mixed $key Key of attribute to confiscate
     * @return mixed
     */
- (NSObject*)confiscateAttr:(NSMutableDictionary*)attr sortedKeys:(NSMutableArray*)sortedKeys key:(NSString*)key
    {
        if (!attr[key])
        {
            return nil;
        }
        NSObject* value = attr[key];
        [attr removeObjectForKey:key];
        [sortedKeys removeObject:key];
        return value;
    }




@end
