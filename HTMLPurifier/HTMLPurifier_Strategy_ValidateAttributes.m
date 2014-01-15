//
//  HTMLPurifier_Strategy_ValidateAttributes.m
//  HTMLPurifier
//
//  Created by Roman Priebe on 13.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_Strategy_ValidateAttributes.h"
#import "HTMLPurifier_Token.h"
#import "HTMLPurifier_Token_Empty.h"
#import "HTMLPurifier_Token_Start.h"
//#import "HTMLPurifier_AttrValidator.h"

@implementation HTMLPurifier_Strategy_ValidateAttributes


- (NSMutableArray*)execute:(NSMutableArray*)tokens config:(HTMLPurifier_Config *)config context:(HTMLPurifier_Context *)context;
{
    return nil;
    /*
    // setup validator
    HTMLPurifier_AttrValidator* validator = [HTMLPurifier_AttrValidator new];

    [context registerString:@"CurrentToken", @NO);

    for(HTMLPurifier_Token* token in tokens.allValues)
    {
        // only process tokens that have attributes,
        //   namely start and empty tags
        if (![token isKindOfClass:[HTMLPurifier_Token_Start class]] && ![token isKindOfClass:[HTMLPurifier_Token_Empty class]])
        {
            continue;
        }

        // skip tokens that are armored
        if ([[token armor][@"ValidateAttributes"] count]>0)
        {
            continue;
        }

        // note that we have no facilities here for removing tokens
        [validator validateToken:token config:config context:context];
    }
    [context destroy:@"CurrentToken"];
    return tokens;
     */
}




@end
