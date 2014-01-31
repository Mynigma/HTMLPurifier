//
//   HTMLPurifier_Strategy_ValidateAttributes.m
//   HTMLPurifier
//
//  Created by Roman Priebe on 13.01.14.


#import "HTMLPurifier_Strategy_ValidateAttributes.h"
#import "HTMLPurifier_Token.h"
#import "HTMLPurifier_Token_Empty.h"
#import "HTMLPurifier_Token_Start.h"
#import "HTMLPurifier_AttrValidator.h"
#import "HTMLPurifier_Context.h"

@implementation HTMLPurifier_Strategy_ValidateAttributes


- (NSMutableArray*)execute:(NSMutableArray*)tokens config:(HTMLPurifier_Config *)config context:(HTMLPurifier_Context *)context;
{
    // setup validator
    HTMLPurifier_AttrValidator* validator = [HTMLPurifier_AttrValidator new];

    [context registerWithName:@"CurrentToken" ref:@NO];

    for(HTMLPurifier_Token* token in tokens)
    {
        // only process tokens that have attributes,
        //   namely start and empty tags
        if (![token isKindOfClass:[HTMLPurifier_Token_Start class]] && ![token isKindOfClass:[HTMLPurifier_Token_Empty class]])
        {
            continue;
        }

        // skip tokens that are armored
        if ([token armor][@"ValidateAttributes"])
        {
            continue;
        }

        // note that we have no facilities here for removing tokens
        [validator validateToken:token config:config context:context];
    }
    [context destroy:@"CurrentToken"];
    return tokens;
}




@end
