//
//   HTMLPurifier_Node_Comment.m
//   HTMLPurifier
//
//  Created by Roman Priebe on 12.01.14.


#import "HTMLPurifier_Node_Comment.h"
#import "HTMLPurifier_Token_Comment.h"

@implementation HTMLPurifier_Node_Comment




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
        _data = d;
        self.line = l;
        self.col = c;
        self.isWhitespace = YES;
    }
    return self;
}

- (NSArray*)toTokenPair
{
    return @[[[HTMLPurifier_Token_Comment alloc] initWithData:self.data line:self.line col:self.col], [NSNull null]];
}


@end
