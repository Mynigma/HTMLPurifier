//
//  HTMLPurifier_PropertyList.h
//  HTMLPurifier
//
//  Created by Roman Priebe on 15.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Generic property list implementation
 */
@interface HTMLPurifier_PropertyList : NSObject
{
    /**
     * Internal data-structure for properties.
     * @type array
     */
    NSMutableDictionary* data;

    /**
     * Parent plist.
     * @type HTMLPurifier_PropertyList
     */
    HTMLPurifier_PropertyList* parent;

    /**
     * Cache.
     * @type array
     */
    NSMutableDictionary* cache;
}


@end
