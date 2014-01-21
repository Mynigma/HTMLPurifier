//
//  HTMLPurifier_URIScheme_data.m
//  HTMLPurifier
//
//  Created by Lukas Neumann on 19.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//



#import "HTMLPurifier_URIScheme_data.h"
#import "HTMLPurifier_URI.h"
#import "BasicPHP.h"

/**
 * Implements data: URI for base64 encoded images supported by GD.
 */
@implementation HTMLPurifier_URIScheme_data

@synthesize allowed_types;

-(id) init
{
    self = [super init];
    super.browsable = @YES;
    
    // this is actually irrelevant since we only write out the path
    // component
    super.may_omit_host = @YES;
    
    
    // you better write validation code for other types if you
    // decide to allow them
    self.allowed_types = @[@"image/jpeg",@"image/gif",@"image/png"];
    
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
    NSArray* result = explodeWithLimit(@",",[uri path], 2);
    BOOL is_base64 = NO;
    
    NSString* charset = nil;
    
    NSString* content_type = nil;
    
    NSString* data = nil;
    
    if ([result count] == 2)
    {
        NSString* metadata = result[0];
        data = result[1];
        // do some legwork on the metadata
        NSMutableArray* metas = [explode(@";", metadata) mutableCopy];
        while ([metas count] != 0)
        {
            NSString* cur = (NSString*)array_shift(metas);
            if ([cur isEqual:@"base64"])
            {
                is_base64 = YES;
                break;
            }
            if ([[cur substringToIndex:8] isEqual:@"charset="])
            {
                // doesn't match if there are arbitrary spaces, but
                // whatever dude
                if (charset)
                {
                    continue;
                }
                // garbage
                charset = substr(cur, 8); // not used
            }
            else
            {
                if (content_type)
                {
                    continue;
                }// garbage
                
                content_type = cur;
            }
        }
    }
    else
    {
        data = result[0];
    }
    if (content_type && ![allowed_types containsObject:content_type])
    {
        return NO;
    }
    if (charset)
    {
        // error; we don't allow plaintext stuff
        charset = nil;
    }
    data = [data stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSData* raw_data = nil;
    if (is_base64)
    {
        raw_data = base64_decode(data);
    }
    else
    {
        raw_data = [data dataUsingEncoding:NSUTF8StringEncoding];
    }
    
    NSImage* image = [[NSImage alloc] initWithData:raw_data];

    // XXX probably want to refactor this into a general mechanism
    // for filtering arbitrary content types
    // NSString* file = tempnam(@"/tmp", @"");
/* TODODOTO
 
    
    file_put_contents($file, $raw_data);
    if (function_exists('exif_imagetype')) {
        $image_code = exif_imagetype($file);
        unlink($file);
    } elseif (function_exists('getimagesize')) {
        set_error_handler(array($this, 'muteErrorHandler'));
        $info = getimagesize($file);
        restore_error_handler();
        unlink($file);
        if ($info == false) {
            return false;
        }
        $image_code = $info[2];
    } else {
        trigger_error("could not find exif_imagetype or getimagesize functions", E_USER_ERROR);
    }
    $real_content_type = image_type_to_mime_type($image_code);
    if ($real_content_type != $content_type) {
        // we're nice guys; if the content type is something else we
        // support, change it over
        if (empty($this->allowed_types[$real_content_type])) {
            return false;
        }
        $content_type = $real_content_type;
    }
*/
    if (!image)
        return NO;

    if(!image.isValid)
        return NO;
    
    struct CGImageSource* imgsrc = CGImageSourceCreateWithData((__bridge CFDataRef)(raw_data),(__bridge CFDictionaryRef)(@{}));
    
    // Returns something like public.png
    NSString* real_type = CFBridgingRelease(CGImageSourceGetType(imgsrc));
    CFRelease(imgsrc);
    
    if (!real_type)
        return NO;
    
    if (strpos(real_type, @".") == NSNotFound)
        return NO;
    
    
    NSString* type = [explode(@".",real_type) objectAtIndex:1];

    real_type = [@"image/" stringByAppendingString:type];
    
    
    if (![real_type isEqual:content_type])
    {
        if ([allowed_types containsObject:real_type]){
            content_type = real_type;
            
        }
        else
            return NO;
    }
    
    //CHECK IMAGE TYPE: REAL VS GIVEN || ALLOWED ?
    
    // ok, it's kosher, rewrite what we need
    [uri setUserinfo:nil];
    [uri setHost:nil];
    [uri setPort:nil];
    [uri setFragment:nil];
    [uri setQuery:nil];
    [uri setPath:[NSString stringWithFormat:@"%@;base64,%@",content_type,[raw_data base64EncodedStringWithOptions:0]]];
    return YES;
}


@end
