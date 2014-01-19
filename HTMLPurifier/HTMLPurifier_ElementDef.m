//
//  HTMLPurifier_ElementDef.m
//  HTMLPurifier
//
//  Created by Roman Priebe on 14.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_ElementDef.h"
#import "BasicPHP.h"

@implementation HTMLPurifier_ElementDef


- (id)init
{
    self = [super init];
    if (self) {
        _standalone = YES;
        _attr = [NSMutableDictionary new];
        _attr_transform_post = [NSMutableDictionary new];
        _attr_transform_pre = [NSMutableDictionary new];
        _descendants_are_inline = NO;
        _required_attr = [NSMutableArray new];
        _excludes = [NSMutableSet new];
        _autoclose = [NSMutableArray new];
    }
    return self;
}

    /**
     * Low-level factory constructor for creating new standalone element defs
     */
+ (HTMLPurifier_ElementDef*)create:(NSString*)content_model contentModelType:(NSString*)content_model_type attr:(NSDictionary*)attr
    {
        HTMLPurifier_ElementDef* def = [HTMLPurifier_ElementDef new];
        def.content_model = content_model;
        def.content_model_type = content_model_type;
        def.attr = [attr mutableCopy];
        return def;
    }

    /**
     * Merges the values of another element definition into this one.
     * Values from the new element def take precedence if a value is
     * not mergeable.
     * @param HTMLPurifier_ElementDef $def
     */
- (void)mergeIn:(HTMLPurifier_ElementDef*)def
    {
        for(id<NSCopying> key in def.attr)
        {
            if([(NSObject*)key isEqual:@0])
            {
                NSArray* v = def.attr[key];
                if(v)
                    for(NSObject* v2 in v)
                    {
                        if(self.attr[@0])
                            self.attr[@0] = [self.attr[@0] arrayByAddingObject:v2];
                        else
                            self.attr[@0] = v2;
                    }
                    continue;
            }
            NSObject* v = def.attr[key];
            if([v isEqual:@NO])
            {
                if(self.attr[key])
                    [self.attr removeObjectForKey:key];
                continue;
            }
            self.attr[key] = v;
        }

        [self.excludes unionSet:def.excludes];
        [self _mergeIntoAssocArray:self.attr_transform_pre from:def.attr_transform_pre];
        [self _mergeIntoAssocArray:self.attr_transform_post from:def.attr_transform_post];

        if (def.content_model.length>0) {
            self.content_model = [def.content_model stringByReplacingOccurrencesOfString:@"#SUPER" withString:self.content_model];
            self.child = NO;
        }
        if ([def.content_model_type length]>0) {
            self.content_model_type = def.content_model_type;
            self.child = false;
        }
        if (def.child) {
            self.child = def.child;
        }
        if (def.formatting) {
            self.formatting = def.formatting;
        }
        if (def.descendants_are_inline) {
            self.descendants_are_inline = def.descendants_are_inline;
        }
    }

    /**
     * Merges one array into another, removes values which equal false
     * @param $a1 Array by reference that is merged into
     * @param $a2 Array that merges into $a1
     */
- (void) _mergeIntoAssocArray:(NSMutableDictionary*)a1 from:(NSMutableDictionary*)a2
    {
        for(id<NSCopying> key in a2.allKeys)
        {
            NSObject* value = a2[key];
            if([value isEqual:@NO])
            {
                if(a1[key])
                    [a1 removeObjectForKey:key];
                continue;
            }
            if(value)
                 a1[key] = value;
        }
    }


- (id)copyWithZone:(NSZone *)zone
{
    HTMLPurifier_ElementDef* newElementDef = [[[self class] allocWithZone:zone] init];

    [newElementDef setAttr:self.attr];
    [newElementDef setAttr_transform_post:self.attr_transform_post];
    [newElementDef setAttr_transform_pre:self.attr_transform_pre];
    [newElementDef setChild:self.child];
    [newElementDef setContent_model:self.content_model];
    [newElementDef setContent_model_type:self.content_model_type];
    [newElementDef setDescendants_are_inline:self.descendants_are_inline];
    [newElementDef setExcludes:self.excludes];
    [newElementDef setFormatting:self.formatting];
    [newElementDef setRequired_attr:self.required_attr];
    [newElementDef setStandalone:self.standalone];
    [newElementDef setWrap:self.wrap];

    return newElementDef;
}


@end
