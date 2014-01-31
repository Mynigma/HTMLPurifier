//
//   HTMLPurifier_URIScheme_data.m
//   HTMLPurifier
//
//  Created by Lukas Neumann on 19.01.14.




#import "HTMLPurifier_URIScheme_data.h"
#import "HTMLPurifier_URI.h"
#import "BasicPHP.h"

/**
 * Implements data: URI for base64 encoded images supported by GD.
 */
@implementation HTMLPurifier_URIScheme_data

-(id) init
{
    self = [super init];
    super.browsable = @YES;
    
    // this is actually irrelevant since we only write out the path
    // component
    super.may_omit_host = @YES;
    
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
            if (cur.length >= 8 && [[cur substringToIndex:8] isEqual:@"charset="])
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

    if (!image)
        return NO;
    
    // Is image drawable?
    if(!image.isValid)
        return NO;
    
    
    uint8_t firstByte;
    [raw_data getBytes:&firstByte length:1];

    //get the real content_type
    switch (firstByte) {
            case 0xFF:
                 content_type = @"image/jpeg";
                break;
            case 0x89:
                content_type = @"image/png";
                break;
            case 0x47:
                content_type = @"image/gif";
                break;
            case 0x49:
            case 0x4D:
                content_type = @"image/tiff";
                break;
            default:  // The Image is drawable but an unsual type, we'll use the image but set the type to png. Because we can.
                content_type = @"image/png";
                break;
    }

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
