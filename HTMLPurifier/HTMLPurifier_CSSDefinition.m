//
//  HTMLPurifier_CSSDefinition.m
//  HTMLPurifier
//
//  Created by Roman Priebe on 10.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_CSSDefinition.h"
#import "HTMLPurifier_Config.h"

@implementation HTMLPurifier_CSSDefinition

- (id)init
{
    self = [super init];
    if (self) {
        _type = @"CSS";
    }
    return self;
}

- (void)doSetupWithConfig:(HTMLPurifier_Config*)config
{
    [self.info setObject:[[HTMLPurifier_AttrDef_Enum alloc] initWithValidValues:@[@"left", @"right", @"center", @"justify"] caseSensitive:NO] ];

    HTMLPurifier_AttrDef_Enum* borderStyle = [HTMLPurifier_AttrDef_Enum]


  @[@"none", @"hidden", @"dotted", @"dashed", @"solid", @"double", @"groove", @"ridge", @"inset", @"outset"] forKey:@"border-top-style"]];
}

@end
