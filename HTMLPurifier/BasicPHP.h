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


// Returns the first match + subpattern matches in that match
// instead of return BOOL and using an return Array as ARG. return Array , if not found return nil || empty array ?? TODO
NSArray* preg_match (NSString* pattern, NSString* subject)
{
    NSError* error = nil;
    
    NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSTextCheckingResult* result = [regex firstMatchInString:subject options:0 range:NSMakeRange(0,subject.length)];
    
    if (!result)
    {
        return nil;
    }
    
    if ([result range].location == NSNotFound)
    {
        return nil;
    }
    
    NSMutableArray* findings = [NSMutableArray new];
    
    [findings addObject:[subject substringWithRange:[result range]]];
    
    for (NSInteger i = 1; i < [result numberOfRanges]; i++)
    {
        NSRange range = [result rangeAtIndex:i];
        if (range.location == NSNotFound)
            continue;
        [findings addObject:[subject substringWithRange:range]];
    }
    
    return findings;
    
}


//Returns all matches & subpattern matches
// Structure is array of arrays
NSArray* preg_match_all(NSString* pattern, NSString* subject)
{
    
    NSError* error = nil;
    
    // make regex
    NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    
    //match all in Strings
    NSArray* result = [regex matchesInString:subject options:0 range:NSMakeRange(0, subject.length)];

    // found nothing?
    if (!result)
    {
        return nil;
    }
    
    // # of matches
    NSUInteger num_matches = [result count];
    
    //sanity check
    if(num_matches == 0)
    {
        return nil;
    }
    
    NSMutableArray* findings = [NSMutableArray new];
    
    //count the number of found submatches
    //No differenz between match.numberOfRanges and regex.numberOfCaptureGroups + 1 (the whole match)
    NSUInteger num_submatches = [regex numberOfCaptureGroups] + 1;
    
    BOOL initArrays = YES;
    
    //go through all matches
    for (NSTextCheckingResult* match in result)
    {
        //this cannot happen, "that's what she said"
        if([match range].location == NSNotFound)
            continue;
        
        //go through all submatches
        for (NSInteger j = 0; j < num_submatches; j++)
        {
            // Init Arrays for the first match
            if (initArrays)
                [findings addObject:[NSMutableArray new]];
            
            // if the subpattern did not actually match anything.
            if ([match rangeAtIndex:j].location == NSNotFound)
                continue; //With this we may have some empty arrays, but at least the Order remains. Don't know how PHP deals with this.
            
            //finally add the matched string
            [findings[j] addObject:[subject substringWithRange:[match rangeAtIndex:j]]];
            
        }
        
        //all initiated
        initArrays = NO;
        
    }
    
    return findings;

}

//TODO preg_split

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

NSString* decodeXMLEntities(NSString* string)
{
    NSUInteger myLength = [string length];
    NSUInteger ampIndex = [string rangeOfString:@"&" options:NSLiteralSearch].location;

    // Short-circuit if there are no ampersands.
    if (ampIndex == NSNotFound) {
        return string;
    }
    // Make result string with some extra capacity.
    NSMutableString *result = [NSMutableString stringWithCapacity:(myLength * 1.25)];

    // First iteration doesn't need to scan to & since we did that already, but for code simplicity's sake we'll do it again with the scanner.
    NSScanner *scanner = [NSScanner scannerWithString:string];

    [scanner setCharactersToBeSkipped:nil];

    NSCharacterSet *boundaryCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@" \t\n\r;"];

    do {
        // Scan up to the next entity or the end of the string.
        NSString *nonEntityString;
        if ([scanner scanUpToString:@"&" intoString:&nonEntityString]) {
            [result appendString:nonEntityString];
        }
        if ([scanner isAtEnd]) {
            goto finish;
        }
        // Scan either a HTML or numeric character entity reference.
        if ([scanner scanString:@"&amp;" intoString:NULL])
            [result appendString:@"&"];
        else if ([scanner scanString:@"&apos;" intoString:NULL])
            [result appendString:@"'"];
        else if ([scanner scanString:@"&quot;" intoString:NULL])
            [result appendString:@"\""];
        else if ([scanner scanString:@"&lt;" intoString:NULL])
            [result appendString:@"<"];
        else if ([scanner scanString:@"&gt;" intoString:NULL])
            [result appendString:@">"];
        else if ([scanner scanString:@"&#" intoString:NULL]) {
            BOOL gotNumber;
            unsigned charCode;
            NSString *xForHex = @"";

            // Is it hex or decimal?
            if ([scanner scanString:@"x" intoString:&xForHex]) {
                gotNumber = [scanner scanHexInt:&charCode];
            }
            else {
                gotNumber = [scanner scanInt:(int*)&charCode];
            }

            if (gotNumber) {
                [result appendFormat:@"%C", (unichar)charCode];

                [scanner scanString:@";" intoString:NULL];
            }
            else {
                NSString *unknownEntity = @"";

                [scanner scanUpToCharactersFromSet:boundaryCharacterSet intoString:&unknownEntity];


                [result appendFormat:@"&#%@%@", xForHex, unknownEntity];

                //[scanner scanUpToString:@";" intoString:&unknownEntity];
                //[result appendFormat:@"&#%@%@;", xForHex, unknownEntity];
                NSLog(@"Expected numeric character entity but got &#%@%@;", xForHex, unknownEntity);

            }

        }
        else {
            NSString *amp;

            [scanner scanString:@"&" intoString:&amp];  //an isolated & symbol
            [result appendString:amp];

            /*
             NSString *unknownEntity = @"";
             [scanner scanUpToString:@";" intoString:&unknownEntity];
             NSString *semicolon = @"";
             [scanner scanString:@";" intoString:&semicolon];
             [result appendFormat:@"%@%@", unknownEntity, semicolon];
             NSLog(@"Unsupported XML character entity %@%@", unknownEntity, semicolon);
             */
        }
        
    }
    while (![scanner isAtEnd]);
    
finish:
    return result;
}

BOOL ctype_lower (NSString* text)
{
return ([text isEqual:[text lowercaseString]]);
}


BOOL ctype_alnum(NSString* string)
{
    for(NSInteger i=0;i <string.length; i++)
    {
        unichar character = [string characterAtIndex:i];
        if(!(isalnum(character)))
            return NO;
    }
    return YES;
}


BOOL is_numeric(NSString* string)
{
    for(NSInteger i=0;i <string.length; i++)
    {
        unichar character = [string characterAtIndex:i];
        if(!(isnumber(character)))
            return NO;
    }
    return YES;
}


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

NSArray* explodeWithLimit(NSString* delimiter, NSString* string, NSInteger limit)
{
    NSArray* exploded = [string componentsSeparatedByString:delimiter];
    
    if (limit >= [exploded count]){
        return exploded;
    }
    NSMutableArray* result;
    for (int i = 0; i < limit-1 ; i++)
    {
        [result addObject:[exploded objectAtIndex:i]];
    }
    NSString* lastString = @"";
    for (NSInteger j = limit-1; j < [exploded count]; j++)
    {
        lastString = [lastString stringByAppendingString:[exploded objectAtIndex:j]];
    }
    [result addObject:lastString];
    return result;
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


//TODO
//array_shift

//TODO array_map

//TODO array_splice(first_array, 8 - [second_array count], 8, second_array);


@interface BasicPHP : NSObject

+ (NSString*)trimWithString:(NSString*)string;

+ (NSString*)strReplaceWithSearch:(NSString*)search replace:(NSString*)replace subject:(NSString*)subject;

+ (NSString*)pregReplaceWithPattern:(NSString*)pattern replacement:(NSString*)replacement subject:(NSString*)subject;

+ (NSString*)pregReplace:(NSString*)pattern callback:(NSString*(^)(NSArray*))callBack haystack:(NSString*)haystack;


@end
