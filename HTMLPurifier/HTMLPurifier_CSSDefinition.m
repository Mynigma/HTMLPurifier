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
#import "HTMLPurifier_AttrDef_CSS_Multiple.h"
#import "HTMLPurifier_AttrDef_CSS_Composite.h"
#import "HTMLPurifier_AttrDef_CSS_BackgroundPosition.h"
#import "HTMLPurifier_AttrDef_CSS_Border.h"
#import "HTMLPurifier_AttrDef_CSS_Percentage.h"
#import "HTMLPurifier_AttrDef_CSS_URI.h"


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



    [self.info setObject:[[HTMLPurifier_AttrDef_CSS_Multiple alloc] initWithSingle:borderStyle] forKey:@"border-style"];

    [self.info setObject:[[HTMLPurifier_AttrDef_Enum alloc] initWithValidValues:@[@"none", @"left", @"right", @"both"] caseSensitive:NO] forKey:@"clear"];

    [self.info setObject:[[HTMLPurifier_AttrDef_Enum alloc] initWithValidValues:@[@"none", @"left", @"right"] caseSensitive:NO] forKey:@"float"];

    [self.info setObject:[[HTMLPurifier_AttrDef_Enum alloc] initWithValidValues:@[@"normal", @"italic", @"oblique"] caseSensitive:NO] forKey:@"font-style"];

    [self.info setObject:[[HTMLPurifier_AttrDef_Enum alloc] initWithValidValues:@[@"normal", @"small-caps"] caseSensitive:NO] forKey:@"font-variant"];


    HTMLPurifier_AttrDef_CSS_Composite* uri_or_none = [[HTMLPurifier_AttrDef_CSS_Composite alloc] initWithArray:@[[[HTMLPurifier_AttrDef_Enum alloc] initWithValidValues:@[@"none"]], [[HTMLPurifier_AttrDef_CSS_URI alloc] init]]];

    [self.info setObject:[[HTMLPurifier_AttrDef_Enum alloc] initWithValidValues:@[@"inside", @"outside"] caseSensitive:NO] forKey:@"list-style-position"];

    [self.info setObject:[[HTMLPurifier_AttrDef_Enum alloc] initWithValidValues:@[@"disc", @"circle", @"square", @"decimal", @"lower-roman", @"upper-roman", @"lower-alpha", @"upper-alpha", @"none"] caseSensitive:NO] forKey:@"list-style-type"];

    [self.info setObject:uri_or_none forKey:@"list-style-image"];

    [self.info setObject:[[HTMLPurifier_AttrDef_CSS_ListStyle alloc] initWithSingle:config] forKey:@"list-style"];

    [self.info setObject:[[HTMLPurifier_AttrDef_Enum alloc] initWithValidValues:@[@"capitalize", @"uppercase", @"lowercase", @"none"] caseSensitive:NO] forKey:@"text-transform"];

    [self.info setObject:[[HTMLPurifier_AttrDef_CSS_Color alloc] init] forKey:@"color"];

    [self.info setObject:uri_or_none forKey:@"background-image"];

    [self.info setObject:[[HTMLPurifier_AttrDef_Enum alloc] initWithValidValues:@[@"repeat", @"repeat-x", @"repeat-y", @"no-repeat"]] forKey:@"background-repeat"];

    [self.info setObject:[[HTMLPurifier_AttrDef_Enum alloc] initWithValidValues:@[@"scroll", @"fixed"]] forKey:@"background-attachment"];

    [self.info setObject:[[HTMLPurifier_AttrDef_CSS_BackgroundPosition alloc] init] forKey:@"background-position"];

    HTMLPurifier_AttrDef_CSS_Composite* border_color = [[HTMLPurifier_AttrDef_Composite alloc] initWithSingle:@[[[HTMLPurifier_AttrDef_Enum alloc] initWithValidValues:@[@"transparent"]], [[HTMLPurifier_AttrDef_CSS_Color alloc] init]]];

    [self.info setObject:border_color forKey:@"border-top-color"];
    [self.info setObject:border_color forKey:@"border-bottom-color"];
    [self.info setObject:border_color forKey:@"border-left-color"];
    [self.info setObject:border_color forKey:@"border-right-color"];
    [self.info setObject:border_color forKey:@"background-color"];


    [self.info setObject:[[HTMLPurifier_AttrDef_CSS_Background alloc] initWithSingle:config] forKey:@"background"];

    [self.info setObject:[[HTMLPurifier_AttrDef_CSS_Multiple alloc] initWithSingle:@[border-color forKey:@"border-color"]]];

    HTMLPurifier_AttrDef_CSS_Composite* border_width = [[HTMLPurifier_AttrDef_CSS_Composite alloc] initWithSingle:@[[[HTMLPurifier_AttrDef_Enum alloc] initWithValidValues:@[@"thin", @"medium", @"thick"]], [[HTMLPurifier_AttrDef_CSS_Length alloc] initWithString:@"0"]]];

    [self.info setObject:border_width forKey:@"border-top-width"];
    [self.info setObject:border_width forKey:@"border-bottom-width"];
    [self.info setObject:border_width forKey:@"border-left-width"];
    [self.info setObject:border_width forKey:@"border-right-width"];

    [self.info setObject:[[HTMLPurifier_AttrDef_CSS_Multiple alloc] initWithSingle:border_width] forKey:@"border-width"];

    [self.info setObject:[[HTMLPurifier_AttrDef_CSS_Composite alloc] initWithSingle:@[[[HTMLPurifierAttrDef_Enum alloc] initWithSingle:@[@"normal"]]]]];

    [self.info setObject:[[HTMLPurifier_AttrDef_CSS_Composite alloc] initWithSingle:@[[[HTMLPurifier_AttrDef_Enum alloc] initWithValidValues:@[@"normal"]], [[HTMLPurifier_AttrDef_CSS_Length] alloc] init]] forKey:@"letter-spacing"];

    [self.info setObject:[[HTMLPurifier_AttrDef_CSS_Composite alloc] initWithSingle:@[@"normal"]] forKey:@"word-spacing"];

    [self.info setObject:[[HTMLPurifier_AttrDef_CSS_Composite alloc] initWithSingle:@[[[HTMLPurifier_AttrDef_Enum alloc] initWithValidValues:@"xx-small", @"x-small", @"small", @"medium", @"large", @"x-large", @"xx-large", @"larger", @"smaller"], [[HTMLPurifier_AttrDef_CSS_Percentage alloc] init], [[HTMLPurifier_AttrDef_CSS_Length alloc] init] ] forKey:@"font-size"];

     [self.info setObject:[[HTMLPurifier_AttrDef_CSS_Composite alloc] initWIthSingle:@[[[HTMLPurifier_AttrDef_Enum alloc] initWithValidValues:@[@"normal"], [[HTMLPurifier_AttrDef_Number alloc] initWith:YES], [[HTMLPurifier_AttrDef_Length alloc] initWith:@"0"], [[HTMLPurifier_AttrDef_CSS_Percentage alloc] init:]]]] forKey:@"line-height"];

     HTMLPurifier_AttrDef_CSS_Composite* margin = [[HTMLPurifier_AttrDef_CSS_Composite alloc] initWith:@[[[HTMLPurifier_AttrDef_CSS_Length alloc] init], [[HTMLPurifier_AttrDef_CSS_Length alloc] init], [[HTMLPurifier_AttrDef_CSS_Length alloc] initWith:@[@"auto"]]]];

     [self.info setObject:margin forKey:@"margin-top"];
     [self.info setObject:margin forKey:@"margin-bottom"];
     [self.info setObject:margin forKey:@"margin-left"];
     [self.info setObject:margin forKey:@"margin-right"];

     [self.info setObject:[[HTMLPurifier_AttrDef_CSS_Multiple alloc] initWithSingle:margin] forKey:@"margin"];

     HTMLPurifier_AttrDef_CSS_Composite* padding = [[HTMLPurifier_AttrDef_CSS_Composite alloc] initWith:@[[[HTMLPurifier_AttrDef_CSS_Length alloc] initWith:@"0"], [[HTMLPurifier_AttrDef_CSS_Percentage alloc] initWith:YES]]];

     [self.info setObject:padding forKey:@"padding-top"];
     [self.info setObject:padding forKey:@"padding-bottom"];
     [self.info setObject:padding forKey:@"padding-left"];
     [self.info setObject:padding forKey:@"padding-right"];

     [self.info setObject:[[HTMLPurifier_AttrDef_CSS_Multiple alloc] initWithSingle:padding] forKey:@"padding"];

     [self.info setObject:[[HTMLPurifier_AttrDef_CSS_Composite alloc] initWith:@[[[HTMLPurifier_AttrDef_CSS_Length alloc] init], [[HTMLPurifier_AttrDef_CSS_Percentage alloc] init]]] forKey:@"text-indent"];

     HTMLPurifier_AttrDef_CSS_Composite* trusted_wh = [[HTMLPurifier_AttrDef_CSS_Composite alloc] initWith:@[[[HTMLPurifier_AttrDef_CSS_Length alloc] initWith:@"0"], [[HTMLPurifier_AttrDef_CSS_Percentage alloc] initWith:YES], [[HTMLPurifier_AttrDef_Enum alloc] initWith:@[@"auto"]]]];

     [self.info setObject: forKey:];

     NSNumber* max = [config get:@"CSS.MaxImgLength"];

    $max = $config->get('CSS.MaxImgLength');

     HTMLPurifier_AttrDef* attrDef = (max==nil)?trusted_wh:[[HTMLPurifier_AttrDef_Switch alloc] init:@"img", [[HTMLPurifier_AttrDef_CSS_Composite alloc] initW:@[[[HTMLPurifier_AttrDef_CSS_Length alloc] initW:@"0" max], [[HTML]]]]

     [self.info setObject:]

    $this->info['width'] =
    $this->info['height'] =
    $max === null ?
    $trusted_wh :
    new HTMLPurifier_AttrDef_Switch(
                                    'img',
                                    // For img tags:
                                    new HTMLPurifier_AttrDef_CSS_Composite(
                                                                           array(
                                                                                 new HTMLPurifier_AttrDef_CSS_Length('0', $max),
                                                                                 new HTMLPurifier_AttrDef_Enum(array('auto'))
                                                                                 )
                                                                           ),
                                    // For everyone else:
                                    $trusted_wh
                                    );
    
    $this->info['text-decoration'] = new HTMLPurifier_AttrDef_CSS_TextDecoration();
    
    $this->info['font-family'] = new HTMLPurifier_AttrDef_CSS_FontFamily();
    
    // this could use specialized code
    $this->info['font-weight'] = new HTMLPurifier_AttrDef_Enum(
                                                               array(
                                                                     'normal',
                                                                     'bold',
                                                                     'bolder',
                                                                     'lighter',
                                                                     '100',
                                                                     '200',
                                                                     '300',
                                                                     '400',
                                                                     '500',
                                                                     '600',
                                                                     '700',
                                                                     '800',
                                                                     '900'
                                                                     ),
                                                               false
                                                               );
    
    // MUST be called after other font properties, as it references
    // a CSSDefinition object
    $this->info['font'] = new HTMLPurifier_AttrDef_CSS_Font($config);
    
    // same here
    $this->info['border'] =
    $this->info['border-bottom'] =
    $this->info['border-top'] =
    $this->info['border-left'] =
    $this->info['border-right'] = new HTMLPurifier_AttrDef_CSS_Border($config);
    
    $this->info['border-collapse'] = new HTMLPurifier_AttrDef_Enum(
                                                                   array('collapse', 'separate')
                                                                   );
    
    $this->info['caption-side'] = new HTMLPurifier_AttrDef_Enum(
                                                                array('top', 'bottom')
                                                                );
    
    $this->info['table-layout'] = new HTMLPurifier_AttrDef_Enum(
                                                                array('auto', 'fixed')
                                                                );
    
    $this->info['vertical-align'] = new HTMLPurifier_AttrDef_CSS_Composite(
                                                                           array(
                                                                                 new HTMLPurifier_AttrDef_Enum(
                                                                                                               array(
                                                                                                                     'baseline',
                                                                                                                     'sub',
                                                                                                                     'super',
                                                                                                                     'top',
                                                                                                                     'text-top',
                                                                                                                     'middle',
                                                                                                                     'bottom',
                                                                                                                     'text-bottom'
                                                                                                                     )
                                                                                                               ),
                                                                                 new HTMLPurifier_AttrDef_CSS_Length(),
                                                                                 new HTMLPurifier_AttrDef_CSS_Percentage()
                                                                                 )
                                                                           );

}

@end
