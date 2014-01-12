//
//  BasicPHP.h
//  HTMLPurifier
//
//  Created by Roman Priebe on 10.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import <Foundation/Foundation.h>

#define TRIGGER_ERROR NSLog

NSString* preg_replace(NSString* pattern, NSString* replacement, NSString* subject)
{
    NSError* error = nil;

    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];

    NSMutableString* subjectString = [subject mutableCopy];
    [regex replaceMatchesInString:subjectString options:0 range:NSMakeRange(0, subjectString.length) withTemplate:replacement];

    return subjectString;
}

//preg_match_all

//preg_match
//BOOL or Array?
NSArray* preg_match (NSString* pattern, NSString* subject)
{
    NSError* error = nil;
    
    NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];

    return [regex matchesInString:subject options:0 range:NSMakeRange(0, subject.length)];
}

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

BOOL ctype_digit (NSString* text)
{
    for(NSInteger i=0; i<text.length; i++)
    {
        unichar character = [text characterAtIndex:i];
        if(character<'0')
            return NO;
        if(character>'9')
            return NO;
    }
    return YES;
}

//TODO is_numeric (string)

NSString* trim(NSString* string)
{
    return [string stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:[NSString stringWithFormat:@" \t\n\r\0%c", 11]]];
}


//trim with Format like 'A..Za..z0..9:-._' some kind of regex
// TODO
NSString* trimWithFormat(NSString* string, NSString* format)
{
    return [string stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:format]];
}

//parse cdata

//ctype_alpha
BOOL ctype_alpha (NSString* text)
{
    for(NSInteger i=0;i <text.length; i++)
    {
        unichar character = [text characterAtIndex:i];
        if(!(isalpha(character)))
            return NO;
    }
    return YES;
}

BOOL ctype_space(NSString* string)
{
    return trim(string).length==0;
}

NSObject* str_replace(NSObject* search, NSObject* replace, NSString* subject)
{
    if([search isKindOfClass:[NSString class]])
        return [subject stringByReplacingOccurrencesOfString:(NSString*)search withString:(NSString*)replace];

    if([search isKindOfClass:[NSArray class]])
    {
        NSMutableString* returnValue = [subject mutableCopy];

        for(NSString* string in (NSArray*)search)
        {
        NSString* replaceString = @"";

            if([replace isKindOfClass:[NSString class]])
                replaceString = (NSString*)replace;

        if([replace isKindOfClass:[NSArray class]])
        {
            NSInteger index = [(NSArray*)search indexOfObject:string];
            if(index<[(NSArray*)replace count])
                replaceString = [(NSArray*)replace objectAtIndex:index];
            else
                replaceString = @"";
        }
        [returnValue replaceOccurrencesOfString:string withString:replaceString options:0 range:NSMakeRange(0,returnValue.length)];
        }
        return returnValue;
    }
    return nil;
}

NSInteger php_strspn(NSString* string, NSString* characterList)
{
    NSInteger index;
    for(index = 0; index<string.length; index++)
    {
        if([characterList rangeOfString:[string substringWithRange:NSMakeRange(index, 1)]].location==NSNotFound)
            {
                break;
            }
    }
    return index;
}

NSInteger strpos(NSString* haystack, NSString* needle)
{
    return [haystack rangeOfString:needle].location;
}

NSString* substr(NSString* string, NSInteger start)
{
    return [string substringFromIndex:start];
}

NSInteger substr_count(NSString* haystack , NSString* needle)
{
    NSUInteger count = 0, length = [haystack length];
    NSRange range = NSMakeRange(0, length);
    while(range.location != NSNotFound)
    {
        range = [haystack rangeOfString: needle options:0 range:range];
        if(range.location != NSNotFound)
        {
            range = NSMakeRange(range.location + range.length, length - (range.location + range.length));
            count++; 
        }
    }
    return count;
}


//does not work properly if there is overlap between substituted strings and strings to be replaced
NSString* strtr_php(NSString* fromString, NSDictionary* replacementDict)
{
    NSMutableString* substitutedString = [fromString mutableCopy];

    for(NSString* key in replacementDict)
    {
        [substitutedString replaceOccurrencesOfString:key withString:[replacementDict objectForKey:key] options:0 range:NSMakeRange(0, substitutedString.length)];
    }

    return substitutedString;
}

NSString* ltrim_whitespaces(NSString* string)
{
    NSUInteger location;
    NSUInteger length = [string length];
    unichar charBuffer[length];
    [string getCharacters:charBuffer];

    NSCharacterSet* characterSet = [NSCharacterSet characterSetWithCharactersInString:[NSString stringWithFormat:@" \t\n\r\0%c", 11]];

    for (location = 0; location < length; location++) {
        if (![characterSet characterIsMember:charBuffer[location]]) {
            break;
        }
    }

    return [string substringWithRange:NSMakeRange(location, length - location)];
}

NSString* rtrim_whitespaces(NSString* string)
{
    NSUInteger location = 0;
    NSUInteger length;
    unichar charBuffer[string.length];
    [string getCharacters:charBuffer];

    NSCharacterSet* characterSet = [NSCharacterSet characterSetWithCharactersInString:[NSString stringWithFormat:@" \t\n\r\0%c", 11]];
    
    for (length = string.length; length > 0; length--)
    {
        if (![characterSet characterIsMember:charBuffer[length - 1]]) {
            break;
        }
    }

    return [string substringWithRange:NSMakeRange(location, length - location)];
}


NSString* ltrim(NSString* string, NSString* characterSetString)
{
    NSCharacterSet* characterSet = [NSCharacterSet characterSetWithCharactersInString:characterSetString];
    NSUInteger location;
    NSUInteger length = [string length];
    unichar charBuffer[length];
    [string getCharacters:charBuffer];

    for (location = 0; location < length; location++) {
        if (![characterSet characterIsMember:charBuffer[location]]) {
            break;
        }
    }

    return [string substringWithRange:NSMakeRange(location, length - location)];
}

NSString* rtrim(NSString* string, NSString* characterSetString)
{
    NSCharacterSet* characterSet = [NSCharacterSet characterSetWithCharactersInString:characterSetString];
    NSUInteger location = 0;
    NSUInteger length;
    unichar charBuffer[string.length];
    [string getCharacters:charBuffer];

    for (length = string.length; length > 0; length--)
    {
        if (![characterSet characterIsMember:charBuffer[length - 1]]) {
            break;
        }
    }

    return [string substringWithRange:NSMakeRange(location, length - location)];
}


NSString* implode(NSString* glue, NSArray* pieces)
{
    return [pieces componentsJoinedByString:glue];
}

NSArray* explode(NSString* limitString, NSString* string)
{
    return [string componentsSeparatedByString:limitString];
}

NSMutableArray* array_reverse(NSMutableArray* oldArray)
{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:[oldArray count]];
    NSEnumerator *enumerator = [oldArray reverseObjectEnumerator];
    for (id element in enumerator) {
        [array addObject:element];
    }
    return array;
}

NSObject* array_pop(NSMutableArray* array)
{
    if(array.count<1)
        return nil;

    NSObject* object = [array objectAtIndex:array.count-1];
    [array removeObjectAtIndex:array.count-1];
    
    return object;
}

void array_push(NSMutableArray* array, NSObject* x)
{
    [array addObject:x];
}


@interface BasicPHP : NSObject

+ (NSString*)trimWithString:(NSString*)string;

+ (NSString*)strReplaceWithSearch:(NSString*)search replace:(NSString*)replace subject:(NSString*)subject;

+ (NSString*)pregReplaceWithPattern:(NSString*)pattern replacement:(NSString*)replacement subject:(NSString*)subject;

+ (NSString*)pregReplace:(NSString*)pattern callback:(NSString*(^)(NSArray*))callBack haystack:(NSString*)haystack;


@end
