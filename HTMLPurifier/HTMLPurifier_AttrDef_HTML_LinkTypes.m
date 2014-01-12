//
//  HTMLPurifier_AttrDef_HTML_LinkTypes.m
//  HTMLPurifier
//
//  Created by Lukas Neumann on 12.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_AttrDef_HTML_LinkTypes.h"
#import "HTMLPurifier.h"
#import "BasicPHP.h"

@implementation HTMLPurifier_AttrDef_HTML_LinkTypes

/**
 * Name config attribute to pull.
 * @type string
 */
@synthesize name;

/**
 * @param string $name
 */
-(id) initWithName:(NSString*)newName
{
    self = [super init];
    NSDictionary* configLookup = @{@"rel":@"AllowedRel", @"rev":@"AllowedRev"};
    
    if (!([newName isEqual:@"rel"] || [newName isEqual:@"rev"]))
    {
        TRIGGER_ERROR(@"Unrecognized attribute name for link relationship.",
                      E_USER_ERROR);
        return nil;
    }
    name = [configLookup objectForKey:newName];
    return self;
}

/**
 * @param string $string
 * @param HTMLPurifier_Config $config
 * @param HTMLPurifier_Context $context
 * @return bool|string
 */
-(NSString*) validateWithString:(NSString *)string config:(HTMLPurifier_Config *)config context:(HTMLPurifier_Context *)context
{
    NSDictionary* allowed = [config get:[NSString stringWithFormat:@"Attr.%@",name]];
    if (!allowed || [allowed isEqual:@""])
    {
        return nil;
    }
    
    string = [self parseCDATAWithString:string];
    NSArray* parts = explode(@" ",string);
    
    // lookup to prevent duplicates
    NSMutableArray* ret_lookup = [NSMutableArray new];
    for (NSString* part in parts)
    {
        NSString* thisPart = [part mutableCopy];
        thisPart = [trim(thisPart) lowercaseString];
        if (![allowed objectForKey:thisPart])
        {
            continue;
        }
        [ret_lookup addObject:thisPart];
    }
    
    if ([ret_lookup count] == 0)
    {
        return nil;
    }
    string = implode(@" ",ret_lookup);
    return string;
}

@end
