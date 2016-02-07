//
//   HTMLPurifier_AttrDef_CSS_Multiple.m
//   HTMLPurifier
//
//  Created by Roman Priebe on 10.01.14.


#import "HTMLPurifier_AttrDef_CSS_Multiple.h"
#import "BasicPHP.h"

@implementation HTMLPurifier_AttrDef_CSS_Multiple

- (id)initWithSingle:(HTMLPurifier_AttrDef*)newSingle max:(NSNumber*)newMax
{
    self = [super init];
    if (self) {
        _single = newSingle;
        _max = newMax;
    }
    return self;
}

- (id)initWithSingle:(HTMLPurifier_AttrDef*)single
{
    return [self initWithSingle:single max:@4];
}


- (instancetype)initWithCoder:(NSCoder*)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        _single = [coder decodeObjectForKey:@"single"];
        _max = [coder decodeObjectForKey:@"max"];
    }
    return self;
}



- (void)encodeWithCoder:(NSCoder*)encoder
{
    [super encodeWithCoder:encoder];
    [encoder encodeObject:_single forKey:@"single"];
    [encoder encodeObject:_max forKey:@"max"];
}


- (BOOL)isEqual:(id)other
{
    if (other == self) {
        return YES;
    } else if (![super isEqual:other]) {
        return NO;
    } else if(![other isKindOfClass:[HTMLPurifier_AttrDef_CSS_Multiple class]])
    {
        return NO;
    }
    else
    {
        return ((!self.single && ![(HTMLPurifier_AttrDef_CSS_Multiple*)other single]) || [self.single isEqual:[(HTMLPurifier_AttrDef_CSS_Multiple*)other single]]) && ((!self.max && ![(HTMLPurifier_AttrDef_CSS_Multiple*)other max]) || [self.max isEqual:[(HTMLPurifier_AttrDef_CSS_Multiple*)other max]]);
    }
}

- (NSUInteger)hash
{
    return [_single hash] ^ [_max hash] ^ [super hash];
}












- (NSString*)validateWithString:(NSString*)string config:(HTMLPurifier_Config*)config context:(HTMLPurifier_Context*)context
{
    string = [self parseCDATAWithString:string];
    if ([string isEqual:@""]) {
        return nil;
    }
    NSArray* parts = explode(@" ", string); // parseCDATA replaced \r, \t and \n
    NSInteger length = parts.count;
    NSMutableString* finalString = [@"" mutableCopy];
    NSInteger num = 0;
    for (NSInteger i = 0; i < length && num < self.max.integerValue; i++)
    {
        if (ctype_space(parts[i])) {
            continue;
        }
        NSString* result = [self.single validateWithString:parts[i] config:config context:context];
        if (result != nil) {
            [finalString appendFormat:@"%@ ", result];
            num++;
        }
    }
    if ([finalString isEqual:@""]) {
        return nil;
    }
    return trim(finalString);
}



@end
