//
//  HTMLPurifier_LanguageFactory.m
//  HTMLPurifier
//
//  Created by Lukas Neumann on 10.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_LanguageFactory.h"

@implementation HTMLPurifier_LanguageFactory


- (id)init
{
    self = [super init];
    if (self) {
        _keys = [@[@"fallback", @"messages", @"errorNames"] mutableCopy];
        mergeable_keys_map = [@{@"messages":@YES, @"errorNames":@YES} mutableCopy];
        mergeable_keys_list = [NSMutableDictionary new];
    }
    return self;
}


+ (HTMLPurifier_LanguageFactory*)instance
{
    return nil;
}

+ (HTMLPurifier_LanguageFactory*)instanceWithPrototype:(HTMLPurifier_LanguageFactory*)prototype
{
    return nil;
}

- (void)setup
{

}

- (HTMLPurifier_Language*)create:(HTMLPurifier_Config*)config context:(HTMLPurifier_Context*)context
{
    return nil;
}

- (NSString*)getFallbackFor:(NSString*)code
{
    return nil;
}

- (NSString*)loadLanguage:(NSString*)code
{
    return nil;
}

@end
