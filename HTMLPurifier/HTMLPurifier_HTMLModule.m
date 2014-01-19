//
//  HTMLPurifier_HTMLModule.m
//  HTMLPurifier
//
//  Created by Roman Priebe on 14.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_HTMLModule.h"
#import "HTMLPurifier_ChildDef.h"
#import "HTMLPurifier_ElementDef.h"

@implementation HTMLPurifier_HTMLModule

- (NSObject*)valueForUndefinedKey:(NSString*)key
{


    return  nil;
}


- (id)init
{
    self = [super init];
    if (self) {
        _name = NSStringFromClass([self class]);

        _elements = [NSMutableArray new];
        _info = [NSMutableDictionary new];
        _attr_collections = [NSMutableDictionary new];
        _content_sets = [NSMutableDictionary new];
        _info_tag_transform = [NSMutableDictionary new];
        _info_attr_transform_pre = [NSMutableArray new];
        _info_attr_transform_post = [NSMutableArray new];
        _info_injector = [NSMutableDictionary new];
        _defines_child_def = NO;
        _safe = YES;
    }
    return self;
}


/**
 * Retrieves a proper HTMLPurifier_ChildDef subclass based on
 * content_model and content_model_type member variables of
 * the HTMLPurifier_ElementDef class. There is a similar function
 * in HTMLPurifier_HTMLDefinition.
 * @param HTMLPurifier_ElementDef $def
 * @return HTMLPurifier_ChildDef subclass
 */
- (HTMLPurifier_ChildDef*)getChildDef:(NSObject*)def
//- (HTMLPurifier_ChildDef*)getChildDef:(HTMLPurifier_HTMLElementDef*)def
{
    return false;
}

// -- Convenience -----------------------------------------------------

/**
 * Convenience function that sets up a new element
 * @param string $element Name of element to add
 * @param string|bool $type What content set should element be registered to?
 *              Set as false to skip this step.
 * @param string $contents Allowed children in form of:
 *              "$content_model_type: $content_model"
 * @param array $attr_includes What attribute collections to register to
 *              element?
 * @param array $attr What unique attributes does the element define?
 * @see HTMLPurifier_ElementDef:: for in-depth descriptions of these parameters.
 * @return HTMLPurifier_ElementDef Created element definition object, so you
 *         can set advanced parameters
 */
- (HTMLPurifier_ElementDef*)addElement:(NSString*)element type:(NSString*)type contents:(NSObject*)contents attrIncludes:(NSObject*)attr_includes attr:(NSDictionary*)attr
{
    [self.elements addObject:element];
    // parse content_model
    NSArray* pair = [self parseContents:contents];
    NSString* content_model_type = nil;
    NSString* content_model = nil;
    if(pair.count>0)
        content_model_type = pair[0];
    if(pair.count>1)
        content_model = pair[1];

    // merge in attribute inclusions
    [self mergeInAttrIncludes:attr attrIncludes:attr_includes];
    // add element to content sets
    if (type)
    {
        [self addElementToContentSet:element type:type];
    }
    // create element
    self.info[element] = [HTMLPurifier_ElementDef create:content_model contentModelType:content_model_type attr:attr];

    // literal object $contents means direct child manipulation
    if ([contents isKindOfClass:[HTMLPurifier_ChildDef class]])
    {
        [(HTMLPurifier_ElementDef*)self.info[element] setChild:(HTMLPurifier_ChildDef*)contents];
    }
    return self.info[element];
}

/**
 * Convenience function that creates a totally blank, non-standalone
 * element.
 * @param string $element Name of element to create
 * @return HTMLPurifier_ElementDef Created element
 */
- (NSObject*)addBlankElement:(NSString*)elementName
//- (HTMLPurifier_ElementDef*)addBlankElement:(NSString*)elementName
{
    return nil;
}

/**
 * Convenience function that registers an element to a content set
 * @param string $element Element to register
 * @param string $type Name content set (warning: case sensitive, usually upper-case
 *        first letter)
 */
- (void)addElementToContentSet:(NSString*)element type:(NSString*)type
{

}

/**
 * Convenience function that transforms single-string contents
 * into separate content model and content model type
 * @param string $contents Allowed children in form of:
 *                  "$content_model_type: $content_model"
 * @return array
 * @note If contents is an object, an array of two nulls will be
 *       returned, and the callee needs to take the original $contents
 *       and use it directly.
 */
- (NSArray*)parseContents:(NSString*)contents
{
    return nil;
}

/**
 * Convenience function that merges a list of attribute includes into
 * an attribute array.
 * @param array $attr Reference to attr array to modify
 * @param array $attr_includes Array of includes / string include to merge in
 */
- (void)mergeInAttrIncludes:(NSMutableDictionary*)attr attrIncludes:(NSDictionary*)attr_includes
{

}

/**
 * Convenience function that generates a lookup table with boolean
 * true as value.
 * @param string $list List of values to turn into a lookup
 * @note You can also pass an arbitrary number of arguments in
 *       place of the regular argument
 * @return array array equivalent of list
 */
- (NSMutableArray*)makeLookup:(NSString*)list
{
    return nil;
}

/**
 * Lazy load construction of the module after determining whether
 * or not it's needed, and also when a finalized configuration object
 * is available.
 * @param HTMLPurifier_Config $config
 */
- (void)setup:(HTMLPurifier_Config*)config
{

}


- (id)copyWithZone:(NSZone *)zone
{
    HTMLPurifier_HTMLModule* newModule = [[[self class] allocWithZone:zone] init];
    [newModule setAttr_collections:self.attr_collections];
    [newModule setChild:self.child];
    [newModule setContent_sets:self.content_sets];
    [newModule setDefines_child_def:self.defines_child_def];
    [newModule setElements:self.elements];
    [newModule setInfo:self.info];
    [newModule setInfo_attr_transform_post:self.info_attr_transform_post];
    [newModule setInfo_attr_transform_pre:self.info_attr_transform_pre];
    [newModule setInfo_injector:self.info_injector];
    [newModule setInfo_tag_transform:self.info_tag_transform];
    [newModule setName:self.name];
    [newModule setSafe:self.safe];

    return newModule;
}

@end
