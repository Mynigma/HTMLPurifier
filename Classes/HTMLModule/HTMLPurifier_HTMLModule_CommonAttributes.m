//
//   HTMLPurifier_HTMLModule_CommonAttributes.m
//   HTMLPurifier
//
//  Created by Roman Priebe on 18.01.14.


#import "HTMLPurifier_HTMLModule_CommonAttributes.h"

@implementation HTMLPurifier_HTMLModule_CommonAttributes


- (id)initWithConfig:(HTMLPurifier_Config*)config
{
    self = [super initWithConfig:config];
    if (self) {
        self.name = @"CommonAttributes";
        self.attr_collections = [@{@"Core" : @{@0 : @"Style", @"class":@"Class", @"id":@"ID", @"title":@"CDATA"}, @"Lang":@{}, @"I18N":@{@0 : @"Lang"}, @"Common" : @{ @0 : @[@"Core", @"I18N"]}} mutableCopy];
        }
    return self;
}


@end
