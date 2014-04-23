//
//   HTMLPurifier_AttrTransform_SafeParam.m
//   HTMLPurifier
//
//  Created by Lukas Neumann on 23.01.14.


#import "HTMLPurifier_AttrTransform_SafeParam.h"
#import "HTMLPurifier_AttrDef_URI.h"
#import "HTMLPurifier_AttrDef_Enum.h"
#import "HTMLPurifier_Config.h"

/**
 * Validates name/value pairs in param tags to be used in safe objects. This
 * will only allow name values it recognizes, and pre-fill certain attributes
 * with required values.
 *
 * @note
 *      This class only supports Flash. In the future, Quicktime support
 *      may be added.
 *
 * @warning
 *      This class expects an injector to add the necessary parameters tags.
 */
@implementation HTMLPurifier_AttrTransform_SafeParam

/**
 * @type string
 */
@synthesize name; //"SafeParam";

/**
 * @type HTMLPurifier_AttrDef_URI
 */
@synthesize uri;

@synthesize wmode;

-(id) init
{
    self = [super init];
    name = @"SafeParam";
    uri = [[HTMLPurifier_AttrDef_URI alloc] initWithNumber:@YES]; // embedded
    wmode = [[HTMLPurifier_AttrDef_Enum alloc]
             initWithValidValues:@[@"window", @"opaque", @"transparent"]];
    return self;
}

/**
 * @param array $attr
 * @param HTMLPurifier_Config $config
 * @param HTMLPurifier_Context $context
 * @return array
 */
- (NSDictionary*)transform:(NSDictionary*)attr sortedKeys:(NSMutableArray*)sortedKeys config:(HTMLPurifier_Config*)config context:(HTMLPurifier_Context*)context
{
    // If we add support for other objects, we'll need to alter the
    // transforms.
    NSDictionary* switch_vals = @{@"allowScriptAccess" : @0, @"allowNetworking":@1, @"allowFullScreen":@2, @"wmode":@3, @"movie":@4 , @"src":@5,@"flashvars":@6};
    
    NSMutableDictionary* attr_m = [attr mutableCopy];
    if (attr_m[@"name"])
    {
        NSNumber* s = [switch_vals objectForKey:attr_m[@"name"]];
        if (!s)
        {
            //default case of original "string"-switch
            [attr_m removeObjectForKey:@"name"];
            [attr_m removeObjectForKey:@"value"];
            [sortedKeys removeObject:@"name"];
            [sortedKeys removeObject:@"value"];
        }
        else
        {
            NSString* val;
            switch (s.intValue) {
                    // application/x-shockwave-flash
                    // Keep this synchronized with Injector/SafeObject.php
                case 0:
                    [attr_m setObject:@"never" forKey:@"value"];
                    break;
                case 1:
                    [attr_m setObject:@"internal" forKey:@"value"];
                    break;
                case 2:
                    if ([config get:@"HTML.FlashAllowFullScreen"])
                    {
                        // nil pointer problem?
                        [attr_m setObject:(([attr_m[@"value"] isEqual:@"true"]) ? @"true" : @"false") forKey:@"value"];
                    }
                    else
                    {
                        [attr_m setObject:@"false" forKey:@"value"];
                    }
                    break;
                case 3:
                    val = [wmode validateWithString:attr_m[@"value"] config:config context:context];
                    if (val)
                        [attr_m setObject:val forKey:@"value"];
                    break;
                case 4:
                case 5:
                    val = [uri validateWithString:attr_m[@"value"] config:config context:context];
                    [attr_m setObject:@"movie" forKey:@"name"];
                    if (val)
                        [attr_m setObject:val forKey:@"value"];
                    break;
                case 6:
                    // we're going to allow arbitrary inputs to the SWF, on
                    // the reasoning that it could only hack the SWF, not us.
                    break;
                    // add other cases to support other param name/value pairs
                default:
                    // can't be here
                    break;
            }
            // checks if added or changed "value" attribut
            if (![sortedKeys containsObject:@"value"])
                [sortedKeys addObject:@"value"];
        }
    }
    // no name attr? remove value aswell
    [attr_m removeObjectForKey:@"value"];
    [sortedKeys removeObject:@"value"];
    
    return attr_m;
}

@end
