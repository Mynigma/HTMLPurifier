//
//  BasicPHP.m
//  HTMLPurifier
//
//  Created by Roman Priebe on 10.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "BasicPHP.h"
#import <CommonCrypto/CommonHMAC.h>


NSString* preg_replace_3(NSString* pattern, NSString* replacement, NSString* subject)
{
    if(!subject || !replacement || !pattern)
        return subject;

    NSError* error = nil;

    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];

    NSMutableString* subjectString = [subject mutableCopy];
    [regex replaceMatchesInString:subjectString options:0 range:NSMakeRange(0, subjectString.length) withTemplate:replacement];

    return subjectString;
}


//TODO
NSArray* preg_split_2(NSString* expression, NSString* subject)
{
    NSRegularExpression *exp = [NSRegularExpression regularExpressionWithPattern:expression options:0 error:nil];

    NSArray *matches = [exp matchesInString:subject options:0 range:NSMakeRange(0, [subject length])];

    NSMutableArray *results = [NSMutableArray new];

    if ([matches count] == 0)
    {
        [results addObject:subject];
        return results;
    }

    //start @beginning
    NSInteger loc = 0;

    for (NSTextCheckingResult *match in matches) {

        //range of the match
        NSRange match_range = [match range];

        //lenght from loc to this match
        NSInteger len = match_range.location - loc;

        // make range
        NSRange range = NSMakeRange(loc, len);
        //add string, even if empty
        [results addObject:[subject substringWithRange:range]];
        // set the new loc
        loc = match_range.location + match_range.length;
    }

    // get the last straw
    if (loc < [subject length])
    {
        [results addObject:[subject substringWithRange:NSMakeRange(loc, [subject length]-loc)]];
    }

    return results;
}

// Limit: max limit elements in returned array
NSArray* preg_split_3(NSString* expression, NSString* subject, NSInteger limit)
{
    if (limit <= 0)
    {
        return preg_split_2(expression,subject);
    }

    NSRegularExpression *exp = [NSRegularExpression regularExpressionWithPattern:expression options:0 error:nil];

    NSArray *matches = [exp matchesInString:subject options:0 range:NSMakeRange(0, [subject length])];

    NSMutableArray *results = [NSMutableArray new];

    if ([matches count] == 0)
    {
        [results addObject:subject];
        return results;
    }

    //start @beginning
    NSInteger loc = 0;

    for (NSTextCheckingResult *match in matches) {

        // we only want #limit-elements
        if ([results count] >= limit - 1)
            break;
        //range of the match
        NSRange match_range = [match range];

        //lenght from loc to this match
        NSInteger len = match_range.location - loc;

        // make range
        NSRange range = NSMakeRange(loc, len);
        //add string, even if empty
        [results addObject:[subject substringWithRange:range]];
        // set the new loc
        loc = match_range.location + match_range.length;
    }

    // get the last straw
    if (loc < [subject length])
    {
        [results addObject:[subject substringWithRange:NSMakeRange(loc, [subject length]-loc)]];
    }

    return results;
}

/* *** Instead directly with FLAG ***
 NSArray* preg_split_4(NSString* expression, NSString* subject, NSInteger limit, NSInteger* flag)
 {

 if (flag == 0)
 return preg_split_3(expression,subject,limit);

 NSRegularExpression *exp = [NSRegularExpression regularExpressionWithPattern:expression options:0 error:nil];

 NSArray *matches = [exp matchesInString:subject options:0 range:NSMakeRange(0, [subject length])];

 NSMutableArray *results = [NSMutableArray new];

 if ([matches count] == 0)
 {
 [results addObject:subject];
 return results;
 }

 //start @beginning
 NSInteger loc = 0;

 for (NSTextCheckingResult *match in matches) {

 // we only want #limit-elements
 if ([results count] >= limit - 1)
 break;

 //range of the match
 NSRange match_range = [match range];

 //lenght from loc to this match
 NSInteger len = match_range.location - loc;

 // make range
 NSRange range = NSMakeRange(loc, len);
 //add string, even if empty
 [results addObject:[subject substringWithRange:range]];
 // set the new loc
 loc = match_range.location + match_range.length;
 }

 // get the last straw
 if (loc < [subject length])
 {
 [results addObject:[subject substringWithRange:NSMakeRange(loc, [subject length]-loc)]];
 }

 return results;
 }
 */

NSArray* preg_split_2_PREG_SPLIT_DELIM_CAPTURE(NSString* expression, NSString* subject)
{
    NSRegularExpression *exp = [NSRegularExpression regularExpressionWithPattern:expression options:0 error:nil];

    NSArray *matches = [exp matchesInString:subject options:0 range:NSMakeRange(0, [subject length])];

    NSMutableArray *results = [NSMutableArray new];

    if ([matches count] == 0)
    {
        [results addObject:subject];
        return results;
    }

    //start @beginning
    NSInteger loc = 0;

    for (NSTextCheckingResult *match in matches) {

        //range of the match
        NSRange match_range = [match range];

        //lenght from loc to this match
        NSInteger len = match_range.location - loc;

        // make range
        NSRange range = NSMakeRange(loc, len);
        //add string, even if empty
        [results addObject:[subject substringWithRange:range]];

        // sets the delimiter
        [results addObject:[subject substringWithRange:match_range]];

        // set the new loc
        loc = match_range.location + match_range.length;
    }

    // get the last straw
    if (loc < [subject length])
    {
        [results addObject:[subject substringWithRange:NSMakeRange(loc, [subject length]-loc)]];
    }

    return results;
}


NSArray* preg_split_3_PREG_SPLIT_DELIM_CAPTURE(NSString* expression, NSString* subject, NSInteger limit)
{

    if (limit <= 0)
        return preg_split_2_PREG_SPLIT_DELIM_CAPTURE(expression,subject);

    NSRegularExpression *exp = [NSRegularExpression regularExpressionWithPattern:expression options:0 error:nil];

    NSArray *matches = [exp matchesInString:subject options:0 range:NSMakeRange(0, [subject length])];

    NSMutableArray *results = [NSMutableArray new];

    if ([matches count] == 0)
    {
        [results addObject:subject];
        return results;
    }

    //start @beginning
    NSInteger loc = 0;

    //don't count the added delimiter
    NSInteger count = 0;

    for (NSTextCheckingResult *match in matches) {

        // we only want #limit-elements
        if (count >= limit - 1)
            break;

        //range of the match
        NSRange match_range = [match range];

        //lenght from loc to this match
        NSInteger len = match_range.location - loc;

        // make range
        NSRange range = NSMakeRange(loc, len);
        //add string, even if empty
        [results addObject:[subject substringWithRange:range]];

        //adds the delimiter
        [results addObject:[subject substringWithRange:match_range]];

        // set the new loc
        loc = match_range.location + match_range.length;

        count++;
    }

    // get the last straw
    if (loc < [subject length])
    {
        [results addObject:[subject substringWithRange:NSMakeRange(loc, [subject length]-loc)]];
    }

    return results;
}


BOOL preg_match_2(NSString* pattern, NSString* subject)
{
    NSError* error = nil;

    NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];

    NSTextCheckingResult* result = [regex firstMatchInString:subject options:0 range:NSMakeRange(0,subject.length)];

    return (result != nil);
}

BOOL preg_match_2_WithLineBreak(NSString* pattern, NSString* subject)
{
    NSError* error = nil;
    
    NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators error:&error];
    
    NSTextCheckingResult* result = [regex firstMatchInString:subject options:0 range:NSMakeRange(0,subject.length)];
    
    return (result != nil);
}


//Returns all matches & subpattern matches
// Structure is array of arrays
BOOL preg_match_all_3(NSString* pattern, NSString* subject, NSMutableArray* matches)
{

    NSError* error = nil;

    // make regex
    NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];

    //match all in Strings
    NSArray* result = [regex matchesInString:subject options:0 range:NSMakeRange(0, subject.length)];

    //empty matches:
    [matches removeAllObjects];

    // found nothing?
    if ([result count] == 0)
    {
        return NO;
    }

    // # of matches
    NSUInteger num_matches = [result count];

    //sanity check
    if(num_matches == 0)
    {
        return NO;
    }

    //count the number of found submatches
    //No difference between match.numberOfRanges and regex.numberOfCaptureGroups + 1 (the whole match)
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
                [matches addObject:[NSMutableArray new]];

            // if the subpattern did not actually match anything.
            if ([match rangeAtIndex:j].location == NSNotFound)
                continue;

            //finally add the matched string
            [matches[j] addObject:[subject substringWithRange:[match rangeAtIndex:j]]];

        }

        //all initiated
        initArrays = NO;

    }

    return YES;
}

BOOL preg_match_3(NSString* pattern, NSString* subject, NSMutableArray* matches)
{
    NSError* error = nil;

    NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];

    NSTextCheckingResult* result = [regex firstMatchInString:subject options:0 range:NSMakeRange(0, subject.length)];

    [matches removeAllObjects];

    // matched nothing?
    if (result == nil)
        return NO;

    for(NSUInteger i = 0; i<result.numberOfRanges; i++)
    {
        if([result rangeAtIndex:i].location!=NSNotFound)
            [matches addObject:[subject substringWithRange:[result rangeAtIndex:i]]];
        else
            [matches addObject:@""];
    }

    //Matched at least one thing
    return YES;
}

BOOL preg_match_3_withLineBreak(NSString* pattern, NSString* subject, NSMutableArray* matches)
{
    NSError* error = nil;
    
    NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators error:&error];
    
    NSTextCheckingResult* result = [regex firstMatchInString:subject options:0 range:NSMakeRange(0, subject.length)];
    
    [matches removeAllObjects];
    
    // matched nothing?
    if (result == nil)
        return NO;
    
    for(NSUInteger i = 0; i<result.numberOfRanges; i++)
    {
        if([result rangeAtIndex:i].location!=NSNotFound)
            [matches addObject:[subject substringWithRange:[result rangeAtIndex:i]]];
        else
            [matches addObject:@""];
    }
    
    //Matched at least one thing
    return YES;
}


NSInteger preg_match_all_2(NSString* pattern, NSString* subject)
{
    NSError* error = nil;

    NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];

    return [regex numberOfMatchesInString:subject options:0 range:NSMakeRange(0, subject.length)];
}

BOOL ctype_xdigit(NSString* text)
{
    for(NSInteger i=0; i<text.length; i++)
    {
        unichar character = [text characterAtIndex:i];
        if(!isxdigit(character))
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


//better to use this, also recognizes negative numbers
BOOL stringIsNumeric(NSString *str)
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    
    //Recognize decimal number (e.g. 4.7)
    [formatter setDecimalSeparator:@"."];
    
    NSNumber *number = [formatter numberFromString:str];

    return !!number; // If the string is not numeric, number will be nil
}

//Does not check for  + - Upfront
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

NSString* trimCharacters(NSString* string, NSCharacterSet* characters)
{
    return [string stringByTrimmingCharactersInSet:characters];
}

NSString* htmlspecialchars_ENT_NOQUOTES(NSString* string)
{
    NSMutableString* newString = [NSMutableString new];
    for(NSInteger i = 0; i<string.length; i++)
    {
        switch([string characterAtIndex:i])
        {
            case '&':
                [newString appendString:@"&amp;"];
                break;
            /*case '"':
                [newString appendString:@"&quot;"];
                break;
            case '\'':
                [newString appendString:@"&#039"];
                break;*/
            case '<':
                [newString appendString:@"&lt;"];
                break;
            case '>':
                [newString appendString:@"&gt;"];
                break;
            default:
                [newString appendString:[string substringWithRange:NSMakeRange(i, 1)]];
        }
    }
    return newString;
}


NSString* htmlspecialchars(NSString* string)
{
    NSMutableString* newString = [NSMutableString new];
    for(NSInteger i = 0; i<string.length; i++)
    {
        switch([string characterAtIndex:i])
        {
            case '&':
                [newString appendString:@"&amp;"];
                break;
            case '"':
                [newString appendString:@"&quot;"];
                break;
            case '\'':
                [newString appendString:@"&#039"];
                break;
            case '<':
                [newString appendString:@"&lt;"];
                break;
            case '>':
                [newString appendString:@"&gt;"];
                break;
            default:
                [newString appendString:[string substringWithRange:NSMakeRange(i, 1)]];
        }
    }
    return newString;
}

NSString* htmlspecialchars_ENT_COMPAT(NSString* string)
{
    NSMutableString* newString = [NSMutableString new];
    for(NSInteger i = 0; i<string.length; i++)
    {
        switch([string characterAtIndex:i])
        {
            case '&':
                [newString appendString:@"&amp;"];
                break;
            case '"':
                [newString appendString:@"&quot;"];
                break;
                /*case '\'':
                 [newString appendString:@"&#039"];
                 break;*/
            case '<':
                [newString appendString:@"&lt;"];
                break;
            case '>':
                [newString appendString:@"&gt;"];
                break;
            default:
                [newString appendString:[string substringWithRange:NSMakeRange(i, 1)]];
        }
    }
    return newString;
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

NSInteger strrpos(NSString* haystack, NSString* needle)
{
    return [haystack rangeOfString:needle options:NSBackwardsSearch].location;
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

NSInteger strspn_2(NSString* subject, NSString* mask)
{
    NSInteger i = 0;
    for(; i<subject.length; i++)
    {
        if([mask rangeOfString:[subject substringWithRange:NSMakeRange(1, 1)]].location==NSNotFound)
        {
            break;
        }
    }
    return i;
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


NSString* ltrim_2(NSString* string, NSString* characterSetString)
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

NSString* rtrim(NSString* string)
{
    NSCharacterSet* characterSet = [NSCharacterSet characterSetWithCharactersInString:[NSString stringWithFormat:@" \t\n\r\0%c", 11]];
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


NSString* rtrim_2(NSString* string, NSString* characterSetString)
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

NSMutableArray* array_slice_2(NSArray* array, NSInteger offset)
{
    return [[array subarrayWithRange:NSMakeRange(offset, array.count - offset)] mutableCopy];
}

NSMutableArray* array_slice_3(NSArray* array, NSInteger offset, NSInteger length)
{
    return [[array subarrayWithRange:NSMakeRange(offset, length)] mutableCopy];
}

NSInteger array_unshift_2(NSMutableArray* array, NSObject* object)
{
    [array insertObject:object atIndex:0];
    return array.count;
}


NSObject* array_shift(NSMutableArray* array)
{
    if(array.count==0)
        return nil;
    NSObject* returnValue = array[0];
    [array removeObjectAtIndex:0];
    return returnValue;
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


NSInteger strcspn_2(NSString* string1, NSString* string2)
{
    return 0;
}


NSInteger strcspn_3(NSString* string1, NSString* string2, NSInteger start)
{
    return 0;
}

//TODO array_map_i
//Call back should be a function callback
NSArray* array_map_2(NSString* callback,NSArray* arrayWithInput)
{
    return nil;
}

//Call back should be a function callback
NSArray* array_map_3(NSString* callback,NSArray* arrayWithInput, NSArray* arrayWithArgs)
{
    return nil;
}


//array_merge can be used with morge input arrays ad needed.
NSArray* array_merge_2(NSArray* array1, NSArray* array2)
{

    NSMutableArray* array = [array1 mutableCopy];
    [array addObjectsFromArray:array2];

    return array;

}

//PHP array_merge also works as "dictionary_merge"
NSDictionary* dict_merge_2(NSDictionary* dict1, NSDictionary* dict2)
{
    NSMutableDictionary* dict = [dict1 mutableCopy];

    [dict addEntriesFromDictionary:dict2];

    return dict;
}



//TODO array_splice
NSArray* array_splice_4 (NSArray* ninput, NSInteger offset, NSInteger length, NSArray* replacement)
{
    NSMutableArray* input = [ninput mutableCopy];
    if (offset >= 0) {
        if (length > 0)
        {
            NSInteger maxLength = [input count] - offset;
            if (maxLength < length)
                length = maxLength;
            [input replaceObjectsInRange:NSMakeRange(offset,length) withObjectsFromArray:replacement];
            return input;
        }
        // TODO length <=0
    }
    //TODO offset < 0
    return nil;
}

NSInteger hexdec(NSString* hex_string)
{
    unsigned result = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hex_string];
    
    if ([hex_string characterAtIndex:0] == '#')
    {
        [scanner setScanLocation:1]; // bypass '#' character
    }
    else
    {
        [scanner setScanLocation:0];
    }
    
    [scanner scanHexInt:&result];
    
    return result;
}

NSString* dechex(NSString* dec_string)
{
    return [NSString stringWithFormat:@"%lX", (long)dec_string.integerValue];
}

NSData* base64_decode(NSString* base64String)
{
    NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:base64String options:0];
    // NSString *decodedString = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
    return decodedData;
}

NSString* base64_encode(NSString* plainString)
{
    NSData *plainData = [plainString dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64String = [plainData base64EncodedStringWithOptions:0];
    return base64String;
}


NSString* hash_hmac(NSString* algo, NSString* data, NSString* key)
{
    if ([algo isEqual:@"sha256"])
    {
        const char *cKey  = [key cStringUsingEncoding:NSASCIIStringEncoding];
        const char *cData = [data cStringUsingEncoding:NSASCIIStringEncoding];
        unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
        CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
        return [[NSString alloc] initWithData:[[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)]encoding:NSUTF8StringEncoding];
    }
    return nil;
}


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
    if(!pattern || !haystack)
        return nil;

    NSError* error = nil;

    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];

    NSArray* matches = [regex matchesInString:haystack options:0 range:NSMakeRange(0, haystack.length)];

    NSMutableString* newHaystack = [haystack mutableCopy];

    //NSMutableArray* replacements = [NSMutableArray new];

    for (NSTextCheckingResult *match in [matches reverseObjectEnumerator]) {

        NSMutableArray* resultArray = [NSMutableArray new];

        for(NSInteger index = 0; index < match.numberOfRanges; index++)
        {
            NSRange range = [match rangeAtIndex:index];
            if(range.location!=NSNotFound)
                [resultArray addObject:[haystack substringWithRange:range]];
            else
                [resultArray addObject:@""];
        }

        NSString* replacement = callBack(resultArray);

        if(replacement)
            [newHaystack replaceCharactersInRange:match.range withString:replacement];
    }

    return newHaystack;
}


@end
