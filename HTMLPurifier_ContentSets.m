//
//  HTMLPurifier_ContentSets.m
//  HTMLPurifier
//
//  Created by Roman Priebe on 19.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_ContentSets.h"
#import "HTMLPurifier_HTMLModule.h"
#import "BasicPHP.h"
#import "HTMLPurifier_ChildDef_Optional.h"
#import "HTMLPurifier_ChildDef_Custom.h"
#import "HTMLPurifier_ChildDef_Required.h"
#import "HTMLPurifier_ChildDef_Empty.h"
#import "HTMLPurifier_ElementDef.h"
#import "HTMLPurifier_ChildDef.h"



@implementation HTMLPurifier_ContentSets




/**
 * Merges in module's content sets, expands identifiers in the content
 * sets and populates the keys, values and lookup member variables.
 * @param HTMLPurifier_HTMLModule[] $modules List of HTMLPurifier_HTMLModule
 */
- (id)initWithModules:(NSObject*)modules
{
    self = [super init];
    if (self) {
        _info = [NSMutableDictionary new];
        _lookup = [NSMutableDictionary new];

        _keys = [NSMutableSet new];
        _values = [NSMutableSet new];

        if(![modules isKindOfClass:[NSArray class]])
            modules = @[modules];
        for(HTMLPurifier_HTMLModule* module in (NSArray*)modules)
        {
            for(NSString* key in module.content_sets)
            {
                NSString* value = module.content_sets[key];
                NSSet* temp = [self convertToLookup:value];
                if(self.lookup[key])
                {
                    self.lookup[key] = [self.lookup[key] setByAddingObjectsFromSet:temp];
                }
                else
                {
                    self.lookup[key] = temp;
                }
            }
        }

        NSObject* old_lookup = @NO;
        while(![old_lookup isEqual:self.lookup])
        {
            old_lookup = self.lookup;
            for(NSString* i in self.lookup)
            {
                NSDictionary* set = self.lookup[i];
                NSMutableArray* add = [NSMutableArray new];
                for(NSString* element in set)
                {
                    if(self.lookup[element])
                    {
                        [add addObject:self.lookup[element]];
                        [self.lookup[i] removeObjectForKey:element];
                    }
                }
                self.lookup[i] = [self.lookup[i] setByAddingObject:add];
            }
        }

        for(NSString* key in self.lookup)
        {
            NSSet* lookup = self.lookup[key];
            self.info[key] = implode(@" | ", [lookup allObjects]);
        }

        self.keys = [NSMutableSet setWithArray:self.info.allKeys];
        self.values = [NSMutableSet setWithArray:self.info.allValues];
    }
    return self;
}


/**
 * Accepts a definition; generates and assigns a ChildDef for it
 * @param HTMLPurifier_ElementDef $def HTMLPurifier_ElementDef reference
 * @param HTMLPurifier_HTMLModule $module Module that defined the ElementDef
 */
- (void)generateChildDef:(HTMLPurifier_ElementDef*)def module:(HTMLPurifier_HTMLModule*)module
{
    if (def.child)
    { // already done!
        return;
    }
    NSString* content_model = def.content_model;
    if ([content_model isKindOfClass:[NSString class]])
    {
        // Assume that $this->keys is alphanumeric
        def.content_model = [BasicPHP pregReplace:[NSString stringWithFormat:@"\b(' %@ ')\b", implode(@"|", [self.keys allObjects])] callback:^(NSArray* matches){
            return [self generateChildDefCallback:matches];
        } haystack:content_model];

        //$def->content_model = str_replace(
        //    $this->keys, $this->values, $content_model);
    }
    def.child = [self getChildDef:def module:module];
}

- (NSString*)generateChildDefCallback:(NSArray*)matches
{
    return self.info[matches[0]];
}

/**
 * Instantiates a ChildDef based on content_model and content_model_type
 * member variables in HTMLPurifier_ElementDef
 * @note This will also defer to modules for custom HTMLPurifier_ChildDef
 *       subclasses that need content set expansion
 * @param HTMLPurifier_ElementDef $def HTMLPurifier_ElementDef to have ChildDef extracted
 * @param HTMLPurifier_HTMLModule $module Module that defined the ElementDef
 * @return HTMLPurifier_ChildDef corresponding to ElementDef
 */
- (NSObject*)getChildDef:(HTMLPurifier_ElementDef*)def module:(HTMLPurifier_HTMLModule*)module
{
    NSString* value = def.content_model;
    if (value && ![value isKindOfClass:[NSString class]])
    {
        TRIGGER_ERROR(@"Literal object child definitions should be stored in ElementDef->child not ElementDef->content_model");
        return value;
    }
    if([def.content_model_type isEqual:@"required"])
        return [[HTMLPurifier_ChildDef_Required alloc] initWithElements:value];
    if([def.content_model_type isEqual:@"optional"])
        return [[HTMLPurifier_ChildDef_Optional alloc] initWithElements:value];
    if([def.content_model_type isEqual:@"empty"])
        return [HTMLPurifier_ChildDef_Empty new];
    if([def.content_model_type isEqual:@"custom"])
        return [[HTMLPurifier_ChildDef_Custom alloc] initWithDtdRegex:value];

    // defer to its module
    HTMLPurifier_ChildDef* returnValue = nil;
    if (module.defines_child_def)
    { // save a func call
        returnValue = [module getChildDef:def];
    }

    if(returnValue)
    {
        return returnValue;
    }
    // error-out

    TRIGGER_ERROR(@"Could not determine which ChildDef class to instantiate");
    return nil;
}

/**
 * Converts a string list of elements separated by pipes into
 * a lookup array.
 * @param string $string List of elements
 * @return array Lookup array of elements
 */
- (NSSet*)convertToLookup:(NSString*)string
{
    NSArray* array = explode(@"|", [string stringByReplacingOccurrencesOfString:@" " withString:@""]);
    NSMutableSet* ret = [NSMutableSet new];
    for(NSString* k in array)
    {
        [ret addObject:k];
    }
    return ret;
}


@end
