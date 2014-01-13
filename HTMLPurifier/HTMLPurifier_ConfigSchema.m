//
//  HTMLPurifier_ConfigSchema.m
//  HTMLPurifier
//
//  Created by Roman Priebe on 13.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_ConfigSchema.h"
#import "XPathQuery.m"
#import <libxml/parser.h>
#import <libxml/tree.h>


static HTMLPurifier_ConfigSchema* theSingleton;

@implementation HTMLPurifier_ConfigSchema

- (id)init
{
    self = [super init];
    if (self) {
        _defaults = [NSMutableDictionary new];
        _info = [NSMutableDictionary new];
    }
    return self;
}

+ (HTMLPurifier_ConfigSchema*)singleton
{
    if(!theSingleton)
        theSingleton = [HTMLPurifier_ConfigSchema new];
    return theSingleton;
}

+ (HTMLPurifier_ConfigSchema*)makeFromSerial
{
    NSData* contents = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Config" ofType:@"plist"]];
    if(!contents)
    {
        NSLog(@"Error opening config plist file!");
        return nil;
    }

    CFStringEncoding cfenc = CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding);
    CFStringRef cfencstr = CFStringConvertEncodingToIANACharSetName(cfenc);
    const char *enc = CFStringGetCStringPtr(cfencstr, 0);
    // _doc = htmlParseDoc((xmlChar*)[string UTF8String], enc);
    xmlDocPtr doc = xmlReadDoc ((xmlChar*)contents.bytes, NULL, enc, 0);

    NSDictionary* configDict = DictionaryForNode(&doc->children[0], nil);

    HTMLPurifier_ConfigSchema* r = [HTMLPurifier_ConfigSchema singleton];

    [r setDefaultPList:configDict[@"DefaultPropertyList"]];
    [r setInfo:[configDict[@"info"] mutableCopy]];
    [r setDefaults:[configDict[@"defaults"] mutableCopy]];
    
    if (!r) {
        NSLog(@"Unserialization of configuration schema failed");
    }
    return r;
}


@end
