//
//   HTMLPurifier_URIFilter_DisableResources.m
//   HTMLPurifier
//
//  Created by Lukas Neumann on 19.01.14.


#import "HTMLPurifier_URIFilter_DisableResources.h"
#import "HTMLPurifier_Context.h"

@implementation HTMLPurifier_URIFilter_DisableResources

/**
 * @type string
 */
//public $name = 'DisableResources';

-(id) init
{
    self = [super init];
    self.name = @"DisableResources";
    return self;
}

/**
 * @param HTMLPurifier_URI $uri
 * @param HTMLPurifier_Config $config
 * @param HTMLPurifier_Context $context
 * @return bool
 */
- (BOOL) filter:(HTMLPurifier_URI**)uri config:(HTMLPurifier_Config*)config context:(HTMLPurifier_Context*)context
{
    return ![context getWithName:@"EmbeddedURI" ignoreError:YES];
}

@end
