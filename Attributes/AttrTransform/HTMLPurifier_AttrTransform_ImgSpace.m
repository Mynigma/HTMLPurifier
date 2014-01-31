//
//  HTMLPurifier_AttrTransform_ImgSpace.m
//  HTMLPurifier
//
//  Created by Lukas Neumann on 23.01.14.


#import "HTMLPurifier_AttrTransform_ImgSpace.h"

/**
 * Pre-transform that changes deprecated hspace and vspace attributes to CSS
 */
@implementation HTMLPurifier_AttrTransform_ImgSpace

/**
 * @type string
 */
@synthesize attr_s;

/**
 * @type array
 */
@synthesize css; // = array('hspace' => array('left', 'right'), 'vspace' => array('top', 'bottom') );


/**
 * @param string $attr
 */
-(id) initWithAttr:(NSString*) attr
{
    self = [super init];
    css = @{@"hspace" : @[@"left",@"right"],@"vspace" : @[@"top", @"bottom"]};
    attr_s = attr;
    if (!css[attr_s])
    {
        NSLog(@"%@ is not valid space attribute",attr_s);
    }
    
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
    if (!attr[attr_s]) {
        return attr;
    }
    
    NSMutableDictionary* attr_m = [attr mutableCopy];
    
    NSObject* width = [self confiscateAttr:attr_m sortedKeys:sortedKeys key:attr_s];
    // some validation could happen here
    
    if (!css[attr_s])
    {
        return attr_m;
    }
    
    NSString* style = @"";
    for (NSString* suffix in css[attr_s])
    {
        NSString* property = [@"margin-" stringByAppendingString:suffix];
        style = [NSString stringWithFormat:@"%@%@:{%@}px;",style,property,width];
    }
    [self prependCSS:attr_m sortedKeys:sortedKeys css:style];
    return attr_m;
}

@end
