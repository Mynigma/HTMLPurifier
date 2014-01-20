//
//  HTMLPurifier_URIFilter_MakeAbsolute.m
//  HTMLPurifier
//
//  Created by Lukas Neumann on 19.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_URIFilter_MakeAbsolute.h"
#import "HTMLPurifier_Config.h"
#import "HTMLPurifier_Context.h"
#import "HTMLPurifier_URIDefinition.h"
#import "HTMLPurifier_URI.h"
#import "BasicPHP.h"
#import "HTMLPurifier_URIScheme.h"

@implementation HTMLPurifier_URIFilter_MakeAbsolute

/**
 * @type string
 */
//public $name = 'MakeAbsolute';

/**
 * @type
 */
@synthesize base;

/**
 * @type array
 */
@synthesize basePathStack; // = array();


-(id) init
{
    self = [super init];
    super.name = @"MakeAbsolute";
    basePathStack = [NSMutableArray new];
    return self;
}

/**
 * @param HTMLPurifier_Config $config
 * @return bool
 */
- (BOOL) prepare:(HTMLPurifier_Config*)config
{
    HTMLPurifier_URIDefinition* def = (HTMLPurifier_URIDefinition*)[config getDefinition:@"URI"];
    base = [def base];
    if (!base)
    {
        NSLog(@"URI.MakeAbsolute is being ignored due to lack of value for URI.Base configuration");
        return NO;
    }
    [base setFragment:nil]; // fragment is invalid for base URI
    NSMutableArray* stack = [explode(@"/", [base path]) mutableCopy];
    array_pop(stack); // discard last segment
    stack = [self collapseStack:stack]; // do pre-parsing
    basePathStack = stack;
    return YES;
}

/**
 * @param HTMLPurifier_URI $uri
 * @param HTMLPurifier_Config $config
 * @param HTMLPurifier_Context $context
 * @return bool
 */
-(BOOL) filter:(HTMLPurifier_URI*)uri config:(HTMLPurifier_Config*)config context:(HTMLPurifier_Context*)context
{
    if (!base)
    {
        // abort early
        return YES;
    }
    if ([[uri path] isEqual:@""] && ![uri scheme] &&
        ![uri host] && ![uri query] && ![uri fragment])
    {
        // reference to current document
        uri = base.copy;
        return YES;
    }
    if ([uri scheme])
    {
        // absolute URI already: don't change
        if ([uri host])
        {
            return YES;
        }
        HTMLPurifier_URIScheme* scheme_obj = [uri getSchemeObj:config context:context];
        if (!scheme_obj)
        {
            // scheme not recognized
            return NO;
        }
        if (![scheme_obj hierarchical])
        {
            // non-hierarchal URI with explicit scheme, don't change
            return YES;
        }
        // special case: had a scheme but always is hierarchical and had no authority
    }
    if ([uri host])
    {
        // network path, don't bother
        return YES;
    }
    if ([[uri path] isEqual:@""])
    {
        [uri setPath:base.path];
    }
    else if ([[uri path] characterAtIndex:0] != '/')
    {
        // relative path, needs more complicated processing
        NSArray* stack = explode(@"/", [uri path]);
        NSMutableArray* new_stack = [array_merge_2(basePathStack, stack) mutableCopy];
        if (![new_stack[0] isEqual:@""] && [base host])
        {
            array_unshift_2(new_stack, @"");
        }
        new_stack = [self collapseStack:new_stack];
        [uri setPath:implode(@"/",new_stack)];
    }
    else
    {
        // absolute path, but still we should collapse
        [uri setPath:implode(@"/", [self collapseStack:explode(@"/",[uri path])])];
    }
    // re-combine
    [uri setScheme:[base scheme]];
    
    if (![uri userinfo])
    {
        [uri setUserinfo:[base userinfo]];
    }

    if (![uri host])
    {
        [uri setHost:[base host]];
    }
    if (![uri port])
    {
        [uri setPort:[base port]];
    }
    return YES;
}

/**
 * Resolve dots and double-dots in a path stack
 * @param array $stack
 * @return array
 */
-(NSMutableArray*) collapseStack:(NSArray*)stack
{
    NSMutableArray* result = [NSMutableArray new];
    BOOL is_folder = NO;
    for (NSInteger i = 0; i < stack.count; i++)
    {
        is_folder = NO;
        // absorb an internally duplicated slash
        if ([stack[i] isEqual:@""] && (i + 1 < stack.count))
        {
            continue;
        }
        if ([stack[i] isEqual:@".."])
        {
            if (result.count > 0)
            {
                NSString* segment = (NSString*) array_pop(result);
                if ([segment isEqual:@""] && (result.count == 0))
                {
                    // error case: attempted to back out too far:
                    // restore the leading slash
                    [result addObject:@""];
                }
                else if ([segment isEqual:@".."])
                {
                    [result addObject:@".."]; // cannot remove .. with ..
                }
            }
            else
            {
                // relative path, preserve the double-dots
                [result addObject:@".."];
            }
            is_folder = YES;
            continue;
        }
        if ([stack[i] isEqual:@"."])
        {
            // silently absorb
            is_folder = YES;
            continue;
        }
        [result addObject:stack[i]];
    }
    if (is_folder)
    {
        [result addObject:@""];
    }
    return result;
}

@end
