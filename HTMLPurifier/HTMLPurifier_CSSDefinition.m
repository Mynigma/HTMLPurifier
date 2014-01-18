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
#import "HTMLPurifier_AttrDef_CSS_Background.h"
#import "HTMLPurifier_AttrDef_CSS_BackgroundPosition.h"
#import "HTMLPurifier_AttrDef_CSS_Border.h"
#import "HTMLPurifier_AttrDef_CSS_Percentage.h"
#import "HTMLPurifier_AttrDef_CSS_URI.h"
#import "HTMLPurifier_AttrDef_CSS_ListStyle.h"
#import "HTMLPurifier_AttrDef_CSS_Color.h"
#import "HTMLPurifier_AttrDef_CSS_Number.h"
#import "HTMLPurifier_AttrDef_CSS_Length.h"
#import "HTMLPurifier_AttrDef_Switch.h"
#import "HTMLPurifier_AttrDef_CSS_TextDecoration.h"
#import "HTMLPurifier_AttrDef_CSS_URI.h"
#import "HTMLPurifier_AttrDef_CSS_FontFamily.h"
#import "HTMLPurifier_AttrDef_CSS_Font.h"
#import "BasicPHP.h"


@implementation HTMLPurifier_CSSDefinition

- (id)init
{
    self = [super init];
    if (self) {
        _typeString = @"CSS";
        _info = [NSMutableDictionary new];
    }
    return self;
}

- (void)doSetup:(HTMLPurifier_Config*)config
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


    HTMLPurifier_AttrDef_CSS_Composite* uri_or_none = [[HTMLPurifier_AttrDef_CSS_Composite alloc] initWithDefs:@[[[HTMLPurifier_AttrDef_Enum alloc] initWithValidValues:@[@"none"]], [[HTMLPurifier_AttrDef_CSS_URI alloc] init]]];

    [self.info setObject:[[HTMLPurifier_AttrDef_Enum alloc] initWithValidValues:@[@"inside", @"outside"] caseSensitive:NO] forKey:@"list-style-position"];

    [self.info setObject:[[HTMLPurifier_AttrDef_Enum alloc] initWithValidValues:@[@"disc", @"circle", @"square", @"decimal", @"lower-roman", @"upper-roman", @"lower-alpha", @"upper-alpha", @"none"] caseSensitive:NO] forKey:@"list-style-type"];

    [self.info setObject:uri_or_none forKey:@"list-style-image"];

    [self.info setObject:[[HTMLPurifier_AttrDef_CSS_ListStyle alloc] initWithConfig:config] forKey:@"list-style"];

    [self.info setObject:[[HTMLPurifier_AttrDef_Enum alloc] initWithValidValues:@[@"capitalize", @"uppercase", @"lowercase", @"none"] caseSensitive:NO] forKey:@"text-transform"];

    [self.info setObject:[[HTMLPurifier_AttrDef_CSS_Color alloc] init] forKey:@"color"];

    [self.info setObject:uri_or_none forKey:@"background-image"];

    [self.info setObject:[[HTMLPurifier_AttrDef_Enum alloc] initWithValidValues:@[@"repeat", @"repeat-x", @"repeat-y", @"no-repeat"]] forKey:@"background-repeat"];

    [self.info setObject:[[HTMLPurifier_AttrDef_Enum alloc] initWithValidValues:@[@"scroll", @"fixed"]] forKey:@"background-attachment"];

    [self.info setObject:[[HTMLPurifier_AttrDef_CSS_BackgroundPosition alloc] init] forKey:@"background-position"];

    HTMLPurifier_AttrDef_CSS_Composite* border_color = [[HTMLPurifier_AttrDef_CSS_Composite alloc] initWithDefs:@[[[HTMLPurifier_AttrDef_Enum alloc] initWithValidValues:@[@"transparent"]], [[HTMLPurifier_AttrDef_CSS_Color alloc] init]]];

    [self.info setObject:border_color forKey:@"border-top-color"];
    [self.info setObject:border_color forKey:@"border-bottom-color"];
    [self.info setObject:border_color forKey:@"border-left-color"];
    [self.info setObject:border_color forKey:@"border-right-color"];
    [self.info setObject:border_color forKey:@"background-color"];


    [self.info setObject:[[HTMLPurifier_AttrDef_CSS_Background alloc] initWithConfig:config] forKey:@"background"];

    [self.info setObject:[[HTMLPurifier_AttrDef_CSS_Multiple alloc] initWithSingle:border_color] forKey:@"border-color"];

    HTMLPurifier_AttrDef_CSS_Composite* border_width = [[HTMLPurifier_AttrDef_CSS_Composite alloc] initWithDefs:@[[[HTMLPurifier_AttrDef_Enum alloc] initWithValidValues:@[@"thin", @"medium", @"thick"]], [[HTMLPurifier_AttrDef_CSS_Length alloc] initWithMin:@"0"]]];

    [self.info setObject:border_width forKey:@"border-top-width"];
    [self.info setObject:border_width forKey:@"border-bottom-width"];
    [self.info setObject:border_width forKey:@"border-left-width"];
    [self.info setObject:border_width forKey:@"border-right-width"];

    [self.info setObject:[[HTMLPurifier_AttrDef_CSS_Multiple alloc] initWithSingle:border_width] forKey:@"border-width"];

    [self.info setObject:[[HTMLPurifier_AttrDef_CSS_Composite alloc] initWithDefs:@[[[HTMLPurifier_AttrDef_Enum alloc] initWithValidValues:@[@"normal"]], [[HTMLPurifier_AttrDef_CSS_Length alloc] init]]] forKey:@"letter-spacing"];

    [self.info setObject:[[HTMLPurifier_AttrDef_CSS_Composite alloc] initWithDefs:@[@"normal"]] forKey:@"word-spacing"];

    [self.info setObject:[[HTMLPurifier_AttrDef_CSS_Composite alloc] initWithDefs:@[[[HTMLPurifier_AttrDef_Enum alloc] initWithValidValues:@[@"xx-small", @"x-small", @"small", @"medium", @"large", @"x-large", @"xx-large", @"larger", @"smaller"]], [[HTMLPurifier_AttrDef_CSS_Percentage alloc] init], [[HTMLPurifier_AttrDef_CSS_Length alloc] init]]] forKey:@"font-size"];

     self.info[@"line-height"] = [[HTMLPurifier_AttrDef_CSS_Composite alloc] initWithDefs:@[[[HTMLPurifier_AttrDef_Enum alloc] initWithValidValues:@[@"normal"]], [[HTMLPurifier_AttrDef_CSS_Number alloc] initWithNonNegative:YES], [[HTMLPurifier_AttrDef_CSS_Length alloc] initWithMin:@"0"], [[HTMLPurifier_AttrDef_CSS_Percentage alloc] initWithNonNegative:YES]]];

     HTMLPurifier_AttrDef_CSS_Composite* margin = [[HTMLPurifier_AttrDef_CSS_Composite alloc] initWithDefs:@[[[HTMLPurifier_AttrDef_CSS_Length alloc] init], [[HTMLPurifier_AttrDef_CSS_Length alloc] init], [[HTMLPurifier_AttrDef_Enum alloc] initWithValidValues:@[@"auto"]]]];

     [self.info setObject:margin forKey:@"margin-top"];
     [self.info setObject:margin forKey:@"margin-bottom"];
     [self.info setObject:margin forKey:@"margin-left"];
     [self.info setObject:margin forKey:@"margin-right"];

     [self.info setObject:[[HTMLPurifier_AttrDef_CSS_Multiple alloc] initWithSingle:margin] forKey:@"margin"];

     HTMLPurifier_AttrDef_CSS_Composite* padding = [[HTMLPurifier_AttrDef_CSS_Composite alloc] initWithDefs:@[[[HTMLPurifier_AttrDef_CSS_Length alloc] initWithMin:@"0"], [[HTMLPurifier_AttrDef_CSS_Percentage alloc] initWithNonNegative:YES]]];

     [self.info setObject:padding forKey:@"padding-top"];
     [self.info setObject:padding forKey:@"padding-bottom"];
     [self.info setObject:padding forKey:@"padding-left"];
     [self.info setObject:padding forKey:@"padding-right"];

     [self.info setObject:[[HTMLPurifier_AttrDef_CSS_Multiple alloc] initWithSingle:padding] forKey:@"padding"];

     [self.info setObject:[[HTMLPurifier_AttrDef_CSS_Composite alloc] initWithDefs:@[[[HTMLPurifier_AttrDef_CSS_Length alloc] init], [[HTMLPurifier_AttrDef_CSS_Percentage alloc] init]]] forKey:@"text-indent"];

     HTMLPurifier_AttrDef_CSS_Composite* trusted_wh = [[HTMLPurifier_AttrDef_CSS_Composite alloc] initWithDefs:@[[[HTMLPurifier_AttrDef_CSS_Length alloc] initWithMin:@"0"], [[HTMLPurifier_AttrDef_CSS_Percentage alloc] initWithNonNegative:YES], [[HTMLPurifier_AttrDef_Enum alloc] initWithValidValues:@[@"auto"]]]];

    NSNumber* max = (NSNumber*)[config get:@"CSS.MaxImgLength"];

     HTMLPurifier_AttrDef_CSS_Composite* composite = [[HTMLPurifier_AttrDef_CSS_Composite alloc] initWithDefs:@[[[HTMLPurifier_AttrDef_CSS_Length alloc] initWithMin:@"0"], [[HTMLPurifier_AttrDef_Enum alloc] initWithValidValues:@[@"auto"]]]];

    HTMLPurifier_AttrDef* attrDef = (max==nil) ? trusted_wh:[[HTMLPurifier_AttrDef_Switch alloc] initWithTag:@"img" withTag:composite withoutTag:trusted_wh];

    [self.info setObject:attrDef forKey:@"width"];
    [self.info setObject:attrDef forKey:@"height"];

     [self.info setObject:[[HTMLPurifier_AttrDef_CSS_TextDecoration alloc] init] forKey:@"text-decoration"];

    [self.info setObject:[[HTMLPurifier_AttrDef_CSS_FontFamily alloc] init] forKey:@"font-family"];

    [self.info setObject:[[HTMLPurifier_AttrDef_Enum alloc] initWithValidValues:@[@"normal", @"bold", @"bolder", @"lighter", @"100", @"200", @"300", @"400", @"500", @"600", @"700", @"800", @"900"] caseSensitive:NO] forKey:@"font-weight"];

    [self.info setObject:[[HTMLPurifier_AttrDef_CSS_Font alloc] initWithConfig:config] forKey:@"font"];

    HTMLPurifier_AttrDef_CSS_Border* border = [[HTMLPurifier_AttrDef_CSS_Border alloc] initWithConfig:config];

    [self.info setObject:border forKey:@"border"];
    [self.info setObject:border forKey:@"border-bottom"];
    [self.info setObject:border forKey:@"border-top"];
    [self.info setObject:border forKey:@"border-left"];
    [self.info setObject:border forKey:@"border-right"];

    [self.info setObject:[[HTMLPurifier_AttrDef_Enum alloc] initWithValidValues:@[@"collapse", @"separate"]] forKey:@"border-collapse"];


    [self.info setObject:[[HTMLPurifier_AttrDef_Enum alloc] initWithValidValues:@[@"top", @"bottom"]] forKey:@"caption-side"];

    [self.info setObject:[[HTMLPurifier_AttrDef_Enum alloc] initWithValidValues:@[@"auto", @"fixed"]] forKey:@"table-layout"];


    [self.info setObject:[[HTMLPurifier_AttrDef_CSS_Composite alloc] initWithDefs:@[[[HTMLPurifier_AttrDef_Enum alloc] initWithValidValues:@[@"baseline", @"sub", @"super", @"top", @"text-top", @"middle", @"bottom", @"text-bottom"]], [HTMLPurifier_AttrDef_CSS_Length new], [HTMLPurifier_AttrDef_CSS_Percentage new]]] forKey:@"vertical-align"];


    [self.info setObject:[[HTMLPurifier_AttrDef_CSS_Multiple alloc] initWithSingle:[HTMLPurifier_AttrDef_CSS_Length new] max:2] forKey:@"border-spacing"];

                                                             // These CSS properties don't work on many browsers, but we live
                                                            // in THE FUTURE!
    [self.info setObject:[[HTMLPurifier_AttrDef_Enum alloc] initWithValidValues:@[@"nowrap", @"normal", @"pre", @"pre-wrap", @"pre-line"]] forKey:@"white-space"];

    /*
    if ([[config get:@"CSS.Proprietary"] boolValue])
    {
        [self doSetupProprietary:config];
    }

    if ([[config get:@"CSS.AllowTricky"] boolValue])
    {
        [self doSetupTricky:config];
    }


    if ([config get:@"CSS.Trusted"])
    {
        [self doSetupTrusted:config];
    }

    $allow_important = $config->get('CSS.AllowImportant');
                                                            // wrap all attr-defs with decorator that handles !important
                                                            foreach ($this->info as $k => $v) {
                                                                $this->info[$k] = new HTMLPurifier_AttrDef_CSS_ImportantDecorator($v, $allow_important);
                                                            }*/

    [self setupConfigStuff:config];
}

//                                                            /**
//                                                             * @param HTMLPurifier_Config $config
//                                                             */
//                                                            protected function doSetupProprietary($config)
//                                                            {
//                                                                // Internet Explorer only scrollbar colors
//                                                                $this->info['scrollbar-arrow-color'] = new HTMLPurifier_AttrDef_CSS_Color();
//                                                                $this->info['scrollbar-base-color'] = new HTMLPurifier_AttrDef_CSS_Color();
//                                                                $this->info['scrollbar-darkshadow-color'] = new HTMLPurifier_AttrDef_CSS_Color();
//                                                                $this->info['scrollbar-face-color'] = new HTMLPurifier_AttrDef_CSS_Color();
//                                                                $this->info['scrollbar-highlight-color'] = new HTMLPurifier_AttrDef_CSS_Color();
//                                                                $this->info['scrollbar-shadow-color'] = new HTMLPurifier_AttrDef_CSS_Color();
//
//                                                                // technically not proprietary, but CSS3, and no one supports it
//                                                                $this->info['opacity'] = new HTMLPurifier_AttrDef_CSS_AlphaValue();
//                                                                $this->info['-moz-opacity'] = new HTMLPurifier_AttrDef_CSS_AlphaValue();
//                                                                $this->info['-khtml-opacity'] = new HTMLPurifier_AttrDef_CSS_AlphaValue();
//
//                                                                // only opacity, for now
//                                                                $this->info['filter'] = new HTMLPurifier_AttrDef_CSS_Filter();
//
//                                                                // more CSS3
//                                                                $this->info['page-break-after'] =
//                                                                $this->info['page-break-before'] = new HTMLPurifier_AttrDef_Enum(
//                                                                                                                                 array(
//                                                                                                                                       'auto',
//                                                                                                                                       'always',
//                                                                                                                                       'avoid',
//                                                                                                                                       'left',
//                                                                                                                                       'right'
//                                                                                                                                       )
//                                                                                                                                 );
//                                                                $this->info['page-break-inside'] = new HTMLPurifier_AttrDef_Enum(array('auto', 'avoid'));
//                                                                
//                                                            }
//                                                            
//                                                            /**
//                                                             * @param HTMLPurifier_Config $config
//                                                             */
//                                                            protected function doSetupTricky($config)
//                                                            {
//                                                                $this->info['display'] = new HTMLPurifier_AttrDef_Enum(
//                                                                                                                       array(
//                                                                                                                             'inline',
//                                                                                                                             'block',
//                                                                                                                             'list-item',
//                                                                                                                             'run-in',
//                                                                                                                             'compact',
//                                                                                                                             'marker',
//                                                                                                                             'table',
//                                                                                                                             'inline-block',
//                                                                                                                             'inline-table',
//                                                                                                                             'table-row-group',
//                                                                                                                             'table-header-group',
//                                                                                                                             'table-footer-group',
//                                                                                                                             'table-row',
//                                                                                                                             'table-column-group',
//                                                                                                                             'table-column',
//                                                                                                                             'table-cell',
//                                                                                                                             'table-caption',
//                                                                                                                             'none'
//                                                                                                                             )
//                                                                                                                       );
//                                                                $this->info['visibility'] = new HTMLPurifier_AttrDef_Enum(
//                                                                                                                          array('visible', 'hidden', 'collapse')
//                                                                                                                          );
//                                                                $this->info['overflow'] = new HTMLPurifier_AttrDef_Enum(array('visible', 'hidden', 'auto', 'scroll'));
//                                                            }
//                                                            
//                                                            /**
//                                                             * @param HTMLPurifier_Config $config
//                                                             */
//                                                            protected function doSetupTrusted($config)
//                                                            {
//                                                                $this->info['position'] = new HTMLPurifier_AttrDef_Enum(
//                                                                                                                        array('static', 'relative', 'absolute', 'fixed')
//                                                                                                                        );
//                                                                $this->info['top'] =
//                                                                $this->info['left'] =
//                                                                $this->info['right'] =
//                                                                $this->info['bottom'] = new HTMLPurifier_AttrDef_CSS_Composite(
//                                                                                                                               array(
//                                                                                                                                     new HTMLPurifier_AttrDef_CSS_Length(),
//                                                                                                                                     new HTMLPurifier_AttrDef_CSS_Percentage(),
//                                                                                                                                     new HTMLPurifier_AttrDef_Enum(array('auto')),
//                                                                                                                                     )
//                                                                                                                               );
//                                                                $this->info['z-index'] = new HTMLPurifier_AttrDef_CSS_Composite(
//                                                                                                                                array(
//                                                                                                                                      new HTMLPurifier_AttrDef_Integer(),
//                                                                                                                                      new HTMLPurifier_AttrDef_Enum(array('auto')),
//                                                                                                                                      )
//                                                                                                                                );

                                                            /**
                                                             * Performs extra config-based processing. Based off of
                                                             * HTMLPurifier_HTMLDefinition.
                                                             * @param HTMLPurifier_Config $config
                                                             * @todo Refactor duplicate elements into common class (probably using
                                                             *       composition, not inheritance).
                                                             */

- (void)setupConfigStuff:(HTMLPurifier_Config*)config
{
    // setup allowed elements
    NSString* support = @"(for information on implementing this, see the support forums) ";
    NSMutableDictionary* allowed_properties = [[config get:@"CSS.AllowedProperties"] mutableCopy];
    if (allowed_properties)
    {
        for(NSString* name in self.info.allKeys)
        {
            if(!allowed_properties[name])
            {
                [self.info removeObjectForKey:name];
            }
            [self.info removeObjectForKey:name];
        }

    for(NSString* name in allowed_properties)
    {
        NSString* newName = htmlspecialchars(name);
        TRIGGER_ERROR(@"Style attribute '%@' is not supported %@", newName, support);
    }

    }

    NSMutableDictionary* forbidden_properties = [[config get:@"CSS.ForbiddenProperties"] mutableCopy];
    if (forbidden_properties)
    {
        for(NSString* name in self.info)
        {
            [self.info removeObjectForKey:name];
        }
    }
}


@end
