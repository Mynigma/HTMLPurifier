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


@implementation HTMLPurifier

/**
 * Global configuration object.
 */
@synthesize config;

/**
 * Array of extra filter objects to run on HTML,
 * for backwards compatibility.
 */
@synthesize filter;

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
- (NSString*) purifyWith:(NSString*)html
{
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
    [context registerWithName:@"Generator" Ref:generator];
    
    //Set up global context variables
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
