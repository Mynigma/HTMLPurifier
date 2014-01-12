//
//  HTMLPurifier_Node_Element.h
//  HTMLPurifier
//
//  Created by Roman Priebe on 12.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_Node.h"

/**
 * Concrete element node class.
 */
@interface HTMLPurifier_Node_Element : HTMLPurifier_Node

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
     * Associative array of the node's attributes.
     * @type array
     */
@property NSMutableDictionary* attr;

/**
     * List of child elements.
     * @type array
     */
@property NSMutableArray* children;

    /**
     * Does this use the <a></a> form or the </a> form, i.e.
     * is it a pair of start/end tokens or an empty token.
     * @bool
     */
@property BOOL empty;

@property endCol;

@property endLine;

@property NSMutableDictionary* endArmor;


    public $endCol = null, $endLine = null, $endArmor = array();

    public function __construct($name, $attr = array(), $line = null, $col = null, $armor = array()) {
        $this->name = $name;
        $this->attr = $attr;
        $this->line = $line;
        $this->col = $col;
        $this->armor = $armor;
    }

    public function toTokenPair() {
        // XXX inefficiency here, normalization is not necessary
        if ($this->empty) {
            return array(new HTMLPurifier_Token_Empty($this->name, $this->attr, $this->line, $this->col, $this->armor), null);
        } else {
            $start = new HTMLPurifier_Token_Start($this->name, $this->attr, $this->line, $this->col, $this->armor);
            $end = new HTMLPurifier_Token_End($this->name, array(), $this->endLine, $this->endCol, $this->endArmor);
            //$end->start = $start;
            return array($start, $end);
        }
    }
}

@end
