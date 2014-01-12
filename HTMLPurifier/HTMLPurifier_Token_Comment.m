//
//  HTMLPurifier_Token_Comment.m
//  HTMLPurifier
//
//  Created by Roman Priebe on 12.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_Token_Comment.h"

@implementation HTMLPurifier_Token_Comment





    /**
     * Transparent constructor.
     *
     * @param string $data String comment data.
     * @param int $line
     * @param int $col
     */
- (id)initWithData:(NSString*)d line:(NSInteger)l col:(NSInteger)c
{
    self = [super init];
    if (self) {
        self.data = d;
        self.line = l;
        self.col = c;
    }
    return self;
}

- (void)toNode
{
    return [[HTMLPurifier_Node_Comment alloc] initWithData:self.data, self.line, self.col];
}


@end
