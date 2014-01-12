//
//  HTMLPurifier_TokenFactory.m
//  HTMLPurifier
//
//  Created by Roman Priebe on 12.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_TokenFactory.h"
#import "HTMLPurifier_Token_Empty.h"
#import "HTMLPurifier_Token_End.h"
#import "HTMLPurifier_Token_Start.h"
#import "HTMLPurifier_Token_Comment.h"
#import "HTMLPurifier_Token_Text.h"

@implementation HTMLPurifier_TokenFactory


- (id)init{
    self = [super init];
    if (self) {
        _p_start = [[HTMLPurifier_Token_Start alloc] initWith:@"" @[]];
        _p_end = [[HTMLPurifier_Token_End alloc] initW:@""];
        _p_empty = [[HTMLPurifier_Token_Empty alloc] initW:@"" @[]];
        _p_text = [[HTMLPurifier_Token_Text alloc] initW:@""];
        _p_comment = [[HTMLPurifier_Token_Comment alloc] initWithData:@""];
    }
    return self;
}

    /**
     * Creates a HTMLPurifier_Token_Start.
     * @param string $name Tag name
     * @param array $attr Associative array of attributes
     * @return HTMLPurifier_Token_Start Generated HTMLPurifier_Token_Start
     */
- (HTMLPurifier_Token_Start*)createStartWithName:(NSString*)name attr:(NSMutableDictionary*)att
    {
        HTMLPurifier_Token_Start* p = [self.p_start copy];
        [p initWithName:name att:attr];
        return p;
    }

    /**
     * Creates a HTMLPurifier_Token_End.
     * @param string $name Tag name
     * @return HTMLPurifier_Token_End Generated HTMLPurifier_Token_End
     */
- (HTMLPurifier_Token_End*)createEndWithName:(NSString*)name
    {
        HTMLPurifier_Token_End* p = [self.p_end copy];
        [p initWithName:name];
        return p;
    }

    /**
     * Creates a HTMLPurifier_Token_Empty.
     * @param string $name Tag name
     * @param array $attr Associative array of attributes
     * @return HTMLPurifier_Token_Empty Generated HTMLPurifier_Token_Empty
     */
- (HTMLPurifier_Token_Empty*)createEmptyWithName:(NSString*)name attr:(NSString*)attr
    {
        HTMLPurifier_Token_Empty* p = [self.p_empty copy];
        [p initWithName:name attr:attr];
        return p;
    }

    /**
     * Creates a HTMLPurifier_Token_Text.
     * @param string $data Data of text token
     * @return HTMLPurifier_Token_Text Generated HTMLPurifier_Token_Text
     */
- (HTMLPurifier_Token_Text*)createTextWithData:(NSString*)data
    {
        HTMLPurifier_Token_Text* p = [self.p_text copy];
        [p initWithData:data];
        return p;
    }

    /**
     * Creates a HTMLPurifier_Token_Comment.
     * @param string $data Data of comment token
     * @return HTMLPurifier_Token_Comment Generated HTMLPurifier_Token_Comment
     */
- (HTMLPurifier_Token_Comment*)createCommentWithData:(NSString*)data
    {
        HTMLPurifier_Token_Comment* p = [self.p_comment copy];
        [p initWithData:data];
        return p;
    }


@end
