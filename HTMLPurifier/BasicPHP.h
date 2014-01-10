//
//  BasicPHP.h
//  HTMLPurifier
//
//  Created by Roman Priebe on 10.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import <Foundation/Foundation.h>

NSString* preg_replace(NSString* pattern, NSString* replacement, NSString* subject)
{
    NSError* error = nil;

    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];

    NSMutableString* subjectString = [subject mutableCopy];
    [regex replaceMatchesInString:subjectString options:0 range:NSMakeRange(0, subjectString.length) withTemplate:replacement];

    return subjectString;
}

//preg_match_all

BOOL ctype_xdigit (NSString* text)
{
    for(NSInteger i=0; i<text.length; i++)
    {
        unichar character = [text characterAtIndex:i];
        if(character<'0')
            return NO;
        if(character>'9' && character<'A')
            return NO;
        if(character>'Z' && character<'a')
            return NO;
        if(character>'z')
            return NO;
    }
    return YES;
}

NSString* trim(NSString* string)
{
    return [string stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:[NSString stringWithFormat:@" \t\n\r\0%c", 11]]];
}

BOOL ctype_space(NSString* string)
{
    return trim(string).length==0;
}

NSObject* str_replace(NSObject* search, NSString* replace, NSString* subject)
{
    if([search isKindOfClass:[NSString class]])
        return [subject stringByReplacingOccurrencesOfString:(NSString*)search withString:replace];
    if([search isKindOfClass:[NSArray class]])
    {
        NSMutableArray* returnValue = [NSMutableArray new];
        for(NSString* string in (NSArray*)search)
            [returnValue addObject:str_replace(string, replace, subject)];
        return returnValue;
    }
    return nil;
}

NSString* substr(NSString* string, NSInteger start)
{
    return [string substringFromIndex:start];
}

//implode

NSArray* explode(NSString* limitString, NSString* string)
{
    return [string componentsSeparatedByString:limitString];
}

@interface BasicPHP : NSObject

+ (NSString*)trimWithString:(NSString*)string;

+ (NSString*)strReplaceWithSearch:(NSString*)search replace:(NSString*)replace subject:(NSString*)subject;

+ (NSString*)pregReplaceWithPattern:(NSString*)pattern replacement:(NSString*)replacement subject:(NSString*)subject;


@end
