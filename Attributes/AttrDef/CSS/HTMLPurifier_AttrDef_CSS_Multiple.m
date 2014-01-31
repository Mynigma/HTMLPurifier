//
//  HTMLPurifier_AttrDef_CSS_Multiple.m
//  HTMLPurifier
//
//  Created by Roman Priebe on 10.01.14.


#import "HTMLPurifier_AttrDef_CSS_Multiple.h"
#import "BasicPHP.h"

@implementation HTMLPurifier_AttrDef_CSS_Multiple

- (id)initWithSingle:(HTMLPurifier_AttrDef*)newSingle max:(NSInteger)newMax
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
    return [self initWithSingle:single max:4];
}


- (NSString*)validateWithString:(NSString*)string config:(HTMLPurifier_Config*)config context:(HTMLPurifier_Context*)context
{
    string = [self parseCDATAWithString:string];
    if ([string isEqualTo:@""]) {
        return NO;
    }
    NSArray* parts = explode(@" ", string); // parseCDATA replaced \r, \t and \n
    NSInteger length = parts.count;
    NSMutableString* finalString = [@"" mutableCopy];
    NSInteger num = 0;
    for (NSInteger i = 0; i < length && num < self.max; i++)
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
    if ([finalString isEqualTo:@""]) {
        return nil;
    }
    return trim(finalString);
}



@end
