//
//  BasicPHP.m
//  HTMLPurifier
//
//  Created by Roman Priebe on 10.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "BasicPHP.h"

@implementation BasicPHP

+ (NSString*)trimWithString:(NSString*)string
{
    return [string stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:[NSString stringWithFormat:@" \t\n\r\0%c", 11]]];
}

+ (NSString*)strReplaceWithSearch:(NSString*)search replace:(NSString*)replace subject:(NSString*)subject
{
    return [subject stringByReplacingOccurrencesOfString:search withString:replace];
}


+ (NSString*)pregReplaceWithPattern:(NSString*)pattern replacement:(NSString*)replacement subject:(NSString*)subject
{
    NSError* error = nil;
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];

    NSMutableString* subjectString = [subject mutableCopy];
    [regex replaceMatchesInString:subjectString options:0 range:NSMakeRange(0, subjectString.length) withTemplate:replacement];

    return subjectString;
}

+ (NSString*)pregReplace:(NSString*)pattern callback:(NSString*(^)(NSArray*))callBack haystack:(NSString*)haystack
{
    NSError* error = nil;

    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];

    NSArray* results = [regex matchesInString:haystack options:0 range:NSMakeRange(0, haystack.length)];

    NSString* replacement = callBack(results);

    NSMutableString* newHaystack = [haystack mutableCopy];

    [regex replaceMatchesInString:newHaystack options:0 range:NSMakeRange(0, haystack.length) withTemplate:replacement];

    return newHaystack;
}


@end
