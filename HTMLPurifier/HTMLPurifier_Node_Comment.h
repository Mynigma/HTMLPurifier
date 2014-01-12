//
//  HTMLPurifier_Node_Comment.h
//  HTMLPurifier
//
//  Created by Roman Priebe on 12.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_Node.h"

/**
 * Concrete comment node class.
 */
@interface HTMLPurifier_Node_Comment : HTMLPurifier_Node


    /**
     * Character data within comment.
     * @type string
     */
@property NSString* data;

    /**
     * @type bool
     */
@property BOOL isWhitespace;



@end
