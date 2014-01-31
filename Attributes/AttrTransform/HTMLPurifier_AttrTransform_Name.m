//
//   HTMLPurifier_AttrTransform_Name.m
//   HTMLPurifier
//
//  Created by Lukas Neumann on 23.01.14.


#import "HTMLPurifier_AttrTransform_Name.h"
#import "HTMLPurifier_config.h"

/**
 * Pre-transform that changes deprecated name attribute to ID if necessary
 */
@implementation HTMLPurifier_AttrTransform_Name

/**
 * @param array $attr
 * @param HTMLPurifier_Config $config
 * @param HTMLPurifier_Context $context
 * @return array
 */
- (NSDictionary*)transform:(NSDictionary*)attr sortedKeys:(NSMutableArray*)sortedKeys config:(HTMLPurifier_Config*)config context:(HTMLPurifier_Context*)context
{
    // Abort early if we're using relaxed definition of name
    if ([config get:@"HTML.Attr.Name.UseCDATA"])
    {
        return attr;
    }
    if (!attr[@"name"])
    {
        return attr;
    }
    
    NSMutableDictionary* attr_m = [attr mutableCopy];
    
    NSObject* id_c = [self confiscateAttr:attr_m sortedKeys:sortedKeys key:@"name"];
    if (attr_m[@"id"])
    {
        return attr_m;
    }
    if (id_c){
        [attr_m setObject:id_c forKey:@"id"];
        [sortedKeys addObject:@"id"];
    }
    return attr_m;
}

@end
