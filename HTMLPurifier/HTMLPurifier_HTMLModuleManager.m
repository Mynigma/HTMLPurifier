//
//  HTMLPurifier_HTMLModuleManager.m
//  HTMLPurifier
//
//  Created by Roman Priebe on 14.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_HTMLModuleManager.h"
#import "HTMLPurifier_Doctype.h"
#import "HTMLPurifier_DoctypeRegistry.h"
#import "HTMLPurifier_HTMLModule.h"
#import "HTMLPurifier_Injector.h"
#import "HTMLPurifier_AttrTypes.h"
#import "HTMLPurifier_ElementDef.h"
#import "HTMLPurifier_Config.h"
#import "HTMLPurifier_HTMLModule.h"
#import "BasicPHP.h"
#import "HTMLPurifier_Context.h"
#import "HTMLPurifier_ContentSets.h"
#import "HTMLPurifier_AttrCollections.h"
#import "HTMLPurifier_AttrDef.h"



@implementation HTMLPurifier_HTMLModuleManager

- (id)init
{
    self = [super init];
    if (self) {
        _modules = [NSMutableDictionary new];
        _registeredModules = [NSMutableDictionary new];
        _trusted = NO;

        
        _attrTypes = [HTMLPurifier_AttrTypes new];
        _doctypes = [HTMLPurifier_DoctypeRegistry new];

        _userModules = [NSMutableArray new];
        _elementLookup = [NSMutableDictionary new];
        _prefixes = [NSMutableArray arrayWithObject:@"HTMLPurifier_HTMLModule_"];

        // setup basic modules
        NSArray* common = @[@"CommonAttributes", @"Text", @"Hypertext", @"List", @"Presentation", @"Edit", @"Bdo", @"Tables", @"Image", @"StyleAttribute", /* Unsafe: */ @"Scripting", @"Object", @"Forms", /* Sorta legacy, but present in strict: */ @"Name"];

        NSArray* transitional = @[@"Legacy", @"Target", @"Iframe"];

        NSArray* xml = @[@"XMLAttributes"];
        NSArray* non_xml = @[@"NonXMLAttributes"];

        // setup basic doctypes
        [_doctypes registerDoctype:@"HTML 4.01 Transitional" xml:NO modules:[[common arrayByAddingObjectsFromArray:transitional] arrayByAddingObjectsFromArray:non_xml] tidy_modules:@[@"Tidy_Transitional", @"Tidy_Proprietary"] aliases:@[] dtdPublic:@"-//W3C//DTD HTML 4.01 Transitional//EN" dtdSystem:@"http://www.w3.org/TR/html4/loose.dtd"];


        [_doctypes registerDoctype:@"HTML 4.01 Strict" xml:NO modules:[common arrayByAddingObjectsFromArray:non_xml] tidy_modules:@[@"Tidy_Strict", @"Tidy_Proprietary", @"Tidy_Name"] aliases:@[] dtdPublic:@"-//W3C//DTD HTML 4.01//EN" dtdSystem:@"http://www.w3.org/TR/html4/strict.dtd"];

        [_doctypes registerDoctype:@"XHTML 1.0 Transitional" xml:YES modules:[[[common arrayByAddingObjectsFromArray:transitional] arrayByAddingObjectsFromArray:xml] arrayByAddingObjectsFromArray:non_xml] tidy_modules:@[@"Tidy_Transitional", @"Tidy_XHTML", @"Tidy_Proprietary", @"Tidy_Name"] aliases:@[] dtdPublic:@"-//W3C//DTD XHTML 1.0 Transitional//EN" dtdSystem:@"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"];

        [_doctypes registerDoctype:@"XHTML 1.0 Strict" xml:YES modules:[[common arrayByAddingObjectsFromArray:xml] arrayByAddingObjectsFromArray:non_xml] tidy_modules:@[@"Tidy_Strict", @"Tidy_XHTML", @"Tidy_Strict", @"Tidy_Proprietary", @"Tidy_Name"] aliases:@[] dtdPublic:@"-//W3C//DTD XHTML 1.0 Strict//EN" dtdSystem:@"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"];

        [_doctypes registerDoctype:@"XHTML 1.1" xml:YES modules:[[common arrayByAddingObjectsFromArray:xml] arrayByAddingObjectsFromArray:@[@"Ruby", @"Iframe"]] tidy_modules:@[@"Tidy_Strict", @"Tidy_XHTML", @"Tidy_Proprietary", @"Tidy_Strict", @"Tidy_Name"] aliases:@[] dtdPublic:@"-//W3C//DTD XHTML 1.1//EN" dtdSystem:@"http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd"];
    }
    return self;
}

/**
 * Registers a module to the recognized module list, useful for
 * overloading pre-existing modules.
 * @param $module Mixed: string module name, with or without
 *                HTMLPurifier_HTMLModule prefix, or instance of
 *                subclass of HTMLPurifier_HTMLModule.
 * @param $overload Boolean whether or not to overload previous modules.
 *                  If this is not set, and you do overload a module,
 *                  HTML Purifier will complain with a warning.
 * @note This function will not call autoload, you must instantiate
 *       (and thus invoke) autoload outside the method.
 * @note If a string is passed as a module name, different variants
 *       will be tested in this order:
 *          - Check for HTMLPurifier_HTMLModule_$name
 *          - Check all prefixes with $name in order they were added
 *          - Check for literal object name
 *          - Throw fatal error
 *       If your object name collides with an internal class, specify
 *       your module manually. All modules must have been included
 *       externally: registerModule will not perform inclusions for you!
 */
- (NSString*)registerModule:(NSObject*)module
{
    return [self registerModule:module overload:NO];
}

- (NSString*)registerModule:(NSObject*)module overload:(BOOL)overload
{
    HTMLPurifier_HTMLModule* htmlModule = nil;
    if ([module isKindOfClass:[NSString class]])
    {
        // attempt to load the module
        //NSString* original_module = (NSString*)module;
        BOOL ok = NO;
        for(NSString* prefix in self.prefixes)
            {
            module = [prefix stringByAppendingString:(NSString*)module];
            if (NSClassFromString((NSString*)module))
            {
                ok = YES;
                break;
            }
        }
        if (!ok)
        {
            //module = original_module;
            if (!NSClassFromString((NSString*)module))
            {
                TRIGGER_ERROR(@"%@ module does not exist", module);
                return nil;
            }
        }
        htmlModule = [NSClassFromString((NSString*)module) new];
    }
    if (![htmlModule name])
    {
        TRIGGER_ERROR(@"Module instance of %@ must have name", module);
        return nil;
    }
    if (!overload && self.registeredModules[[htmlModule name]])
    {
        TRIGGER_ERROR(@"Overloading %@ without explicit overload parameter", module);
    }
    self.registeredModules[[htmlModule name]] = htmlModule;

    return [htmlModule name];
}

/**
 * Adds a module to the current doctype by first registering it,
 * and then tacking it on to the active doctype
 */
- (void)addModule:(NSObject*)module
{
    [self registerModule:module];
    if ([module isKindOfClass:[HTMLPurifier_HTMLModule class]])
    {
        module = [(HTMLPurifier_HTMLModule*)module name];
    }
    [self.userModules addObject:module];
}

/**
 * Adds a class prefix that registerModule() will use to resolve a
 * string name to a concrete class
 */
- (void)addPrefix:(NSString*)prefix
{
    [self.prefixes addObject:prefix];
}

/**
 * Performs processing on modules, after being called you may
 * use getElement() and getElements()
 * @param HTMLPurifier_Config $config
 */
- (void)setup:(HTMLPurifier_Config*)config
{
    self.trusted = NO; //[config get:@"HTML.Trusted"];

    // generate
    self.doctype = [self.doctypes make:config];
    NSMutableArray* modules = [NSMutableArray new];

    if([self.doctype isKindOfClass:[HTMLPurifier_Doctype class]])
        modules = [[(HTMLPurifier_Doctype*)self.doctype modules] mutableCopy];

    // take out the default modules that aren't allowed
    NSDictionary* lookup = (NSDictionary*)[config get:@"HTML.AllowedModules"];
    NSDictionary* special_cases = (NSDictionary*)[config get:@"HTML.CoreModules"];

    if ([special_cases isKindOfClass:[NSDictionary class]] && [lookup isKindOfClass:[NSDictionary class]])
    {
        NSMutableArray* moduleArray = modules;
        for(NSString* m in moduleArray)
        {
            if (special_cases[m])
            {
                continue;
            }
            if (!lookup[m])
            {
                [moduleArray removeObject:m];
            }
        }
        modules = moduleArray;
    }

    // custom modules
    if ([config get:@"HTML.Proprietary"])
    {
        [modules addObject:@"Proprietary"];
    }
    if ([config get:@"HTML.SafeObject"])
    {
        [modules addObject:@"SafeObject"];
    }
    if ([config get:@"HTML.SafeEmbed"])
    {
        [modules addObject:@"SafeEmbed"];
    }
    if ([config get:@"HTML.SafeScripting"] && ![[config get:@"HTML.SafeScripting"] isEqual:@[]])
    {
        [modules addObject:@"SafeScripting"];
    }
    if ([config get:@"HTML.Nofollow"])
    {
        [modules addObject:@"Nofollow"];
    }
    if ([config get:@"HTML.TargetBlank"])
    {
        [modules addObject:@"TargetBlank"];
    }

    // merge in custom modules
    [modules addObjectsFromArray:self.userModules];

    for(HTMLPurifier_HTMLModule* module in modules)
    {
        [self processModule:module];
        [self.modules[module] setup:config];
    }

    for(HTMLPurifier_HTMLModule* module in [(HTMLPurifier_Doctype*)self.doctype tidyModules])
    {
        [self processModule:module];
        [self.modules[module] setup:config];
    }

    // prepare any injectors
    for(HTMLPurifier_HTMLModule* module in self.modules)
    {
        NSMutableDictionary* n = [NSMutableDictionary new];
        if([module isKindOfClass:[HTMLPurifier_HTMLModule class]])
        {
        for(HTMLPurifier_Injector* injector in module.info_injector.allValues)
        {
            HTMLPurifier_Injector* newInjector = injector;
            if ([injector isKindOfClass:[NSString class]])
            {
                NSString* className = [NSString stringWithFormat:@"HTMLPurifier_Injector_%@", injector];
                newInjector = (HTMLPurifier_Injector*)[NSClassFromString(className) new];
            }
            n[newInjector.name] = newInjector;
        }
        module.info_injector = n;
        }
    }

    // setup lookup table based on all valid modules
    for(HTMLPurifier_HTMLModule* module in self.modules.allValues)
    {
        for(NSString* name in module.info)
        {
            //HTMLPurifier_ElementDef* def = module.info[name];
            if(!self.elementLookup[name])
                self.elementLookup[name] = [NSMutableArray new];
            [self.elementLookup[name] addObject:module.name];
        }
    }

    // note the different choice
    self.contentSets = [[HTMLPurifier_ContentSets alloc] initWithModules:self.modules.allValues];
                                                      // content set assembly deals with all possible modules,
                                                      // not just ones deemed to be "safe"

    self.attrCollections = [[HTMLPurifier_AttrCollections alloc] initWithAttrTypes:self.attrTypes modules:self.modules];
                                                              // there is no way to directly disable a global attribute,
                                                              // but using AllowedAttributes or simply not including
                                                              // the module in your custom doctype should be sufficient
}

/**
 * Takes a module and adds it to the active module collection,
 * registering it if necessary.
 */
- (void)processModule:(HTMLPurifier_HTMLModule*)module
{
    NSString* moduleName = [module isKindOfClass:[HTMLPurifier_HTMLModule class]]?[(HTMLPurifier_HTMLModule*)module name]:(NSString*)module;
    if (!self.registeredModules[moduleName] || [module isKindOfClass:[HTMLPurifier_HTMLModule class]])
    {
        moduleName = [self registerModule:module];
    }
    if(moduleName)
        self.modules[module] = self.registeredModules[moduleName];
}

/**
 * Retrieves merged element definitions.
 * @return Array of HTMLPurifier_ElementDef
 */
- (NSMutableDictionary*)getElements
{
    NSMutableDictionary* elements = [NSMutableDictionary new];
    for(HTMLPurifier_HTMLModule* module in self.modules.allValues)
    {
        if (!self.trusted && !module.safe)
        {
            continue;
        }
        for(NSString* name in module.info)
        {
            if (elements[name])
            {
                continue;
            }
            HTMLPurifier_ElementDef* def = [self getElement:name];
            if(def)
                elements[name] = def;
        }
    }

    // remove dud elements, this happens when an element that
    // appeared to be safe actually wasn't
    for(NSString* n in elements)
    {
        HTMLPurifier_ElementDef* v = elements[n];

        if (!v || [v isEqual:@NO])
        {
            [elements removeObjectForKey:n];
        }
    }

    return elements;
}

/**
 * Retrieves a single merged element definition
 * @param string $name Name of element
 * @param bool $trusted Boolean trusted overriding parameter: set to true
 *                 if you want the full version of an element
 * @return HTMLPurifier_ElementDef Merged HTMLPurifier_ElementDef
 * @note You may notice that modules are getting iterated over twice (once
 *       in getElements() and once here). This
 *       is because
 */
- (HTMLPurifier_ElementDef*)getElement:(NSString*)name
{
    return [self getElement:name trusted:NO];
}

- (HTMLPurifier_ElementDef*)getElement:(NSString*)name trusted:(BOOL)trusted
{
    if (!self.elementLookup[name])
    {
        return nil;
    }

    // setup global state variables
    HTMLPurifier_ElementDef* def = nil;

    // iterate through each module that has registered itself to this
    // element
    for(NSString* module_name in self.elementLookup[name])
    {
        HTMLPurifier_HTMLModule* module = self.modules[module_name];

        // refuse to create/merge from a module that is deemed unsafe--
        // pretend the module doesn't exist--when trusted mode is not on.
        if (!trusted && !module.safe) {
            continue;
        }

        // clone is used because, ideally speaking, the original
        // definition should not be modified. Usually, this will
        // make no difference, but for consistency's sake
        HTMLPurifier_ElementDef* new_def = [module.info[name] copy];

        if (!def && new_def.standalone) {
            def = new_def;
        } else if (def) {
            // This will occur even if $new_def is standalone. In practice,
            // this will usually result in a full replacement.
            [def mergeIn:new_def];
        } else {
            // :TODO:
            // non-standalone definitions that don't have a standalone
            // to merge into could be deferred to the end
            // HOWEVER, it is perfectly valid for a non-standalone
            // definition to lack a standalone definition, even
            // after all processing: this allows us to safely
            // specify extra attributes for elements that may not be
            // enabled all in one place.  In particular, this might
            // be the case for trusted elements.  WARNING: care must
            // be taken that the /extra/ definitions are all safe.
            continue;
        }

        // attribute value expansions
        [self.attrCollections performInclusions:def.attr];
        [self.attrCollections expandIdentifiers:def.attr attrTypes:self.attrTypes];

        // descendants_are_inline, for ChildDef_Chameleon
        if ([def.content_model isKindOfClass:[NSString class]] &&
            strpos(def.content_model, @"Inline") != NSNotFound)
        {
            if (![name isEqual:@"del"] && ![name isEqual:@"ins"])
            {
                // this is for you, ins/del
                def.descendants_are_inline = YES;
            }
        }

        [self.contentSets generateChildDef:def module:module];
    }

    // This can occur if there is a blank definition, but no base to
    // mix it in with
    if (!def) {
        return nil;
    }

    // add information on required attributes
    for(NSString* attr_name in def.attr)
    {
        HTMLPurifier_AttrDef* attr_def = def.attr[attr_name];
        if (attr_def.required)
        {
            [def.required_attr addObject:attr_name];
        }
    }
    return def;
}


@end
