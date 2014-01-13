//
//  HTMLPurifier_Token_Text.m
//  HTMLPurifier
//
//  Created by Roman Priebe on 12.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_Token_Text.h"
#import "HTMLPurifier_Node_Text.h"
#import "BasicPHP.h"

@implementation HTMLPurifier_Token_Text


/**
 * Constructor, accepts data and determines if it is whitespace.
 * @param string $data String parsed character data.
 * @param int $line
 * @param int $col
 */
- (id)initWithData:(NSString*)d line:(NSNumber*)l col:(NSNumber*)c
{
    self = [super init];
    if (self) {
        _data = d;
        _isWhitespace = ctype_space(d);
        self.line = l;
        self.col = c;
        self.name = @"#PCDATA";
    }
    return self;
}

- (id)initWithData:(NSString*)d
{
    return [self initWithData:d line:nil col:nil];
}


- (NSArray*)toNode
{
    return @[[[HTMLPurifier_Node_Text alloc] initWithData:self.data line:self.line col:self.col], [NSNull null]];
}

@end
