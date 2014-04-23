//
//   HTMLPurifier_Node_Text.m
//   HTMLPurifier
//
//  Created by Roman Priebe on 12.01.14.


#import "HTMLPurifier_Node_Text.h"
#import "HTMLPurifier_Token_Text.h"

@implementation HTMLPurifier_Node_Text


    /**
     * Constructor, accepts data and determines if it is whitespace.
     * @param string $data String parsed character data.
     * @param int $line
     * @param int $col
     */
- (id)initWithData:(NSString*)d isWhitespace:(BOOL)isW line:(NSNumber*)l col:(NSNumber*)c
{
    self = [super init];
    if (self) {
        _data = d;
        self.isWhitespace = isW;
        self.line = l;
        self.col = c;
        self.name = @"#PCDATA";
    }
    return self;
}

    

- (NSArray*)toTokenPair
{
    return @[[[HTMLPurifier_Token_Text alloc] initWithData:self.data line:self.line col:self.col], [NSNull null]];
}

@end
