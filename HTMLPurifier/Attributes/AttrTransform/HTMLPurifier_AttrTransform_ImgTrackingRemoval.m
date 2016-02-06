//
//  HTMLPurifier_AttrTransform_ImgTrackingRemoval.m
//  HTMLPurifier
//
//  Created by Lukas Neumann on 06.02.16.
//  Copyright © 2016 Mynigma. All rights reserved.
//

#import "HTMLPurifier_AttrTransform_ImgTrackingRemoval.h"
#import "HTMLPurifier_Context.h"
#import "HTMLPurifier_Config.h"
#import "BasicPHP.h"


/**
 * Transforms tracking pixels, such that they are disabled.
 * Exchanges the src URL with a blue pixel and adds an identifier as alt text
 * This can be registered as a pre or post attribute transform.
 **/

@implementation HTMLPurifier_AttrTransform_ImgTrackingRemoval


- (NSDictionary*)transform:(NSDictionary*)passedAttr sortedKeys:(NSMutableArray*)sortedKeys config:(HTMLPurifier_Config*)config context:(HTMLPurifier_Context*)context
{
    NSMutableDictionary* attr = [passedAttr mutableCopy];
    
    // check if this is enabled
    if ([[config get:@"Core.RemoveTrackingPixel"] isEqual:@NO])
        return attr;
    
    // find width and length attributes
    NSNumber* width = [self transformLengthToInt: attr[@"width"]];
    NSNumber* height = [self transformLengthToInt: attr[@"height"]];

    if (height && width && height.intValue <= 1 && width.intValue <= 1) {
        // educated guess: this is a tracking pixel
        
        // now set a blue pixel as source
        attr[@"src"] = @"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAIAAACQd1PeAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAB3RJTUUH4AIGDTonDUBF3wAAAB1pVFh0Q29tbWVudAAAAAAAQ3JlYXRlZCB3aXRoIEdJTVBkLmUHAAAADElEQVQI12NQi+gHAAG1AQ6Ex5VQAAAAAElFTkSuQmCC";
        
        // if there is an alt attribute replace it
        if (!attr[@"alt"])
        {
            [attr setObject:@"MynigmaTrackingPixelReplacement4711" forKey:@"alt"];
            [sortedKeys addObject:@"alt"];
        }
        else
        {
            attr[@"alt"] = @"MynigmaTrackingPixelReplacement4711";
        }
        
    }
    
    return attr;
}

- (NSNumber*)transformLengthToInt:(NSString*)string
{
    string = trim(string);
    if ([string isEqual:@""])
    {
        return nil;
    }
    
    NSUInteger length = string.length;
    
    if ((length >= 2) && [substr(string,length - 2) isEqual:@"px"])
    {
        string = [string substringToIndex:(length - 2)];
    }
    
    if (!stringIsNumeric(string))
    {
        return nil;
    }
    
    NSInteger num = [string integerValue];
    
    if (num < 0)
    {
        return 0;
    }

    return @(num);
}


@end
