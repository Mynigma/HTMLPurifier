//
//   HTMLPurifier_AttrDef_CSS_BackgroundPosition.m
//   HTMLPurifier
//
//  Created by Roman Priebe on 10.01.14.


#import "HTMLPurifier_AttrDef_CSS_BackgroundPosition.h"
#import "BasicPHP.h"
#import "HTMLPurifier_AttrDef_CSS_Percentage.h"
#import "HTMLPurifier_AttrDef_CSS_Length.h"

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



- (instancetype)initWithCoder:(NSCoder*)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        _length = [coder decodeObjectForKey:@"length"];
        _percentage = [coder decodeObjectForKey:@"percentage"];
    }
    return self;
}



- (void)encodeWithCoder:(NSCoder*)encoder
{
    [super encodeWithCoder:encoder];
    [encoder encodeObject:_length forKey:@"length"];
    [encoder encodeObject:_percentage forKey:@"percentage"];
}


- (BOOL)isEqual:(id)other
{
    if (other == self) {
        return YES;
    } else if (![super isEqual:other]) {
        return NO;
    } else if(![other isKindOfClass:[HTMLPurifier_AttrDef_CSS_BackgroundPosition class]])
    {
        return NO;
    }
    else
    {
        return ((!self.length && ![(HTMLPurifier_AttrDef_CSS_BackgroundPosition*)other length]) || [self.length isEqual:[(HTMLPurifier_AttrDef_CSS_BackgroundPosition*)other length]]) && ((!self.percentage && ![(HTMLPurifier_AttrDef_CSS_BackgroundPosition*)other percentage]) || [self.percentage isEqual:[(HTMLPurifier_AttrDef_CSS_BackgroundPosition*)other percentage]]);
    }
}

- (NSUInteger)hash
{
    return [_length hash] ^ [_percentage hash];
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
        if([bit isEqual:@""])
            continue;

          // test for keyword
        NSString* lbit = [bit lowercaseString];
        if ([lookup objectForKey:lbit]) {
            NSString* status = [lookup objectForKey:lbit];
            if ([status isEqual:@"c"]) {
                if (i == 0) {
                    status = @"ch";
                } else {
                    status = @"cv";
                }
            }
            if (status){
                [keywords setObject:lbit forKey:status];
                i++;
            }
        }

        // test for length
        NSString* r = [self.length validateWithString:bit config:config context:context];
        if (r) {
            [measures addObject:r];
            i++;
        }

        // test for percentage
        r = [self.percentage validateWithString:bit config:config context:context];
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
    if (keywords[@"h"] && ![keywords[@"h"] isEqual:@NO])
    {
        [ret addObject:keywords[@"h"]];
    } else if (keywords[@"ch"] && ![keywords[@"ch"] isEqual:@NO])
    {
        [ret addObject:keywords[@"ch"]];
        keywords[@"cv"] = @NO; // prevent re-use: center = center center
    } else if (measures.count>0)
    {
        [ret addObject:array_shift(measures)];
    }

    if (keywords[@"v"] && ![keywords[@"v"] isEqual:@NO])
    {
        [ret addObject:keywords[@"v"]];
    } else if (keywords[@"cv"] && ![keywords[@"cv"] isEqual:@NO])
    {
        [ret addObject:keywords[@"cv"]];
    } else if (measures.count>0)
    {
        [ret addObject:array_shift(measures)];
    }

    if (ret.count==0)
    {
        return nil;
    }
    return implode(@" ", ret);
}



@end
