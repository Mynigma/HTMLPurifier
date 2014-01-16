//
//  HTMLPurifier_Token.m
//  HTMLPurifier
//
//  Created by Roman Priebe on 12.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_Token.h"
#import "HTMLPurifier.h"
#import "BasicPHP.h"
#import "HTMLPurifier_Node.h"
#import "HTMLPurifier_Token_Empty.h"
#import "HTMLPurifier_Token_End.h"
#import "HTMLPurifier_Token_Start.h"
#import "HTMLPurifier_Token_Comment.h"
#import "HTMLPurifier_Token_Text.h"


@implementation HTMLPurifier_Token

- (id)init
{
    self = [super init];
    if (self) {
        _armor = [NSMutableDictionary new];
        _isTag = NO;
    }
    return self;
}

    /**
     * @param string $n
     * @return null|string
     */
- (NSString*)valueForUndefinedKey:(NSString*)n
    {
        if ([n isEqualToString:@"type"])
        {
            TRIGGER_ERROR(@"Deprecated type property called; use instanceof");
        }
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
        return nil;
    }

/*
- (NSString*)name
{
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
    return nil;
}

- (NSString*)attr
{
    return [self name];
}*/

    /**
     * Sets the position of the token in the source document.
     * @param int $l
     * @param int $c
     */
- (void)position:(NSNumber*)l c:(NSNumber*)c
    {
        self.line = l;
        self.col = c;
    }

    /**
     * Convenience function for DirectLex settings line/col position.
     * @param int $l
     * @param int $c
     */
- (void)rawPosition:(NSNumber*)l c:(NSNumber*)c
    {
        if (c.integerValue == -1) {
            l = @(l.integerValue+1);
        }
        self.line = l;
        self.col = c;
    }

    /**
     * Converts a token into its corresponding node.
     */
- (HTMLPurifier_Node*)toNode
{
    return nil;
}


@end
