//
//  HTMLPurifier_URIScheme_ftp.m
//  HTMLPurifier
//
//  Created by Lukas Neumann on 19.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_URIScheme_ftp.h"
#import "HTMLPurifier_URI.h"
#import "BasicPHP.h"
#import "HTMLPurifier_PercentEncoder.h"

/**
 * Validates ftp (File Transfer Protocol) URIs as defined by generic RFC 1738.
 */
@implementation HTMLPurifier_URIScheme_ftp


-(id) init
{
    self = [super init];
    super.default_port = @(21);
    super.browsable = @YES;
    super. hierarchical = @YES;
    return self;
}

/**
 * @param HTMLPurifier_URI $uri
 * @param HTMLPurifier_Config $config
 * @param HTMLPurifier_Context $context
 * @return bool
 */
-(BOOL) doValidate:(HTMLPurifier_URI*)uri config:(HTMLPurifier_Config*)config context:(HTMLPurifier_Context*)context
{
    [uri setQuery:nil];
    
    // typecode check
    NSInteger semicolon_pos = strrpos([uri path], @";"); // reverse
    
    if (semicolon_pos != NSNotFound)
    {
        // breaking a butterfly on a wheel
        // HTMLPurifier_PercentEncoder* enc = [HTMLPurifier_PercentEncoder new];
        // NSString* encoded_path = nil;
        NSString* type = [[uri path] substringFromIndex:semicolon_pos + 1]; // no semicolon
        [uri setPath:[[uri path] substringToIndex:semicolon_pos]];
        NSString* type_ret = @"";
        if (strpos(type, @"=") != NSNotFound)
        {
            // figure out whether or not the declaration is correct
            NSArray* temp = explodeWithLimit(@"=",type,2);
            NSString* key = temp[0];
            NSString* typecode = temp[1];
            if (![key isEqual:@"type"])
            {
                // invalid key, tack it back on encoded
                //encoded_path = [enc encode:[NSString stringWithFormat:@"%@;%@",[uri path],type]];
                [uri setPath:[NSString stringWithFormat:@"%@%%3B%@",[uri path],type]];
            }
            else if ([typecode isEqual:@"a"] || [typecode isEqual:@"i"] || [typecode isEqual:@"d"])
            {
                type_ret = [@";type=" stringByAppendingString:typecode];
            }
        }
        else
        {
            // encoded_path = [enc encode:[NSString stringWithFormat:@"%@;%@",[uri path],type]];
            [uri setPath:[NSString stringWithFormat:@"%@%%3B%@",[uri path],type]];
        }
        [uri setPath:(NSString*)str_replace(@";", @"%3B", [uri path])];
        [uri setPath:[[uri path] stringByAppendingString:type_ret]];
    }
    return YES;
}

@end
