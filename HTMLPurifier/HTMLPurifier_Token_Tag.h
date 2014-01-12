//
//  HTMLPurifier_Token_Tag.h
//  HTMLPurifier
//
//  Created by Roman Priebe on 12.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_Token.h"

/**
 * Abstract class of a tag token (start, end or empty), and its behavior.
 */
@interface HTMLPurifier_Token_Tag : HTMLPurifier_Token

    /**
     * Static bool marker that indicates the class is a tag.
     *
     * This allows us to check objects with <tt>!empty($obj->is_tag)</tt>
     * without having to use a function call <tt>is_a()</tt>.
     * @type bool
     */
@property BOOL is_tag;

    /**
     * The lower-case name of the tag, like 'a', 'b' or 'blockquote'.
     *
     * @note Strictly speaking, XML tags are case sensitive, so we shouldn't
     * be lower-casing them, but these tokens cater to HTML tags, which are
     * insensitive.
     * @type string
     */
@property NSString* name;

    /**
     * Associative array of the tag's attributes.
     * @type array
     */
@property NSMutableDictionary* attr;

    /**
     * Non-overloaded constructor, which lower-cases passed tag name.
     *
     * @param string $name String name.
     * @param array $attr Associative array of attributes.
     * @param int $line
     * @param int $col
     * @param array $armor
     */

- (id)initWithName:(NSString*)n attr:(NSMutableDictionary*)att line:(NSNumber*)l col:(NSNumber*)c armor:(NSMutableDictionary*)arm;

- (HTMLPurifier_Node_Element*)toNode;

@end
