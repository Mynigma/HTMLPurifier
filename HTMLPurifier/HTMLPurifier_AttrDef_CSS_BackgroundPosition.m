//
//  HTMLPurifier_AttrDef_CSS_BackgroundPosition.m
//  HTMLPurifier
//
//  Created by Roman Priebe on 10.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_AttrDef_CSS_BackgroundPosition.h"
#import "BasicPHP.h"

@implementation HTMLPurifier_AttrDef_CSS_BackgroundPosition

- (id)init
{
    self = [super init];
    if (self) {
    _length = [[HTMLPurifier_AttrDef_CSS_Length alloc] init];
    _percentage = [[HTMLPurifier_AttrDef_CSS_Percentage alloc] init];
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
        NSString* r = [self.length validate($bit, $config, $context);
        if ($r !== false) {
            $measures[] = $r;
            $i++;
        }

        // test for percentage
        $r = $this->percentage->validate($bit, $config, $context);
        if ($r !== false) {
            $measures[] = $r;
            $i++;
        }
    }

    if (!$i) {
        return false;
    } // no valid values were caught

    $ret = array();

    // first keyword
    if ($keywords['h']) {
        $ret[] = $keywords['h'];
    } elseif ($keywords['ch']) {
        $ret[] = $keywords['ch'];
        $keywords['cv'] = false; // prevent re-use: center = center center
    } elseif (count($measures)) {
        $ret[] = array_shift($measures);
    }

    if ($keywords['v']) {
        $ret[] = $keywords['v'];
    } elseif ($keywords['cv']) {
        $ret[] = $keywords['cv'];
    } elseif (count($measures)) {
        $ret[] = array_shift($measures);
    }

    if (empty($ret)) {
        return false;
    }
    return implode(' ', $ret);
}
}


@end
