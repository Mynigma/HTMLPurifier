//
//  HTMLPurifier_Token.h
//  HTMLPurifier
//
//  Created by Roman Priebe on 12.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTMLPurifier_Node.h"

/**
 * Abstract base token class that all others inherit from.
 */
@interface HTMLPurifier_Token : NSObject

    /**
     * Line number node was on in source document. Null if unknown.
     * @type int
     */
@property NSNumber* line;

    /**
     * Column of line node was on in source document. Null if unknown.
     * @type int
     */
@property NSNumber* col;

    /**
     * Lookup array of processing that this token is exempt from.
     * Currently, valid values are "ValidateAttributes" and
     * "MakeWellFormed_TagClosedError"
     * @type array
     */
@property NSMutableDictionary* armor;

    /**
     * Used during MakeWellFormed.
     * @type
     */
@property NSMutableDictionary* skip;

    /**
     * @type
     */
@property NSObject* rewind;

    /**
     * @type
     */
@property NSObject* carryover;

- (id)init;

/**
 * @param string $n
 * @return null|string
 */
- (NSString*)valueForUndefinedKey:(NSString*)n;


/**
 * Sets the position of the token in the source document.
 * @param int $l
 * @param int $c
 */
- (void)position:(NSNumber*)l c:(NSNumber*)c;

/**
 * Convenience function for DirectLex settings line/col position.
 * @param int $l
 * @param int $c
 */
- (void)rawPosition:(NSNumber*)l c:(NSNumber*)c;
/**
 * Converts a token into its corresponding node.
 */
- (HTMLPurifier_Node*)toNode;

@end
