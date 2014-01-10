//
//  HTMLPurifier_CSSDefinition.m
//  HTMLPurifier
//
//  Created by Roman Priebe on 10.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_CSSDefinition.h"
#import "HTMLPurifier_Config.h"
#import "HTMLPurifier_AttrDef_Enum.h"


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
    [self.info setObject:[[HTMLPurifier_AttrDef_Enum alloc] initWithValidValues:@[@"left", @"right", @"center", @"justify"] caseSensitive:NO] forKey:@"text-align"];

    HTMLPurifier_AttrDef_Enum* borderStyle = [[HTMLPurifier_AttrDef_Enum alloc] initWithValidValues:@[@"none", @"hidden", @"dotted", @"dashed", @"solid", @"double", @"groove", @"ridge", @"inset", @"outset"] caseSensitive:NO];

    [self.info setObject:borderStyle forKey:@"border-bottom-style"];
    [self.info setObject:borderStyle forKey:@"border-right-style"];
    [self.info setObject:borderStyle forKey:@"border-left-style"];
    [self.info setObject:borderStyle forKey:@"border-top-style"];



    $this->info['border-style'] = new HTMLPurifier_AttrDef_CSS_Multiple($border_style);

    $this->info['clear'] = new HTMLPurifier_AttrDef_Enum(
                                                         array('none', 'left', 'right', 'both'),
                                                         false
                                                         );
    $this->info['float'] = new HTMLPurifier_AttrDef_Enum(
                                                         array('none', 'left', 'right'),
                                                         false
                                                         );
    $this->info['font-style'] = new HTMLPurifier_AttrDef_Enum(
                                                              array('normal', 'italic', 'oblique'),
                                                              false
                                                              );
    $this->info['font-variant'] = new HTMLPurifier_AttrDef_Enum(
                                                                array('normal', 'small-caps'),
                                                                false
                                                                );

    
}

@end
