//
//   HTMLPurifier_AttrValidator.m
//   HTMLPurifier
//
//  Created by Roman Priebe on 16.01.14.


#import "HTMLPurifier_AttrValidator.h"
#import "HTMLPurifier_Config.h"
#import "HTMLPurifier_Context.h"
#import "HTMLPurifier_HTMLDefinition.h"
#import "HTMLPurifier_IDAccumulator.h"
#import "HTMLPurifier_Token.h"
#import "HTMLPurifier_Token_Start.h"
#import "HTMLPurifier_Token_Empty.h"
#import "HTMLPurifier_ElementDef.h"
#import "HTMLPurifier_AttrDef.h"
#import "HTMLPurifier_AttrTransform.h"
#import "BasicPHP.h"


@implementation HTMLPurifier_AttrValidator


- (void)validateToken:(HTMLPurifier_Token*)token config:(HTMLPurifier_Config*)config  context:(HTMLPurifier_Context*)context
{
    HTMLPurifier_HTMLDefinition* definition = [config getHTMLDefinition];

    // initialize IDAccumulator if necessary

    HTMLPurifier_IDAccumulator* ok = (HTMLPurifier_IDAccumulator*)[context getWithName:@"IDAccumulator" ignoreError:YES];
    if (!ok) {
        HTMLPurifier_IDAccumulator* id_accumulator = [HTMLPurifier_IDAccumulator buildWithConfig:config context:context];
        [context registerWithName:@"IDAccumulator" ref:id_accumulator];
    }

    // initialize CurrentToken if necessary
    NSObject* current_token = (HTMLPurifier_Token*)[context getWithName:@"CurrentToken" ignoreError:YES];
    if (!current_token || [current_token isEqual:@NO]) {
        [context registerWithName:@"CurrentToken" ref:token];
    }

    if (![token isKindOfClass:[HTMLPurifier_Token_Start class]] &&
        ![token isKindOfClass:[HTMLPurifier_Token_Empty class]]
        ) {
        return;
    }

    // create alias to global definition array, see also defs
    // DEFINITION CALL
    NSMutableDictionary* d_defs = [definition info_global_attr];

    // don't update token until the very end, to ensure an atomic update
    NSMutableDictionary* attr = [token.attr mutableCopy];

    NSMutableArray* attrKeyOrder = token.sortedAttrKeys;


     // do global transformations (pre)
     // nothing currently utilizes this
     for(HTMLPurifier_AttrTransform* transform in definition.info_attr_transform_pre.allValues)
     {
         NSMutableDictionary* attrCopy = [attr copy];
         attr = [[transform transform:attr sortedKeys:attrKeyOrder config:config context:context] mutableCopy];
         if (![attr isEqual:attrCopy]) {
             TRIGGER_ERROR(@"AttrValidator: Attributes transformed %@ -> %@", attrCopy, attr);
         }
     }

    // do local transformations only applicable to this element (pre)
    // ex. <p align="right"> to <p style="text-align:right;">

    for(HTMLPurifier_AttrTransform* transform in [(HTMLPurifier_ElementDef*)definition.info[token.name] attr_transform_pre].allValues)
     {
         NSMutableDictionary* attrCopy = [attr copy];
         attr = [[transform transform:attr sortedKeys:attrKeyOrder config:config context:context] mutableCopy];
         if (![attr isEqual:attrCopy])
         {
             TRIGGER_ERROR(@"AttrValidator: Attributes transformed %@ -> %@", attrCopy, attr);
         }
     }

    // create alias to this element's attribute definition array, see
    // also d_defs (global attribute definition array)
    // DEFINITION CALL
    NSDictionary* definitionInfo = definition.info;
    HTMLPurifier_ElementDef* elementDef = definitionInfo[token.name];
    NSMutableDictionary* defs = [elementDef attr];

    NSString* result = nil;

    NSNumber* attr_key = @NO;
    [context registerWithName:@"CurrentAttr" ref:attr_key];

    // iterate through all the attribute keypairs

    NSArray* attrKeyOrderCopy = [attrKeyOrder copy];

    for(NSString* key in attrKeyOrderCopy)
    {
        NSString* value = attr[key];
        if(!value)
            return;
        
        [context registerWithName:@"CurrentAttr" ref:key];
        
        // call the definition
        if (defs[key])
        {
            // there is a local definition defined
            if ([defs[key] isEqual:@NO])
            {
                // We've explicitly been told not to allow this element.
                // This is usually when there's a global definition
                // that must be overridden.
                // Theoretically speaking, we could have a
                // AttrDef_DenyAll, but this is faster!
                result = nil;
            }
            else
            {
                // validate according to the element's definition
                result = [(HTMLPurifier_AttrDef*)defs[key] validateWithString:value config:config context:context];
            }
        }
        else if (d_defs[key])
        {
            // there is a global definition defined, validate according
            // to the global definition
            result = [(HTMLPurifier_AttrDef*)d_defs[key] validateWithString:value config:config context:context];

        }
        else
        {
            // system never heard of the attribute? DELETE!
            result = nil;
        }

        // put the results into effect
        if (!result)
        {
            TRIGGER_ERROR(@"AttrValidator: Attribute '%@' removed on tag '%@'", key, token.name);

            // remove the attribute

            if([attrKeyOrder containsObject:key])
                [attrKeyOrder removeObject:key];
            [attr removeObjectForKey:key];
        }
        else if (result)
        {
            // generally, if a substitution is happening, there
            // was some sort of implicit correction going on. We'll
            // delegate it to the attribute classes to say exactly what.

            // simple substitution
            attr[key] = result;
        } else {
            // nothing happens
        }

        // we'd also want slightly more complicated substitution
        // involving an array as the return value,
        // although we're not sure how colliding attributes would
        // resolve (certain ones would be completely overriden,
        // others would prepend themselves).
        [context destroy:@"CurrentAttr"];
        [context registerWithName:@"CurrentAttr" ref:@NO];
    }

    [context destroy:@"CurrentAttr"];

    // post transforms


     // global
     for(HTMLPurifier_AttrTransform* transform in definition.info_attr_transform_post.allValues)
     {
                                NSMutableDictionary* attrCopy = [attr copy];
                                attr = [[transform transform:attr sortedKeys:attrKeyOrder config:config context:context] mutableCopy];
                                if (![attr isEqual:attrCopy]) {
                                    TRIGGER_ERROR(@"AttrValidator: Attributes transformed %@ -> %@", attrCopy, attr);
                                }
     }

     // local
     for(HTMLPurifier_AttrTransform* transform in [definition.info[token.name] attr_transform_post].allValues)
     {
                                NSMutableDictionary* attrCopy = [attr copy];
                                attr = [[transform transform:attr sortedKeys:attrKeyOrder config:config context:context] mutableCopy];
                                if (![attr isEqual:attrCopy]) {
                                    TRIGGER_ERROR(@"AttrValidator: Attributes transformed %@ -> %@", attrCopy, attr);
                                }
     }

    [token setAttr:attr];

    [token setSortedAttrKeys:attrKeyOrder];

    // destroy CurrentToken if we made it ourselves
    if (!current_token || [current_token isEqual:@NO])
    {
        [context destroy:@"CurrentToken"];
    }
}



@end
