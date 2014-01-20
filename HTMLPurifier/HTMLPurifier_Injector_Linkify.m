//
//  HTMLPurifier_Injector_Linkify.m
//  HTMLPurifier
//
//  Created by Roman Priebe on 14.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_Injector_Linkify.h"
#import "HTMLPurifier_Token_Text.h"
#import "HTMLPurifier_Token.h"
#import "HTMLPurifier_Token_Start.h"
#import "HTMLPurifier_Token_End.h"
#import "BasicPHP.h"

@implementation HTMLPurifier_Injector_Linkify

- (id)init
{
    self = [super init];
    if (self) {
        super.name = @"Linkify";
        super.needed = [@{@"a" :@[@"href"]} mutableCopy];
    }
    return self;
}



- (void)handleText:(HTMLPurifier_Token**)token
{
    if (![self allowsElement:@"a"]) {
        return;
    }

    if (strpos([*token valueForKey:@"data"], @"://") == NSNotFound) {
        // our really quick heuristic failed, abort
        // this may not work so well if we want to match things like
        // "google.com", but then again, most people don't
        return;
    }

    // there is/are URL(s). Let's split the string:
    // Note: this regex is extremely permissive
    NSArray* bits = preg_split_3_PREG_SPLIT_DELIM_CAPTURE(@"#((?:https?|ftp)://[^\\s\\'\",<>()]+)#Su", [*token valueForKey:@"data"], -1);


    NSMutableArray* tokenArray = [NSMutableArray new];

    // $i = index
    // $c = count
    // $l = is link
    NSInteger c = bits.count;
    BOOL l = NO;
    for (NSInteger i = 0; i < c; i++, l = !l) {
        if (!l) {
            if ([bits[i] isEqualToString:@""])
            {
                continue;
            }
            [tokenArray addObject:[[HTMLPurifier_Token_Text alloc] initWithData:bits[i]]];
        } else {
            [tokenArray addObject:[[HTMLPurifier_Token_Start alloc] initWithName:@"a" attr:@{@"href":bits[i]} sortedAttrKeys:@[@"href"] line:nil col:nil armor:[NSMutableDictionary new]]];
            [tokenArray addObject:[[HTMLPurifier_Token_Text alloc] initWithData:bits[i]]];
            [tokenArray addObject:[[HTMLPurifier_Token_End alloc] initWithName:@"a"]];
        }
    }

    *token = (HTMLPurifier_Token*)tokenArray;
}


@end
