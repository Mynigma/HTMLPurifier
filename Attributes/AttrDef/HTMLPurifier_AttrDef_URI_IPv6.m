//
//  HTMLPurifier_AttrDef_URI_IPv6.m
//  HTMLPurifier
//
//  Created by Lukas Neumann on 12.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_AttrDef_URI_IPv6.h"
#import "BasicPHP.h"

@implementation HTMLPurifier_AttrDef_URI_IPv6

/**
 * @param string $aIP
 * @param HTMLPurifier_Config $config
 * @param HTMLPurifier_Context $context
 * @return bool|string
 */
-(NSString*) validateWithString:(NSString *)aIP config:(HTMLPurifier_Config *)config context:(HTMLPurifier_Context *)context
{
    if (!super.ip4)
    {
        [super loadRegex];
    }
    
    NSString* original = [aIP copy];
    
    // not used
    // NSString* hex = @"[0-9a-fA-F]";
    // NSString* blk = [NSString stringWithFormat:@"(?:%@{1,4})",hex];
    NSString* pre = @"(?:/(?:12[0-8]|1[0-1][0-9]|[1-9][0-9]|[0-9]))"; // /0 - /128
    
    //      prefix check
    if (strpos(aIP, @"/") != NSNotFound) {
        NSMutableArray* matches = [NSMutableArray new];
        if (preg_match_3_withLineBreak([NSString stringWithFormat:@"%@$",pre],aIP,matches))
        {
            NSString* string = [matches objectAtIndex:0];
            if (aIP.length<string.length)
                return nil;
            aIP = [aIP substringToIndex:(aIP.length-string.length)];
        }
        else
        {
            return nil;
        }
    }
    
    
    //      IPv4-compatiblity check
    NSMutableArray* matches_ip4 = [NSMutableArray new];
    if (preg_match_3_withLineBreak([NSString stringWithFormat:@"(?<=:)%@$",super.ip4], aIP,matches_ip4))
    {
        NSString* string = [matches_ip4 objectAtIndex:0];
        if (aIP.length<string.length)
            return nil;
        aIP = [aIP substringToIndex:(aIP.length-string.length)];
        NSArray* dec_ip = explode(@".",string);
        
        // ip = array_map(@"dechex",ip);
        NSMutableArray* hex_ip = [NSMutableArray new];
        for (NSString* tmp in dec_ip) {
            [hex_ip addObject:dechex(tmp.copy)];
        }
        if ([hex_ip count] > 4) // exception security
            return nil;
        aIP = [NSString stringWithFormat:@"%@%@%@:%@%@",aIP,[hex_ip objectAtIndex:0],[hex_ip objectAtIndex:1],[hex_ip objectAtIndex:2],[hex_ip objectAtIndex:3]];
    }
    
    //      compression check
    NSArray* aIP_array = explode(@"::", aIP);
    NSUInteger c = [aIP_array count];
    if (c > 2)
    {
        return nil;
    }
    else if (c == 2)
    {
        NSString* first = [aIP_array objectAtIndex:0];
        NSString* second = [aIP_array objectAtIndex:1];
        NSMutableArray* first_array = [explode(@":", first) mutableCopy];
        NSMutableArray* second_array = [explode(@":", second)mutableCopy];
        
        if ([first_array count] + [second_array count] > 8)
        {
            return nil;
        }
        
        while ([first_array count] < 8) {
            array_push(first_array, @"0");
        }
        
        //TODO array_splice
        aIP_array = array_splice_4(first_array, 8 - [second_array count], 8, second_array);
    }
    else
    {
        if (c==0)
            return nil;
        aIP_array = explode(@":", [aIP_array objectAtIndex:0]);
    }
    
    c = [aIP_array count];
    
    if (c != 8)
    {
        return nil;
    }
    
    //[NSString stringWithFormat:@"%lX",(long)piece.intValue]
    
    //      All the pieces should be 16-bit hex strings. Are they?
    for (NSString* piece in aIP_array)
    {
        if ( (piece.length <=4) && !ctype_xdigit(piece)) //was "%04s"
        {
            return nil;
        }
    }
    return original;
}

@end
