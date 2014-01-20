//
//  HTMLPurifier_AttrCollections.m
//  HTMLPurifier
//
//  Created by Roman Priebe on 19.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_AttrCollections.h"
#import "HTMLPurifier_HTMLModule.h"
#import "BasicPHP.h"
#import "HTMLPurifier_AttrTypes.h"
#import "HTMLPurifier_ElementDef.h"
#import "HTMLPurifier_AttrDef.h"


/**
 * Defines common attribute collections that modules reference
 */
@implementation HTMLPurifier_AttrCollections


- (id)initWithAttrTypes:(HTMLPurifier_AttrTypes*)attr_types modules:(NSDictionary*)modules
{
    self = [super init];
    if (self) {
        _info = [NSMutableDictionary new];

        // load extensions from the modules
        for(HTMLPurifier_HTMLModule* module in modules.allValues)
        {
            for(NSString* coll_i in module.attr_collections)
        {
            NSDictionary* coll = module.attr_collections[coll_i];
            if(!self.info[coll_i])
                self.info[coll_i] = [NSMutableDictionary new];
            for(NSNumber* attr_i in coll)
            {
                NSObject* attr = coll[attr_i];

                //NSMutableDictionary*

                if([attr_i isEqual:@0] && self.info[coll_i][attr_i])
                {
                    if([attr isKindOfClass:[NSArray class]])
                        self.info[coll_i][attr_i] = [self.info[coll_i][attr_i] arrayByAddingObjectsFromArray:(NSArray*)attr];
                    else
                        self.info[coll_i][attr_i] = [self.info[coll_i][attr_i] arrayByAddingObject:attr];
                    continue;
                }
                if([attr isKindOfClass:[NSArray class]])
                    self.info[coll_i][attr_i] = attr;
                else
                    self.info[coll_i][attr_i] = @[attr];
            }
        }
        }

        // perform internal expansions and inclusions
        for(NSString* name in self.info)
        {
            //NSDictionary* attr = self.info[name];

            // merge attribute collections that include others
            [self performInclusions:self.info[name]];
            // replace string identifiers with actual attribute objects
            [self expandIdentifiers:self.info[name] attrTypes:attr_types];
        }

    }
    return self;
}

- (id)init
{
    return [self initWithAttrTypes:nil modules:nil];
}

    /**
     * Takes a reference to an attribute associative array and performs
     * all inclusions specified by the zero index.
     * @param array &$attr Reference to attribute array
     */
- (void)performInclusions:(NSMutableDictionary*)attr
    {
        if (!attr[@0]) {
            return;
        }
        NSMutableArray* merge = [attr[@0] mutableCopy];
        NSMutableSet* seen  = [NSMutableSet new]; // recursion guard
                          // loop through all the inclusions
        for (NSInteger i = 0; i<merge.count; i++)
        {
            if ([seen containsObject:merge[i]])
            {
                continue;
            }
            [seen addObject:merge[i]];
            // foreach attribute of the inclusion, copy it over
            if (!self.info[merge[i]])
            {
                continue;
            }
            for(NSString* key in self.info[merge[i]])
            {
                NSObject* value = self.info[merge[i]][key];
                if (attr[key])
                {
                    continue;
                } // also catches more inclusions
                attr[key] = value;
            }

            if ([self.info[merge[i]] isKindOfClass:[NSDictionary class]] && self.info[merge[i]][@0])
            {
                // recursion
                [merge addObjectsFromArray:self.info[merge[i]][@0]];
                attr[@0] = merge;
            }
        }
        [attr removeObjectForKey:@0];
    }

    /**
     * Expands all string identifiers in an attribute array by replacing
     * them with the appropriate values inside HTMLPurifier_AttrTypes
     * @param array &$attr Reference to attribute array
     * @param HTMLPurifier_AttrTypes $attr_types HTMLPurifier_AttrTypes instance
     */
- (void)expandIdentifiers:(NSMutableDictionary*)attr attrTypes:(HTMLPurifier_AttrTypes*)attr_types
    {
        // because foreach will process new elements we add, make sure we
        // skip duplicates
        NSMutableSet* processed = [NSMutableSet new];

        //while there are unprocessed objects in attr
        while(processed.count<[processed setByAddingObjectsFromArray:attr.allKeys].count)
        {
        NSArray* allKeys = attr.allKeys;
        for(NSString* def_i in allKeys)
        {
            NSObject* def = attr[def_i];
            if([def isKindOfClass:[NSArray class]] && [(NSArray*)def count]>0)
                def = [(NSArray*)def objectAtIndex:0];

            // skip inclusions
            if ([def_i isEqual:@0])
            {
                continue;
            }

            if ([processed containsObject:def_i])
            {
                continue;
            }

            // determine whether or not attribute is required
            BOOL required = (strpos(def_i, @"*") != NSNotFound);
            if (required) {
                // rename the definition
                [attr removeObjectForKey:def_i];
                NSString* new_def_i = trimWithFormat(def_i, @"*");
                attr[new_def_i] = def;
            }

            [processed addObject:def_i];

            // if we've already got a literal object, move on
            if ([def isKindOfClass:[HTMLPurifier_AttrDef class]])
            {
                // preserve previous required
                [(HTMLPurifier_AttrDef*)def setRequired:(required || [(HTMLPurifier_AttrDef*)def required])];
                continue;
            }

            if (!def || [def isEqual:@NO])
            {
                [attr removeObjectForKey:def_i];
                continue;
            }

            HTMLPurifier_AttrDef* t = [attr_types get:(NSString*)def];
            if(t)
            {
                attr[def_i] = t;
                [(HTMLPurifier_AttrDef*)attr[def_i] setRequired:required];
            }
            else
            {
                [attr removeObjectForKey:def_i];
            }
        }
        }
    }




@end
