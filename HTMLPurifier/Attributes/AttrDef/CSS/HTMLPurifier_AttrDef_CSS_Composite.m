//
//   HTMLPurifier_AttrDef_CSS_Composite.m
//   HTMLPurifier
//
//  Created by Roman Priebe on 10.01.14.


#import "HTMLPurifier_AttrDef_CSS_Composite.h"

@implementation HTMLPurifier_AttrDef_CSS_Composite

- (id)initWithDefs:(NSArray*)newDefs
{
    self = [super init];
    if (self) {
        _defs = newDefs;
    }
    return self;
}


- (instancetype)initWithCoder:(NSCoder*)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        _defs = [coder decodeObjectForKey:@"defs"];
    }
    return self;
}



- (void)encodeWithCoder:(NSCoder*)encoder
{
    [super encodeWithCoder:encoder];
    [encoder encodeObject:_defs forKey:@"defs"];
}


- (BOOL)isEqual:(id)other
{
    if (other == self) {
        return YES;
    } else if (![super isEqual:other]) {
        return NO;
    } else if(![other isKindOfClass:[HTMLPurifier_AttrDef_CSS_Composite class]])
    {
        return NO;
    }
    else
    {
        return (!self.defs && ![(HTMLPurifier_AttrDef_CSS_Composite*)other defs]) || [self.defs isEqual:[(HTMLPurifier_AttrDef_CSS_Composite*)other defs]];
    }
}

- (NSUInteger)hash
{
    return [_defs hash] ^ [super hash];
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
