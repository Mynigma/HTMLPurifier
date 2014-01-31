//
//  HTMLPurifier_AttrDef_CSS_Composite.m
//  HTMLPurifier
//
//  Created by Roman Priebe on 10.01.14.


#import "HTMLPurifier_AttrDef_CSS_Composite.h"

@implementation HTMLPurifier_AttrDef_CSS_Composite

- (id)initWithDefs:(NSArray*)newDefs
{
    self = [super init];
    if (self) {
        _defs = [newDefs mutableCopy];
    }
    return self;
}
    /**
     * @param string $string
     * @param HTMLPurifier_Config $config
     * @param HTMLPurifier_Context $context
     * @return bool|string
     */
- (NSString*)validateWithString:(NSString *)string config:(HTMLPurifier_Config *)config context:(HTMLPurifier_Context *)context
{
    for(HTMLPurifier_AttrDef* def in self.defs)
    {
        NSString* result = [def validateWithString:string config:config context:context];
        if(result)
            return result;
    }
        return nil;
}

@end
