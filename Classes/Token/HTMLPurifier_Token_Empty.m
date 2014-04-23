//
//   HTMLPurifier_Token_Empty.m
//   HTMLPurifier
//
//  Created by Roman Priebe on 12.01.14.


#import "HTMLPurifier_Token_Empty.h"
#import "HTMLPurifier_Node_ELement.h"

/**
 * Concrete empty token class.
 */
@implementation HTMLPurifier_Token_Empty


- (HTMLPurifier_Node*)toNode
{
    HTMLPurifier_Node_Element* n = (HTMLPurifier_Node_Element*)[super toNode];
        n.empty = YES;
        return n;
}

@end
