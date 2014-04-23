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
