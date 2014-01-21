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

- (id)copyWithZone:(NSZone *)zone
{
    HTMLPurifier_Token* newToken = [[[self class] allocWithZone:zone] init];
    [newToken setLine:[self.line copyWithZone:zone]];
    [newToken setCol:[self.col copyWithZone:zone]];
    [newToken setName:[self.name copyWithZone:zone]];
    [newToken setArmor:[self.armor copyWithZone:zone]];
    [newToken setSkip:[self.skip copyWithZone:zone]];
    [newToken setRewind:[self.rewind copyWithZone:zone]];
    [newToken setSkip:[self.skip copyWithZone:zone]];
    [newToken setAttr:[self.attr copyWithZone:zone]];
    [newToken setSortedAttrKeys:[self.sortedAttrKeys copyWithZone:zone]];
    [newToken setIsTag:self.isTag];

    return newToken;
}


-(BOOL) isEqual:(HTMLPurifier_Token*)object
{
    return  (self.line?[self.line isEqual:object.line]:object.line?NO:YES)  &&
            (self.col?[self.col isEqual:object.col]:object.col?NO:YES)  &&
            (self.armor?[self.armor isEqual:object.armor]:object.armor?NO:YES)  &&
            (self.skip?[self.skip isEqual:object.skip]:object.skip?NO:YES)  &&
            (self.rewind?[self.rewind isEqual:object.rewind]:object.rewind?NO:YES)  &&
            (self.carryover?[self.carryover isEqual:object.carryover]:object.carryover?NO:YES)  &&
            (self.name?[self.name isEqual:object.name]:object.name?NO:YES)  &&
            (self.attr?[self.attr isEqual:object.attr]:object.attr?NO:YES)  &&
            (self.sortedAttrKeys?[self.sortedAttrKeys isEqual:object.sortedAttrKeys]:object.sortedAttrKeys?NO:YES)  &&
            (self.isTag == object.isTag);

}

-(NSUInteger) hash
{
    return [self.line hash] + [self.col hash] + [self.armor hash] + [self.rewind hash] + [self.skip hash] + [self.carryover hash] + [self.name hash] + [self.attr hash] + [self.sortedAttrKeys hash];
}


@end
