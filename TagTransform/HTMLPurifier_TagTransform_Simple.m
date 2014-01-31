//
//  HTMLPurifier_TagTransform_Simple.m
//  HTMLPurifier
//
//  Created by Roman Priebe on 18.01.14.


#import "HTMLPurifier_TagTransform_Simple.h"
#import "HTMLPurifier_Config.h"
#import "HTMLPurifier_Context.h"
#import "HTMLPurifier_Token_Tag.h"
#import "HTMLPurifier_Token_Start.h"
#import "HTMLPurifier_Token_Empty.h"

@implementation HTMLPurifier_TagTransform_Simple



- (id)initWithTransformTo:(NSString*)newTo style:(NSString*)newStyle
{
    self = [super init];
    if (self) {
        self.transform_to = newTo;
        style = newStyle;
    }
    return self;
}

    /**
     * @param HTMLPurifier_Token_Tag $tag
     * @param HTMLPurifier_Config $config
     * @param HTMLPurifier_Context $context
     * @return string
     */
- (HTMLPurifier_Token_Tag*)transform:(HTMLPurifier_Token_Tag*)tag config:(HTMLPurifier_Config*)config context:(HTMLPurifier_Context *)context
    {
        HTMLPurifier_Token_Tag* newTag = [tag copy];
        newTag.name = self.transform_to;
        if (style &&
            ([newTag isKindOfClass:[HTMLPurifier_Token_Start class]] || [newTag isKindOfClass:[HTMLPurifier_Token_Empty class]])
            ) {
            [self prependCSS:newTag.attr css:style];
        }
        return newTag;
    }



@end
