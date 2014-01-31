//
//  HTMLPurifier_Language.m
//  HTMLPurifier
//
//  Created by Lukas Neumann on 10.01.14.


#import "HTMLPurifier_Language.h"

@implementation HTMLPurifier_Language

- (id)initWithConfig:(HTMLPurifier_Config*)newConfig context:(HTMLPurifier_Context*)newContext
{
    return [self init];
}
- (id)initWithConfig:(HTMLPurifier_Config*)newConfig
{
    return [self init];
}

- (id)init
{
    self = [super init];
    if (self) {
        _code = @"en";
        _fallback = nil;
        _messages = [NSMutableDictionary new];
        _errorNames = [NSMutableDictionary new];
        _error = NO;
        _loaded = NO;
    }
    return self;
}

- (void)load
{

}

- (NSString*)getMessage:(NSString*)key
{
    return nil;
}

- (NSString*)getErrorName:(NSInteger)phpErrorCode
{
    return nil;
}

- (NSString*)listify:(NSObject*)object
{
    return nil;
}

- (NSString*)formatMessage:(NSString*)key
{
    return nil;
}

- (NSString*)formatMessage:(NSString*)key args:(NSArray*)args
{
    return nil;
}


@end
