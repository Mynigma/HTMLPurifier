//
//  HTMLPurifier_Token_End.m
//  HTMLPurifier
//
//  Created by Roman Priebe on 12.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_Token_End.h"
#import "HTMLPurifier_Node.h"
#import "BasicPHP.h"

@implementation HTMLPurifier_Token_End

- (HTMLPurifier_Node*)toNode
{
    TRIGGER_ERROR(@"toNode not supported on end tokens");
    return nil;
}

@end
