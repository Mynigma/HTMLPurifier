//
//  HTMLPurifier_Token_Comment.m
//  HTMLPurifier
//
//  Created by Roman Priebe on 12.01.14.


#import "HTMLPurifier_Token_Comment.h"
#import "HTMLPurifier_Node_Comment.h"

@implementation HTMLPurifier_Token_Comment





    /**
     * Transparent constructor.
     *
     * @param string $data String comment data.
     * @param int $line
     * @param int $col
     */
- (id)initWithData:(NSString*)d line:(NSNumber*)l col:(NSNumber*)c
{
    self = [super init];
    if (self) {
        self.data = d;
        self.line = l;
        self.col = c;
        _is_whitespace = YES;
    }
    return self;
}

- (id)initWithData:(NSString*)d
{
    self = [super init];
    if (self) {
        self.data = d;
        _is_whitespace = YES;
    }
    return self;
}

- (HTMLPurifier_Node_Comment*)toNode
{
    return [[HTMLPurifier_Node_Comment alloc] initWithData:self.data line:self.line col:self.col];
}


@end
