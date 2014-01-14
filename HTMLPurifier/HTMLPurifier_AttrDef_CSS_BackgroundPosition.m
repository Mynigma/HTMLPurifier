//
//  HTMLPurifier_AttrDef_CSS_BackgroundPosition.m
//  HTMLPurifier
//
//  Created by Roman Priebe on 10.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_AttrDef_CSS_BackgroundPosition.h"
#import "BasicPHP.h"
#import "HTMLPurifier_AttrDef_CSS_Percentage.h"
#import "HTMLPurifier_AttrDef_CSS_Length.h"

@implementation HTMLPurifier_AttrDef_CSS_BackgroundPosition

- (id)init
{
    self = [super init];
    if (self) {
    length = [[HTMLPurifier_AttrDef_CSS_Length alloc] init];
    percentage = [[HTMLPurifier_AttrDef_CSS_Percentage alloc] init];
    }
    return self;
}

/**
 * @param string $string
 * @param HTMLPurifier_Config $config
 * @param HTMLPurifier_Context $context
 * @return bool|string
 */
- (NSString*)validateWithString:(NSString *)string config:(HTMLPurifier_Config *)config context:(HTMLPurifier_Context *)context
{
    string = [self parseCDATAWithString:string];
    NSArray* bits = explode(@" ", string);

    NSMutableDictionary* keywords = [NSMutableDictionary new];
    [keywords setObject:@NO forKey:@"h"];
    [keywords setObject:@NO forKey:@"v"];
    [keywords setObject:@NO forKey:@"ch"];
    [keywords setObject:@NO forKey:@"cv"];

    NSMutableArray* measures = [NSMutableArray new];

    NSInteger i = 0;

    NSDictionary* lookup = @{@"top":@"v", @"bottom":@"v", @"left":@"h", @"right":@"h", @"center":@"c"};

    for(NSString* bit in bits)
    {
        if([bit isEqualTo:@""])
            continue;

          // test for keyword
        NSString* lbit = [bit lowercaseString];
        if ([lookup objectForKey:lbit]) {
            NSString* status = [lookup objectForKey:lbit];
            if ([status isEqualTo:@"c"]) {
                if (i == 0) {
                    status = @"ch";
                } else {
                    status = @"cv";
                }
            }
            [keywords setObject:lbit forKey:status];
            i++;
        }

        // test for length
        NSString* r = [length validateWithString:bit config:config context:context];
        if (r) {
            [measures addObject:r];
            i++;
        }

        // test for percentage
        r = [self->percentage validateWithString:bit config:config context:context];
        if (r) {
            [measures addObject:r];
            i++;
        }
    }

    if (i==0) {
        return nil;
    } // no valid values were caught

    NSMutableArray* ret = [NSMutableArray new];

    // first keyword
    if (keywords[@"h"]) {
        [ret addObject:keywords[@"h"]];
    } else if (keywords[@"ch"]) {
        [ret addObject:keywords[@"ch"]];
        keywords[@"cv"] = NO; // prevent re-use: center = center center
    } else if (measures.count>0) {
        [ret addObject:array_shift(measures)];
    }

    if (keywords[@"v"]) {
        [ret addObject:keywords[@"v"]];
    } else if (keywords[@"cv"]) {
        [ret addObject:keywords[@"cv"]];
    } else if (measures.count>0) {
        [ret addObject:array_shift(measures)];
    }

    if (ret.count==0)
    {
        return nil;
    }
    return implode(@" ", ret);
}



@end
