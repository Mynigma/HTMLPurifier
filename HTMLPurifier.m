//
//   HTMLPurifier.m
//   HTMLPurifier
//
//  Created by Lukas Neumann on 10.01.14.

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
#import "HTMLPurifier_Encoder.h"
#import "BasicPHP.h"



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



static HTMLPurifier* theInstance;

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
        config = [HTMLPurifier_Config createWithConfig:newConfig];
        strategy = [HTMLPurifier_Strategy_Core new];
        context = [NSMutableArray new];
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
- (NSString*) purify:(NSString*)newHtml
{
    return [self purify:newHtml config:nil];
}


/**
 * Filters an HTML snippet/document to be XSS-free and standards-compliant.
 *
 * @param string $html String of HTML to purify
 * @param HTMLPurifier_Config $config Config object for this operation. 
 *
 * @return string Purified HTML
 */
- (NSString*)purify:(NSString*)newHtml config:(HTMLPurifier_Config*)newConfig
{
    
    NSString* html = newHtml;
    
    //Set Config
    config = newConfig?newConfig:[HTMLPurifier_Config createDefault];
    
    //New Lexer with Config
    HTMLPurifier_Lexer* lexer = [HTMLPurifier_Lexer createWithConfig:config];
    
    //New Context
    HTMLPurifier_Context* localContext = [HTMLPurifier_Context new];
    
    //setup HTML generator
    generator = [[HTMLPurifier_Generator alloc] initWithConfig:config context:localContext];
    [localContext registerWithName:@"Generator" ref:generator];


    /*
    //setup global context variables
    if ([config get:@"Core.CollectErrors"])
    {
        HTMLPurifier_LanguageFactory* language_factory = [HTMLPurifier_LanguageFactory instance];
        HTMLPurifier_Language* language = [language_factory create:config context:localContext];
        [localContext registerWithName:@"Locale" ref:language];
    }*/
    
    // setup id_accumulator context, necessary due to the fact that AttrValidator can be called from many places
    HTMLPurifier_IDAccumulator* id_accumulator = [HTMLPurifier_IDAccumulator buildWithConfig:config context:localContext];
    [localContext registerWithName:@"IDAccumulator" ref:id_accumulator];
    
    html = [HTMLPurifier_Encoder convertToUTF8:html config:config context:localContext];
    
    // setup filters
    
    NSMutableDictionary* filter_flags = [[config getBatch:@"Filter"] mutableCopy];
    NSMutableArray* custom_filters = [filter_flags objectForKey:@"Custom"];
    [filter_flags removeObjectForKey:@"Custom"];
    
    NSMutableArray* newFilters = [NSMutableArray new];


    for (NSString* key in filter_flags.allKeys)
    {
        if (![filter_flags objectForKey:key])
        {
            //This cannot happen
            continue;
        }
        
        if (strpos(key,@".") != NSNotFound){
            continue;
        }
        
        NSString* class = [@"HTMLPurifier_Filter_" stringByAppendingString:key];

        HTMLPurifier_Filter* filter = [NSClassFromString(class) new];

        if(filter)
            [newFilters addObject:filter];
    }
    
    for (NSObject* object in custom_filters)
    {
        [newFilters addObject:object];
    }
    
    [newFilters addObjectsFromArray:filters];
    
    NSUInteger filter_size = [newFilters count];
    
    for (int i=0; i<filter_size; i++)
    {
        html = [newFilters[i] preFilter:html config:config context:localContext];
    }
    
    
    
    //TODO maybe change names
    //purifed HTML

    NSMutableArray* tokens = [[lexer tokenizeHTMLWithString:html config:config context:localContext] mutableCopy];

    tokens = [strategy execute:tokens config:config context:localContext];

    html = [generator generateFromTokens:tokens];
    
    for (NSInteger i = filter_size - 1; i>=0; i--)
    {
        html = [filters[i] postFilter:html config:config context:localContext];
    }
    
    html = [HTMLPurifier_Encoder convertFromUTF8:html config:config context:localContext];
    
    [(NSMutableArray*)context addObject:localContext];
    return html;
    
}

/**
 * Filters an array of HTML snippets
 *
 * @param string[] $array_of_html Array of html snippets
 *
 * @return string[] Array of purified HTML
 */
- (NSMutableArray*) purifyArray:(NSArray*)array_of_html
{
    NSMutableArray* context_array = [NSMutableArray new];
    
    NSMutableArray* new_html_array = [NSMutableArray new];
    
    for(NSObject* htmlObject in array_of_html)
    {
        /*if([htmlObject isKindOfClass:[NSDictionary class]])
        {
            for(NSString* htmlValue in [(NSDictionary*)htmlObject allValues])
            {
                if([htmlValue isKindOfClass:[NSString class]])
                {
                    [new_html_array addObject: [self purify:(NSString*)htmlValue]];
                    [context_array addObject:context];
                }
            }
        }*/
        if([htmlObject isKindOfClass:[NSString class]])
        {
            [new_html_array addObject: [self purify:(NSString*)htmlObject]];
            [context_array addObject:context];
        }

    }
    context = context_array;
    return new_html_array;
}

/**
 * Filters an array of HTML snippets
 *
 * @param string[] $array_of_html Array of html snippets
 * @param HTMLPurifier_Config $config Optional config object for this operation.
 *   See HTMLPurifier::purify() for more details.
 *
 * @return string[] Array of purified HTML
 */
- (NSMutableArray*) purifyArray:(NSArray*)array_of_html config:(HTMLPurifier_Config*)newConfig
{
    NSMutableArray* context_array = [NSMutableArray new];
    
    NSMutableArray* new_html_array = [NSMutableArray new];
    
    for(NSString* html in array_of_html)
    {
        [new_html_array addObject: [self purify:html config:newConfig]];
        [context_array addObject:context];
    }
    context = context_array;
    return new_html_array;

}


+ (HTMLPurifier*)instance
{
    return [HTMLPurifier instance:nil];
}

+ (HTMLPurifier*)instance:(HTMLPurifier*)prototype
{
    if (!theInstance || prototype)
    {
        if ([prototype isKindOfClass:[HTMLPurifier class]])
        {
            theInstance = prototype;
        }
        else if (prototype)
        {
            theInstance = [[HTMLPurifier alloc] initWithConfig:(HTMLPurifier_Config*)prototype];
        }
        else
        {
            theInstance = [HTMLPurifier new];
        }
    }
    return theInstance;
}



@end
