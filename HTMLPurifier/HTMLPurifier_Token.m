//
//  HTMLPurifier_Token.m
//  HTMLPurifier
//
//  Created by Roman Priebe on 12.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_Token.h"
#import "BasicPHP.h"
#import "HTMLPurifier_Node.h"

@implementation HTMLPurifier_Token

- (id)init
{
    self = [super init];
    if (self) {
        _armor = [NSMutableArray new];
    }
    return self;
}


    /**
     * @param string $n
     * @return null|string
     */
- (NSString*)__get:(NSString*)n
    {
        if ([n isEqualToString:@"type"])
        {
            TRIGGER_ERROR(@"Deprecated type property called; use instanceof");
            if([self isKindOfClass:[HTMLPurifier_Token_Start class]])
                return @"start";
            if([self isKindOfClass:[HTMLPurifier_Token_Empty class]])
                return @"empty";
            if([self isKindOfClass:[HTMLPurifier_Token_End class]])
                return @"end";
            if([self isKindOfClass:[HTMLPurifier_Token_Text class]])
                return @"text";
            if([self isKindOfClass:[HTMLPurifier_Token_Comment class]])
                return @"comment";

            return null;
        }
    }

    /**
     * Sets the position of the token in the source document.
     * @param int $l
     * @param int $c
     */
- (void)position:(NSInteger)l c:(NSInteger)c
    {
        self.line = l;
        self.col = c;
    }

    /**
     * Convenience function for DirectLex settings line/col position.
     * @param int $l
     * @param int $c
     */
- (void)rawPosition:(NSInteger)l c:(NSInteger)c
    {
        if (c == -1) {
            l++;
        }
        self.line = l;
        self.col = c;
    }

    /**
     * Converts a token into its corresponding node.
     */
- (HTMLPurifier_Node*)toNode
{
    
}


@end
