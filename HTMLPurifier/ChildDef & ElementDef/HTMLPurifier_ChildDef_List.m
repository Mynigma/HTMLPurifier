//
//   HTMLPurifier_ChildDef_List.m
//   HTMLPurifier
//
//  Created by Roman Priebe on 18.01.14.


#import "HTMLPurifier_ChildDef_List.h"
#import "HTMLPurifier_Node.h"
#import "HTMLPurifier_Node_Element.h"

/**
 * Definition for list containers ul and ol.
 *
 * What does this do?  The big thing is to handle ol/ul at the top
 * level of list nodes, which should be handled specially by /folding/
 * them into the previous list node.  We generally shouldn't ever
 * see other disallowed elements, because the autoclose behavior
 * in MakeWellFormed handles it.
 */
@implementation HTMLPurifier_ChildDef_List

- (id)init
{
    self = [super init];
    if (self) {
        self.typeString = @"list";
        self.elements = [@{@"li":@YES, @"ul":@YES, @"ol":@YES} mutableCopy];

    }
    return self;
}

/**
 * @param array $children
 * @param HTMLPurifier_Config $config
 * @param HTMLPurifier_Context $context
 * @return array
 */
- (NSObject*)validateChildren:(NSArray*)children config:(HTMLPurifier_Config *)config context:(HTMLPurifier_Context *)context
    {
        // Flag for subclasses
        self.whitespace = @NO;

        // if there are no tokens, delete parent node
        if (children.count == 0)
        {
            return nil;
        }

        // the new set of children
        NSMutableArray* result = [NSMutableArray new];

        // a little sanity check to make sure it's not ALL whitespace
        BOOL all_whitespace = YES;

        HTMLPurifier_Node* current_li = nil;

        for(HTMLPurifier_Node* node in children)
        {
            if (node.isWhitespace)
            {
                [result addObject:node];
                continue;
            }
            all_whitespace = NO; // phew, we're not talking about whitespace

            if ([node.name isEqual:@"li"])
            {
                // good
                current_li = node;
                [result addObject:node];
            }
            else
            {
                // we want to tuck this into the previous li
                // Invariant: we expect the node to be ol/ul
                // ToDo: Make this more robust in the case of not ol/ul
                // by distinguishing between existing li and li created
                // to handle non-list elements; non-list elements should
                // not be appended to an existing li; only li created
                // for non-list. This distinction is not currently made.
                if (!current_li) {
                    current_li = [[HTMLPurifier_Node_Element alloc] initWithName:@"li"];
                    [result addObject:current_li];
                }
                [current_li.children addObject:node];
                current_li.empty = NO; // XXX fascinating! Check for this error elsewhere ToDo
            }
        }
        if (!result)
        {
            return nil;
        }
        if (all_whitespace)
        {
            return nil;
        }
        return result;
    }




@end
