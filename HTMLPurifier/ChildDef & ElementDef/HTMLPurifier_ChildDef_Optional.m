//
//   HTMLPurifier_ChidDef_Optional.m
//   HTMLPurifier
//
//  Created by Roman Priebe on 18.01.14.


#import "HTMLPurifier_ChildDef_Optional.h"

@implementation HTMLPurifier_ChildDef_Optional


- (id)init
{
    return [self initWithElements:nil];
}

- (id)initWithElements:(NSObject*)newElements
{
    self = [super initWithElements:newElements];
    if (self) {
        self.allow_empty = @YES;
        self.typeString = @"optional";
    }
    return self;
}


    /**
     * @param array $children
     * @param HTMLPurifier_Config $config
     * @param HTMLPurifier_Context $context
     * @return array
     */
- (NSObject*)validateChildren:(NSArray*)children config:(HTMLPurifier_Config *)config context:(HTMLPurifier_Context *)context
    {
        NSObject* result = [super validateChildren:children config:config context:context];

        // we assume that $children is not modified
        if (!result || [result isEqual:@"NO"])
        {
            if (children.count==0)
            {
                return @YES;
            }
            else if(self.whitespace.boolValue)
            {
                return children;
            } else {
                return @[];
            }
        }
        return result;
    }




@end
