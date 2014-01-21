//
//  HTMLPurifier_URIFilter.m
//  HTMLPurifier
//
//  Created by Lukas Neumann on 19.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_URIFilter.h"
#import "HTMLPurifier_URI.h"
#import "HTMLPurifier_Context.h"
#import "HTMLPurifier_Config.h"

@implementation HTMLPurifier_URIFilter

/**
 * Chainable filters for custom URI processing.
 *
 * These filters can perform custom actions on a URI filter object,
 * including transformation or blacklisting.  A filter named Foo
 * must have a corresponding configuration directive %URI.Foo,
 * unless always_load is specified to be true.
 *
 * The following contexts may be available while URIFilters are being
 * processed:
 *
 *      - EmbeddedURI: true if URI is an embedded resource that will
 *        be loaded automatically on page load
 *      - CurrentToken: a reference to the token that is currently
 *        being processed
 *      - CurrentAttr: the name of the attribute that is currently being
 *        processed
 *      - CurrentCSSProperty: the name of the CSS property that is
 *        currently being processed (if applicable)
 *
 * @warning This filter is called before scheme object validation occurs.
 *          Make sure, if you require a specific scheme object, you
 *          you check that it exists. This allows filters to convert
 *          proprietary URI schemes into regular ones.
 */
    
    /**
     * Unique identifier of filter.
     * @type string
     */
    @synthesize name;
    
    /**
     * True if this filter should be run after scheme validation.
     * @type bool
     */
    @synthesize post; // = false;
    
    /**
     * True if this filter should always be loaded.
     * This permits a filter to be named Foo without the corresponding
     * %URI.Foo directive existing.
     * @type bool
     */
    @synthesize always_load; // = false;
    
    /**
     * Performs initialization for the filter.  If the filter returns
     * false, this means that it shouldn't be considered active.
     * @param HTMLPurifier_Config $config
     * @return bool
     */
-(BOOL) prepare:(HTMLPurifier_Config*)config
    {
        NSLog(@"WARNING: URIFILTER - ABSTRACT FUNCTION CALLED");
        return YES;
    }
    
    /**
     * Filter a URI object
     * @param HTMLPurifier_URI $uri Reference to URI object variable
     * @param HTMLPurifier_Config $config
     * @param HTMLPurifier_Context $context
     * @return bool Whether or not to continue processing: false indicates
     *         URL is no good, true indicates continue processing. Note that
     *         all changes are committed directly on the URI object
     */
-(BOOL) filter:(HTMLPurifier_URI**)uri config:(HTMLPurifier_Config*)config context:(HTMLPurifier_Context*)context
    {
        NSLog(@"WARNING: URIFILTER - ABSTRACT FUNCTION CALLED");
        return YES;
    }

@end
