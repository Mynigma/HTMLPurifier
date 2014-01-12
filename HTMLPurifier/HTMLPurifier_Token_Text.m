//
//  HTMLPurifier_Token_Text.m
//  HTMLPurifier
//
//  Created by Roman Priebe on 12.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_Token_Text.h"

@implementation HTMLPurifier_Token_Text


/**
 * Constructor, accepts data and determines if it is whitespace.
 * @param string $data String parsed character data.
 * @param int $line
 * @param int $col
 */
- (id)initWithData:(NSString*)d isWhitespace:(BOOL)isW line:(NSInteger)l col:(NSInteger)c
{
    self = [super init];
    if (self) {
        _data = d;
        _isWhitespace = isW;
        self.line = l;
        self.col = c;
        self.name = @"#PCDATA";
    }
    return self;
}



- (NSArray*)toNode
{
    return @[[[HTMLPurifier_Node_Text alloc] initWithData:self.data isWhitespace:self.isWhitespace line:self.line col:self.col], [NSNull null]];
}

@end
