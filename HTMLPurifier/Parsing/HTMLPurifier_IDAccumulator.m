//
//   HTMLPurifier_IDAccumulator.m
//   HTMLPurifier
//
//  Created by Lukas Neumann on 10.01.14.


#import "HTMLPurifier_IDAccumulator.h"
#import "HTMLPurifier_Config.h"
#import "HTMLPurifier_Context.h"

@implementation HTMLPurifier_IDAccumulator


- (id)init
{
    self = [super init];
    if (self) {
        _ids = [NSMutableDictionary new];
    }
    return self;
}
    /**
     * Builds an IDAccumulator, also initializing the default blacklist
     * @param HTMLPurifier_Config $config Instance of HTMLPurifier_Config
     * @param HTMLPurifier_Context $context Instance of HTMLPurifier_Context
     * @return HTMLPurifier_IDAccumulator Fully initialized HTMLPurifier_IDAccumulator
     */
+ (HTMLPurifier_IDAccumulator*)buildWithConfig:(HTMLPurifier_Config*)config context:(HTMLPurifier_Context*)context
    {
        HTMLPurifier_IDAccumulator* id_accumulator = [[HTMLPurifier_IDAccumulator alloc] init];

        NSObject* idsObject = [config get:@"Attr.IDBlacklist"];

        if(![idsObject isKindOfClass:[NSArray class]])
            idsObject = nil;

        [id_accumulator loadWithIDs:(NSArray*)idsObject];
        return id_accumulator;
    }

    /**
     * Add an ID to the lookup table.
     * @param string $id ID to be added.
     * @return bool status, true if success, false if there's a dupe
     */
- (BOOL)addWithID:(id)newID
    {
        if (newID){
        if ([_ids objectForKey:newID]) {
            return NO;
        }
        [_ids setObject:@YES forKey:newID];
        return YES;
        }
        return NO;
    }

    /**
     * Load a list of IDs into the lookup table
     * @param $array_of_ids Array of IDs to load
     * @note This function doesn't care about duplicates
     */
- (void)loadWithIDs:(NSArray*)IDs
    {
        if(IDs)
        for(id newID in IDs)
            [_ids setObject:@YES forKey:newID];
    }

@end
