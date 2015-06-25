//
//   HTMLPurifier_AttrTransform_Length.m
//   HTMLPurifier
//
//  Created by Lukas Neumann on 23.01.14.


#import "HTMLPurifier_AttrTransform_Length.h"
#import "BasicPHP.h"

/**
 * Class for handling width/height length attribute transformations to CSS
 */
@implementation HTMLPurifier_AttrTransform_Length

@synthesize cssName;

@synthesize name;

-(id) initWithName:(NSString*)nname css:(NSString*)css_name // = null)
{
    self = [super init];
    name = nname;
    cssName = css_name ? css_name : name;
    return self;
}

-(id) initWithName:(NSString*)nname
{
    return [self initWithName:nname css:nil];
}

/**
 * @param array $attr
 * @param HTMLPurifier_Config $config
 * @param HTMLPurifier_Context $context
 * @return array
 */
- (NSDictionary*)transform:(NSDictionary*)attr sortedKeys:(NSMutableArray*)sortedKeys config:(HTMLPurifier_Config*)config context:(HTMLPurifier_Context*)context
{
    if (!attr[name])
    {
        return attr;
    }
    
    NSMutableDictionary* attr_m = [attr mutableCopy];
    
    NSObject* length = [self confiscateAttr:attr_m sortedKeys:sortedKeys key:name];
    if (ctype_digit((NSString*)length))
    {
        length = [NSString stringWithFormat:@"%@px",length];
    }
    
    [self prependCSS:attr_m sortedKeys:sortedKeys css:[NSString stringWithFormat:@"%@:%@;",cssName,length]];
    
    return attr_m;
}

@end
