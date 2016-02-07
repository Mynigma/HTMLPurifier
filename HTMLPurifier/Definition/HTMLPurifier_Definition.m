//
//   HTMLPurifier_Definition.m
//   HTMLPurifier
//
//  Created by Roman Priebe on 12.01.14.


#import "HTMLPurifier_Definition.h"
#import "HTMLPurifier_Config.h"

@implementation HTMLPurifier_Definition


- (id)init
{
    self = [super init];
    if (self) {
        _setup = NO;
        _optimized = NO;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        _setup = [[coder decodeObjectForKey:@"setup"] boolValue];
        _optimized = [[coder decodeObjectForKey:@"optimized"] boolValue];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:@(_setup) forKey:@"setup"];
    [coder encodeObject:@(_optimized) forKey:@"optimized"];
}



- (BOOL)isEqual:(id)other
{
    if (other == self) {
        return YES;
    } else if(![other isKindOfClass:[HTMLPurifier_Definition class]])
    {
        return NO;
    }
    else
    {
        return (self.setup == [(HTMLPurifier_Definition*)other setup]) && (self.optimized == [(HTMLPurifier_Definition*)other optimized]);
    }
}

- (NSUInteger)hash
{
    return self.setup?0:1 + self.optimized?0:2;
}





    /**
     * Sets up the definition object into the final form, something
     * not done by the constructor
     * @param HTMLPurifier_Config $config
     */
- (void)doSetup:(HTMLPurifier_Config*)config
{

}

    /**
     * Setup function that aborts if already setup
     * @param HTMLPurifier_Config $config
     */
    - (void)setup:(HTMLPurifier_Config*)config;
    {
        if (_setup) {
            return;
        }
        _setup = YES;
        [self doSetup:config];
    }




@end
