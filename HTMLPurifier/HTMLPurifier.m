//
//  HTMLPurifier.m
//  HTMLPurifier
//
//  Created by Lukas Neumann on 10.01.14.

/*
 * HTML Purifier is an HTML filter that will take an arbitrary snippet of
 * HTML and rigorously test, validate and filter it into a version that
 * is safe for output onto webpages. It achieves this by:
 *
 *  -# Lexing (parsing into tokens) the document,
 *  -# Executing various strategies on the tokens:
 *      -# Removing all elements not in the whitelist,
 *      -# Making the tokens well-formed,
 *      -# Fixing the nesting of the nodes, and
 *      -# Validating attributes of the nodes; and
 *  -# Generating HTML from the purified tokens.
 *
 * However, most users will only need to interface with the HTMLPurifier
 * and HTMLPurifier_Config.
 */

/*
 HTML Purifier for PHP 4.6.0 - Standards Compliant HTML Filtering
 Copyright (C) 2006-2008 Edward Z. Yang
 
 HTML Purifier for Objective-c - Standards Compliant HTML Filtering
 Copyright (c) 2014 Mynigma.
 
 This library is free software; you can redistribute it and/or
 modify it under the terms of the GNU Lesser General Public
 License as published by the Free Software Foundation; either
 version 2.1 of the License, or (at your option) any later version.
 
 This library is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 Lesser General Public License for more details.
 
 You should have received a copy of the GNU Lesser General Public
 License along with this library; if not, write to the Free Software
 Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 */

#import "HTMLPurifier.h"
#import "HTMLPurifier_Config.h"
#import "HTMLPurifier_Strategy_Core.h"
#import "HTMLPurifier_Generator.h"
#import "HTMLPurifier_Context.h"
#import "HTMLPurifier_Filter.h"
#import "HTMLPurifier_Lexer.h"
#import "HTMLPurifier_LanguageFactory.h"
#import "HTMLPurifier_Language.h"
#import "HTMLPurifier_ErrorCollector.h"
#import "HTMLPurifier_IDAccumulator.h"

@implementation HTMLPurifier

/**
 * Global configuration object.
 */
@synthesize config;

/**
 * Array of extra filter objects to run on HTML,
 * for backwards compatibility.
 */
@synthesize filters;

/**
 * @type HTMLPurifier_Strategy_Core
 */
@synthesize strategy;

/**
 * @type HTMLPurifier_Generator
 */
@synthesize generator;

/**
 * Resultant context of last run purification.
 * Is an array of contexts if the last called method was purifyArray().
 */
@synthesize context;


/**
 * Initializes the purifier.
 *
 * @param HTMLPurifier_Config $config Optional HTMLPurifier_Config object
 *                for all instances of the purifier, if omitted, a default
 *                configuration is supplied (which can be overridden on a
 *                per-use basis).
 *                The parameter can also be any type that
 *                HTMLPurifier_Config create() supports.
 */
- (id)initWithConfig:(HTMLPurifier_Config*) newConfig
{
    self = [super init];
    if (self) {
        config = [HTMLPurifier_Config create:newConfig];
        strategy = [HTMLPurifier_Strategy_Core new];
    }
    return self;
}

- (id) init
{
    return [self initWithConfig:nil];
}

/**
 * Deprecated
 *
 * Adds a filter to process the output. First come first serve
 *
 * @param HTMLPurifier_Filter $filter HTMLPurifier_Filter object
 *
- (void)addFilter:(HTMLPurifier_Filter*)filter
{
}
*/

/**
 * Filters an HTML snippet/document to be XSS-free and standards-compliant.
 *
 * @param string $html String of HTML to purify
 * default config object specified during this
 * object's construction.  
 *
 * @return string Purified HTML
 */
- (NSString*) purifyWith:(NSString*)newHtml
{
    
    NSString* html = newHtml;
    
    //Create Config
    config = [HTMLPurifier_Config create:nil];
    
    //New Lexer with Config
    HTMLPurifier_Lexer* lexer = [HTMLPurifier_Lexer alloc];
    lexer = [HTMLPurifier_Lexer initWithConfig:config];
    
    //New Context
    context = [HTMLPurifier_Context new];
    
    //setup HTML generator
    generator = [HTMLPurifier_Generator alloc];
    generator = [HTMLPurifier_Generator initWithConfig:config Context:context];
    [context registerWithName:@"Generator" ref:generator];
    
    //setup global context variables
    if ([config getWithKey:@"Core.CollectErrors"])
    {
        
        HTMLPurifier_LanguageFactory* language_factory = [HTMLPurifier_LanguageFactory instance];
        HTMLPurifier_Language* language = [language_factory createWithConfig: config Context: context];
        [context registerWithName:@"Locale" ref:language];
        
        HTMLPurifier_ErrorCollector* error_collector = [HTMLPurifier_ErrorCollector alloc];
        error_collector = [HTMLPurifier_ErrorCollector initWithContext:context];
        [context registerWithName:@"ErrorCollector" ref:error_collector];
    }
    
    // setup id_accumulator context, necessary due to the fact that AttrValidator can be called from many places
    HTMLPurifier_IDAccumulator* id_accumulator = [HTMLPurifier_IDAccumulator buildWithConfig:config Context:context];
    [context registerWithName:@"IDAccumulator" ref:id_accumulator];
    
    html = [HTMLPurifier_Encoder convertToUTF8WithHtml:html Config:config Context:context];
    
    // setup filters
    
    NSMutableDictionary* filter_flags = [config getBatchWithNamespace:@"Filter"];
    NSMutableArray* custom_filters = [filter_flags objectForKey:@"Custom"];
    [filter_flags removeObjectForKey:@"Custom"];
    
    NSMutableArray* newFilters = [NSMutableArray new];
    
    for (NSString* key in filter_flags.allKeys)
    {
        if ([filter_flags objectForKey:key])
        {
            //This cannot happen
            continue;
        }
        
        if (strpos(key,@".") != NO){
            continue
        }
        
        NSString* class = [@"HTMLPurifier_Filter_" stringByAppendingString:key];
        
        [newFilters addObject:[NSClassFromString(class) new]];
    }
    
    for (NSObject* object in custom_filters)
    {
        [newFilters addObject:object];
    }
    
    [newFilters addObjectsFromArray:filters];
    
    for (i=0,)
    
    
}


/**
 * Filters an HTML snippet/document to be XSS-free and standards-compliant.
 *
 * @param string $html String of HTML to purify
 * @param HTMLPurifier_Config $config Config object for this operation. 
 *
 * @return string Purified HTML
 */
- (NSString*) purifyWith:(NSString*)html Config:(HTMLPurifier_Config*)newConfig
{
    config = newConfig;

}

@end
