//
//  HTMLPurifier_Token_Empty.m
//  HTMLPurifier
//
//  Created by Roman Priebe on 12.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_Token_Empty.h"
#import "HTMLPurifier_Node.h"

/**
 * Concrete empty token class.
 */
@implementation HTMLPurifier_Token_Empty


- (HTMLPurifier_Node*)toNode
{
    HTMLPurifier_Node* n = [super toNode];
        n.empty = YES;
        return n;
}

@end
