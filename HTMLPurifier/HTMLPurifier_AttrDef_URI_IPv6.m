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
-(NSString*) validateWithAip:(NSString *)aIP Config:(HTMLPurifier_Config *)config Context:(HTMLPurifier_Context *)context
{
    return nil;
//    if (!super.ip4) {
//        [super loadRegex];
//    }
//    
//    NSString* original = [aIP copy];
//    
//    NSString* hex = @"[0-9a-fA-F]";
//    NSString* blk = [NSString stringWithFormat:@"(?:%@{1,4})",hex];
//    NSString* pre = @"(?:/(?:12[0-8]|1[0-1][0-9]|[1-9][0-9]|[0-9]))"; // /0 - /128
//    
//    NSArray* find = nil;
//    //      prefix check
//    if (strpos(aIP, @"/") != NSNotFound) {
//        find = preg_match_2([NSString stringWithFormat:@"#%@$#s",pre],aIP);
//        if (find)
//        {
//            NSString* string = [find objectAtIndex:0];
//            aIP = [aIP substringToIndex:(aIP.length-string.length)];
//            
//        }
//        else
//        {
//            return nil;
//        }
//    }
//    
//    //      IPv4-compatiblity check
//    BOOL find = preg_match_2([NSString stringWithFormat:@"#(?<=:)%@$#s",super.ip4], aIP);
//    if (find)
//    {
//        NSString* string = [find objectAtIndex:0];
//        aIP = [aIP substringToIndex:(aIP.length-string.length)];
//        NSArray* ip = explode(@".",string);
//        ip = array_map(@"dechex",ip);
//        aIP = [NSString stringWithFormat:@"%@%@%@:%@%@",aIP,[ip objectAtIndex:0],[ip objectAtIndex:1],[ip objectAtIndex:2],[find objectAtIndex:3]];
//      //unset($find, $ip); deletes both variables
//    }
//    
//    //      compression check
//    NSArray* aIP_array = explode(@"::", aIP);
//    NSUInteger c = [aIP_array count];
//    if (c > 2)
//    {
//        return nil;
//    }
//    else if (c == 2)
//    {
//        NSString* first = [aIP_array objectAtIndex:0];
//        NSString* second = [aIP_array objectAtIndex:1];
//        NSMutableArray* first_array = [explode(@":", first) mutableCopy];
//        NSMutableArray* second_array = [explode(@":", second)mutableCopy];
//        
//        if ([first_array count] + [second_array count] > 8)
//        {
//            return nil;
//        }
//        
//        while ([first_array count] < 8) {
//            array_push(first_array, @"0");
//        }
//        
//        //TODO array_splice
//        array_splice(first_array, 8 - [second_array count], 8, second_array);
//        aIP_array = first_array;
//        
//        //unset($first, $second);
//    }
//    else
//    {
//        aIP_array = explode(@":", [aIP_array objectAtIndex:0]);
//    }
//    
//    c = [aIP_array count];
//    
//    if (c != 8)
//    {
//        return nil;
//    }
//    
//    //      All the pieces should be 16-bit hex strings. Are they?
//    for (NSString* piece in aIP_array)
//    {
//        if (!preg_match(@"#^[0-9a-fA-F]{4}$#s",
//                        [NSString stringWithFormat:@"%4@",piece])) //original "%04s"
//        {
//            return nil;
//        }
//    }
//    return original;
}

@end
