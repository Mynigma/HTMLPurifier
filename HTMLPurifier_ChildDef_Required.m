//
//  HTMLPurifier_ChildDef_Required.m
//  HTMLPurifier
//
//  Created by Roman Priebe on 18.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_ChildDef_Required.h"
#import "BasicPHP.h"

@implementation HTMLPurifier_ChildDef_Required



- (id)initWithElements:(NSObject*)newElements
{
    self = [super init];
    if (self) {
        self.elements = [@{} mutableCopy];
        whitespace = NO;
        NSObject* elements = newElements;
        if([elements isKindOfClass:[NSString class]])
        {
            elements = str_replace(@" ", @"", (NSString*)elements);
            elements = explode(@"|", (NSString*)elements);
        }
        //NSDictionary* dict = [NSDictionary alloc] init
        //NSArray* keys = [(NSArray*)elements;

    }
    return self;
}


- (NSObject*)validateChildren:(NSArray *)children config:(HTMLPurifier_Config *)config context:(HTMLPurifier_Context *)context
{
    return nil;
}

//    /**
//     * @param array|string $elements List of allowed element names (lowercase).
//     */
//    public function __construct($elements)
//    {
//        if (is_string($elements)) {
//            $elements = str_replace(' ', '', $elements);
//            $elements = explode('|', $elements);
//        }
//        $keys = array_keys($elements);
//        if ($keys == array_keys($keys)) {
//            $elements = array_flip($elements);
//            foreach ($elements as $i => $x) {
//                $elements[$i] = true;
//                if (empty($i)) {
//                    unset($elements[$i]);
//                } // remove blank
//            }
//        }
//        $this->elements = $elements;
//    }
//
//    /**
//     * @type bool
//     */
//    public $allow_empty = false;
//
//    /**
//     * @type string
//     */
//    public $type = 'required';
//
//    /**
//     * @param array $children
//     * @param HTMLPurifier_Config $config
//     * @param HTMLPurifier_Context $context
//     * @return array
//     */
//    public function validateChildren($children, $config, $context)
//    {
//        // Flag for subclasses
//        $this->whitespace = false;
//
//        // if there are no tokens, delete parent node
//        if (empty($children)) {
//            return false;
//        }
//
//        // the new set of children
//        $result = array();
//
//        // whether or not parsed character data is allowed
//        // this controls whether or not we silently drop a tag
//        // or generate escaped HTML from it
//        $pcdata_allowed = isset($this->elements['#PCDATA']);
//
//        // a little sanity check to make sure it's not ALL whitespace
//        $all_whitespace = true;
//
//        $stack = array_reverse($children);
//        while (!empty($stack)) {
//            $node = array_pop($stack);
//            if (!empty($node->is_whitespace)) {
//                $result[] = $node;
//                continue;
//            }
//            $all_whitespace = false; // phew, we're not talking about whitespace
//
//            if (!isset($this->elements[$node->name])) {
//                // special case text
//                // XXX One of these ought to be redundant or something
//                if ($pcdata_allowed && $node instanceof HTMLPurifier_Node_Text) {
//                    $result[] = $node;
//                    continue;
//                }
//                // spill the child contents in
//                // ToDo: Make configurable
//                if ($node instanceof HTMLPurifier_Node_Element) {
//                    for ($i = count($node->children) - 1; $i >= 0; $i--) {
//                        $stack[] = $node->children[$i];
//                    }
//                    continue;
//                }
//                continue;
//            }
//            $result[] = $node;
//        }
//        if (empty($result)) {
//            return false;
//        }
//        if ($all_whitespace) {
//            $this->whitespace = true;
//            return false;
//        }
//        return $result;
//    }



@end
