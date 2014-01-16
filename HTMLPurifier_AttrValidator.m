//
//  HTMLPurifier_AttrValidator.m
//  HTMLPurifier
//
//  Created by Roman Priebe on 16.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

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
//#import "HTMLPurifier_Transform.h"
#import "BasicPHP.h"


@implementation HTMLPurifier_AttrValidator


- (void)validateToken:(HTMLPurifier_Token*)token config:(HTMLPurifier_Config*)config  context:(HTMLPurifier_Context*)context
{
    HTMLPurifier_HTMLDefinition* definition = [config getHTMLDefinition];

    // initialize IDAccumulator if necessary

    NSNumber* ok = (NSNumber*)[context getWithName:@"IDAccumulator" ignoreError:YES];
    if (!ok.boolValue) {
        HTMLPurifier_IDAccumulator* id_accumulator = [HTMLPurifier_IDAccumulator buildWithConfig:config context:context];
        [context registerWithName:@"IDAccumulator" ref:id_accumulator];
    }

    // initialize CurrentToken if necessary
    HTMLPurifier_Token* current_token = (HTMLPurifier_Token*)[context getWithName:@"CurrentToken" ignoreError:YES];
    if (!current_token) {
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
    NSMutableDictionary* attr = [[token valueForKey:@"attr"] mutableCopy];

    /*
     // do global transformations (pre)
     // nothing currently utilizes this
     for(HTMLPurifier_Transform*
     definition info_attr_transform_pre as transform) {
     attr = transform transform(o = attr, config, context];
     if (e) {
     if (attr != o) {
     e send(E_NOTICE, 'AttrValidator: Attributes transformed', o, attr];
     }
     }
     }*/

    // do local transformations only applicable to this element (pre)
    // ex. <p align="right"> to <p style="text-align:right;">
    /*
     for(HTMLPurifier_Transform* transform in [(HTMLPurifier_ElementDef*)definition.info[[token valueForKey:@"name"]] attr_transform_pre])
     {
     attr = [transform transform:o = attr, config, context];
     if (e) {
     if (attr != o) {
     e send(E_NOTICE, 'AttrValidator: Attributes transformed', o, attr];
     }
     }
     }*/

    // create alias to this element's attribute definition array, see
    // also d_defs (global attribute definition array)
    // DEFINITION CALL
    NSMutableDictionary* defs = [definition.info[[token valueForKey:@"name"]] attr];

    NSString* result = nil;

    NSNumber* attr_key = @NO;
    [context registerWithName:@"CurrentAttr" ref:attr_key];

    // iterate through all the attribute keypairs

    NSArray* allAttrKeys = attr.allKeys;

    for(NSString* key in allAttrKeys)
    {
        NSString* value = attr[key];

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
            TRIGGER_ERROR(@"AttrValidator: Attribute removed");

            // remove the attribute

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
    }

    [context destroy:@"CurrentAttr"];

    // post transforms

    /*
     // global (error reporting untested)
     for(definition info_attr_transform_post as transform) {
     attr = transform transform(o = attr, config, context];
     if (e) {
     if (attr != o) {
     e send(E_NOTICE, 'AttrValidator: Attributes transformed', o, attr];
     }
     }
     }*/
    /*
     for(HTMLPurifier_Transform* transform in [(HTMLPurifier_ElementDef*)definition.info[[token valueForKey:@"name"]] attr_transform_pre])
     {
     attr = [transform transform:o = attr, config, context];
     if (e) {
     if (attr != o) {
     e send(E_NOTICE, 'AttrValidator: Attributes transformed', o, attr];
     }
     }
     }

     // local (error reporting untested)
     for(
     definition info[token name] attr_transform_post as transform) {
     attr = transform transform(o = attr, config, context];
     if (e) {
     if (attr != o) {
     e send(E_NOTICE, 'AttrValidator: Attributes transformed', o, attr];
     }
     }
     }*/

    [token setAttr:attr];

    // destroy CurrentToken if we made it ourselves
    if (!current_token) {
        [context destroy:@"CurrentToken"];
    }
}



@end
