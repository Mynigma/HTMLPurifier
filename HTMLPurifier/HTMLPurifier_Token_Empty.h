//
//  HTMLPurifier_Token_Empty.h
//  HTMLPurifier
//
//  Created by Roman Priebe on 12.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_Token.h"

@class  HTMLPurifier_Node;

@interface HTMLPurifier_Token_Empty : HTMLPurifier_Token

- (HTMLPurifier_Node*)toNode;

@end
