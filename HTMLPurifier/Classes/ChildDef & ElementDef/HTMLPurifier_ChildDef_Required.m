//
//   HTMLPurifier_ChildDef_Required.m
//   HTMLPurifier
//
//  Created by Roman Priebe on 18.01.14.


#import "HTMLPurifier_ChildDef_Required.h"
#import "BasicPHP.h"
#import "HTMLPurifier_Node.h"
#import "HTMLPurifier_Node_Text.h"
#import "HTMLPurifier_Node_Element.h"
#import "HTMLPurifier_Node_Comment.h"

@implementation HTMLPurifier_ChildDef_Required



- (id)initWithElements:(NSObject*)newElements
{
    self = [super init];
    if (self) {
        whitespace = NO;
        self.allow_empty = NO;
        self.typeString = @"required";
        NSObject* elements = newElements;
        if([elements isKindOfClass:[NSString class]])
        {
            elements = str_replace(@" ", @"", (NSString*)elements);
            elements = explode(@"|", (NSString*)elements);
        }
        NSMutableDictionary* elementLookup = [NSMutableDictionary new];
        if([elements isKindOfClass:[NSArray class]])
        {
            for(id<NSCopying> element in (NSArray*)elements)
            {
                elementLookup[element] = @YES;
            }
        }
        self.elements = elementLookup;
    }
    return self;
}

- (id)init
{
    return [self initWithElements:nil];
}


- (NSObject*)validateChildren:(NSArray *)children config:(HTMLPurifier_Config *)config context:(HTMLPurifier_Context *)context
{
    // Flag for subclasses
    whitespace = NO;

    if([children count]==0)
        return NO;

    NSMutableArray* result = [NSMutableArray new];

// whether or not parsed character data is allowed
// this controls whether or not we silently drop a tag
// or generate escaped HTML from it
    BOOL pcdata_allowed = (self.elements[@"#PCDATA"]!=nil);

// a little sanity check to make sure it's not ALL whitespace
    BOOL all_whitespace = YES;
    NSMutableArray* stack = array_reverse(children);
            while (stack.count>0)
            {
                HTMLPurifier_Node* node = (HTMLPurifier_Node*)array_pop(stack);
                if (node.isWhitespace)
                {
                    [result addObject:node];
                    continue;
                }
                all_whitespace = NO; // phew, we're not talking about whitespace

                if (!self.elements[node.name])
                {
                    // special case text
                    // XXX One of these ought to be redundant or something
                    if (pcdata_allowed && [node isKindOfClass:[HTMLPurifier_Node_Text class]])
                    {
                        [result addObject:node];
                        continue;
                    }
                  // spill the child contents in
                 // ToDo: Make configurable
                 if ([node isKindOfClass:[HTMLPurifier_Node_Element class]]) {
                     for (NSInteger i = node.children.count - 1; i >= 0; i--) {
                          [stack addObject:node.children[i]];
                      }
                      continue;
                }
                  continue;
               }
                [result addObject:node];
           }
           if (result.count==0) {
              return NO;
          }
          if (all_whitespace) {
              whitespace = YES;
               return NO;
           }
          return result;
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
