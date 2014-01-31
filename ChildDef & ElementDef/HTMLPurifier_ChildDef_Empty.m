//
//  HTMLPurifier_ChildDef_Empty.m
//  HTMLPurifier
//
//  Created by Roman Priebe on 19.01.14.


#import "HTMLPurifier_ChildDef_Empty.h"
#import "HTMLPurifier_Config.h"
#import "HTMLPurifier_Context.h"

@implementation HTMLPurifier_ChildDef_Empty


- (id)init
{
    self = [super init];
    if (self) {
        self.allow_empty = YES;
        self.typeString = @"empty";
    }
    return self;
}


- (NSArray*)validateChildren:(NSArray*)children config:(HTMLPurifier_Config *)config context:(HTMLPurifier_Context *)context
{
    return @[];
}


@end
