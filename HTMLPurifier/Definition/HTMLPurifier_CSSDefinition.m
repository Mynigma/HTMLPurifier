//
//   HTMLPurifier_CSSDefinition.m
//   HTMLPurifier
//
//  Created by Roman Priebe on 10.01.14.


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
#import "HTMLPurifier_AttrDef_CSS_ImportantDecorator.h"
#import "HTMLPurifier_AttrDef_CSS_Shape.h"
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
    /**
     * Completing this CSS-Definition with latest CSS3 standard compliant properties
     * Last updated: 12.08.2015
     * Source: http://www.w3.org/TR/CSS/
     **/
    
    // background-attachment
    HTMLPurifier_AttrDef_Enum* scroll_fixed = [[HTMLPurifier_AttrDef_Enum alloc] initWithValidValues:@[@"scroll",@"fixed"] caseSensitive:NO];
    [self.info setObject:scroll_fixed forKey:@"background-attachment"];
    
    // background-color
    HTMLPurifier_AttrDef_CSS_Color* color = [HTMLPurifier_AttrDef_CSS_Color new];
    HTMLPurifier_AttrDef_Enum* transparent = [[HTMLPurifier_AttrDef_Enum alloc] initWithValidValues:@[@"transparent"]];
    HTMLPurifier_AttrDef_CSS_Composite* color_or_transparent = [[HTMLPurifier_AttrDef_CSS_Composite alloc] initWithDefs:@[transparent, color]];
    [self.info setObject:color_or_transparent forKey:@"background-color"];
    
    // background-image
    HTMLPurifier_AttrDef_CSS_URI* uri = [HTMLPurifier_AttrDef_CSS_URI new];
    HTMLPurifier_AttrDef_Enum* none = [[HTMLPurifier_AttrDef_Enum alloc] initWithValidValues:@[@"none"] caseSensitive:NO];
    HTMLPurifier_AttrDef_CSS_Composite* uri_or_none = [[HTMLPurifier_AttrDef_CSS_Composite alloc] initWithDefs:@[none, uri]];
    [self.info setObject:uri_or_none forKey:@"background-image"];

    // background-position
    [self.info setObject:[HTMLPurifier_AttrDef_CSS_BackgroundPosition new] forKey:@"background-position"];

    // background-repeat
    [self.info setObject:[[HTMLPurifier_AttrDef_Enum alloc] initWithValidValues:@[@"repeat", @"repeat-x", @"repeat-y", @"no-repeat"]] forKey:@"background-repeat"];

    // background
    [self.info setObject:[[HTMLPurifier_AttrDef_CSS_Background alloc] initWithConfig:config] forKey:@"background"];
    
    // border-collapse
    [self.info setObject:[[HTMLPurifier_AttrDef_Enum alloc] initWithValidValues:@[@"collapse", @"separate"]] forKey:@"border-collapse"];
    
    // border-color
    [self.info setObject:[[HTMLPurifier_AttrDef_CSS_Multiple alloc] initWithSingle:color_or_transparent] forKey:@"border-color"];
    
    // border-spacing
    [self.info setObject:[[HTMLPurifier_AttrDef_CSS_Multiple alloc] initWithSingle:[HTMLPurifier_AttrDef_CSS_Length new] max:2] forKey:@"border-spacing"];

    // border-style
    HTMLPurifier_AttrDef_Enum* border_style = [[HTMLPurifier_AttrDef_Enum alloc] initWithValidValues:@[@"none", @"hidden", @"dotted", @"dashed", @"solid", @"double", @"groove", @"ridge", @"inset", @"outset"] caseSensitive:NO];
    [self.info setObject:[[HTMLPurifier_AttrDef_CSS_Multiple alloc] initWithSingle:border_style] forKey:@"border-style"];

    // border-top-color border-right-color border-bottom-color border-left-color
    [self.info setObject:color_or_transparent forKey:@"border-top-color"];
    [self.info setObject:color_or_transparent forKey:@"border-bottom-color"];
    [self.info setObject:color_or_transparent forKey:@"border-left-color"];
    [self.info setObject:color_or_transparent forKey:@"border-right-color"];
    
    // border-top-style border-right-style border-bottom-style border-left-style
    [self.info setObject:border_style forKey:@"border-bottom-style"];
    [self.info setObject:border_style forKey:@"border-right-style"];
    [self.info setObject:border_style forKey:@"border-left-style"];
    [self.info setObject:border_style forKey:@"border-top-style"];
    
    // border-top-width border-right-width border-bottom-width border-left-width
    HTMLPurifier_AttrDef_CSS_Composite* border_width = [[HTMLPurifier_AttrDef_CSS_Composite alloc] initWithDefs:@[[[HTMLPurifier_AttrDef_Enum alloc] initWithValidValues:@[@"thin", @"medium", @"thick"]], [[HTMLPurifier_AttrDef_CSS_Length alloc] initWithMin:@"0"]]];
    [self.info setObject:border_width forKey:@"border-top-width"];
    [self.info setObject:border_width forKey:@"border-bottom-width"];
    [self.info setObject:border_width forKey:@"border-left-width"];
    [self.info setObject:border_width forKey:@"border-right-width"];

    // border-width
    [self.info setObject:[[HTMLPurifier_AttrDef_CSS_Multiple alloc] initWithSingle:border_width] forKey:@"border-width"];
    
    // border-top border-right border-bottom border-left
    HTMLPurifier_AttrDef_CSS_Border* border = [[HTMLPurifier_AttrDef_CSS_Border alloc] initWithConfig:config];
    [self.info setObject:border forKey:@"border-bottom"];
    [self.info setObject:border forKey:@"border-top"];
    [self.info setObject:border forKey:@"border-left"];
    [self.info setObject:border forKey:@"border-right"];
    
    // border
    [self.info setObject:border forKey:@"border"];

    // bottom
    HTMLPurifier_AttrDef_Enum* _auto = [[HTMLPurifier_AttrDef_Enum alloc] initWithValidValues:@[@"auto"]];
    HTMLPurifier_AttrDef_CSS_Composite* length_percentage_auto = [[HTMLPurifier_AttrDef_CSS_Composite alloc] initWithDefs:@[[[HTMLPurifier_AttrDef_CSS_Length alloc] initWithMin:@"0"],[HTMLPurifier_AttrDef_CSS_Percentage new],_auto]];
    [self.info setObject:length_percentage_auto forKey:@"bottom"];

    // caption-side
    [self.info setObject:[[HTMLPurifier_AttrDef_Enum alloc] initWithValidValues:@[@"top", @"bottom"]] forKey:@"caption-side"];

    // clear
    [self.info setObject:[[HTMLPurifier_AttrDef_Enum alloc] initWithValidValues:@[@"none", @"left", @"right", @"both"] caseSensitive:NO] forKey:@"clear"];

    // clip
    HTMLPurifier_AttrDef_CSS_Shape* shape = [HTMLPurifier_AttrDef_CSS_Shape new];
    [self.info setObject:[[HTMLPurifier_AttrDef_CSS_Composite alloc] initWithDefs:@[shape,_auto]] forKey:@"clip"];
    
    // color
    [self.info setObject:[HTMLPurifier_AttrDef_CSS_Color new] forKey:@"color"];

    // content (left out due to: only applies to :before and :after pseudo-elements)

    // counter-increment
    //[ <identifier> <integer>? ]+ | none
    
    // counter-reset
    //[ <identifier> <integer>? ]+ | none
    
    // curser
    NSArray* cursers = @[@"auto",@"crosshair",@"default",@"pointer",@"move",@"e-resize",@"ne-resize",@"nw-resize",@"n-resize",@"se-resize",@"sw-resize",@"s-resize",@"w-resize",@"text",@"wait",@"help",@"progress"];
    [self.info setObject:[[HTMLPurifier_AttrDef_CSS_Composite alloc] initWithDefs:@[uri,[[HTMLPurifier_AttrDef_Enum alloc] initWithValidValues:cursers]]] forKey:@"cursor"];

    // direction
    [self.info setObject:[[HTMLPurifier_AttrDef_Enum alloc] initWithValidValues:@[@"ltr",@"rtl"]] forKey:@"direction"];

    // display
    NSArray* display = @[@"inline",@"block",@"list-item",@"run-in",@"compact",@"marker",@"table",@"inline-block",@"inline-table",@"table-row-group",@"table-header-group",@"table-footer-group",@"table-row",@"table-column-group",@"table-column",@"table-cell",@"table-caption",@"none"];
    [self.info setObject:[[HTMLPurifier_AttrDef_Enum alloc] initWithValidValues:display] forKey:@"display"];
    
    // empty-cells
    [self.info setObject:[[HTMLPurifier_AttrDef_Enum alloc] initWithValidValues:@[@"show",@"hide"]] forKey:@"empty-cells"];

    // float
    [self.info setObject:[[HTMLPurifier_AttrDef_Enum alloc] initWithValidValues:@[@"none", @"left", @"right"] caseSensitive:NO] forKey:@"float"];

    // font-family
    [self.info setObject:[HTMLPurifier_AttrDef_CSS_FontFamily new] forKey:@"font-family"];

    // font-size
    [self.info setObject:[[HTMLPurifier_AttrDef_CSS_Composite alloc] initWithDefs:@[[[HTMLPurifier_AttrDef_Enum alloc] initWithValidValues:@[@"xx-small", @"x-small", @"small", @"medium", @"large", @"x-large", @"xx-large", @"larger", @"smaller"]], [HTMLPurifier_AttrDef_CSS_Percentage new], [HTMLPurifier_AttrDef_CSS_Length new]]] forKey:@"font-size"];
    
    // font-style
    [self.info setObject:[[HTMLPurifier_AttrDef_Enum alloc] initWithValidValues:@[@"normal", @"italic", @"oblique"] caseSensitive:NO] forKey:@"font-style"];

    // font-variant
    [self.info setObject:[[HTMLPurifier_AttrDef_Enum alloc] initWithValidValues:@[@"normal", @"small-caps"] caseSensitive:NO] forKey:@"font-variant"];

    // font-weight
    [self.info setObject:[[HTMLPurifier_AttrDef_Enum alloc] initWithValidValues:@[@"normal", @"bold", @"bolder", @"lighter", @"100", @"200", @"300", @"400", @"500", @"600", @"700", @"800", @"900"] caseSensitive:NO] forKey:@"font-weight"];
    
    // line-height
    // is needed for multivalue element "font"
    [self.info setObject:[[HTMLPurifier_AttrDef_CSS_Composite alloc] initWithDefs:@[[[HTMLPurifier_AttrDef_Enum alloc] initWithValidValues:@[@"normal"]], [[HTMLPurifier_AttrDef_CSS_Number alloc] initWithNonNegative:YES], [[HTMLPurifier_AttrDef_CSS_Length alloc] initWithMin:@"0"], [[HTMLPurifier_AttrDef_CSS_Percentage alloc] initWithNonNegative:YES]]] forKey:@"line-height"];
    
    // font
    [self.info setObject:[[HTMLPurifier_AttrDef_CSS_Font alloc] initWithConfig:config] forKey:@"font"];

    // max img width from config
    HTMLPurifier_AttrDef_CSS_Composite* trusted_wh = [[HTMLPurifier_AttrDef_CSS_Composite alloc] initWithDefs:@[[[HTMLPurifier_AttrDef_CSS_Length alloc] initWithMin:@"0"], [[HTMLPurifier_AttrDef_CSS_Percentage alloc] initWithNonNegative:YES], [[HTMLPurifier_AttrDef_Enum alloc] initWithValidValues:@[@"auto"]]]];
    NSNumber* max = (NSNumber*)[config get:@"CSS.MaxImgLength"];
    HTMLPurifier_AttrDef_CSS_Composite* composite = [[HTMLPurifier_AttrDef_CSS_Composite alloc] initWithDefs:@[[[HTMLPurifier_AttrDef_CSS_Length alloc] initWithMin:@"0" max:max], [[HTMLPurifier_AttrDef_CSS_Percentage alloc] initWithNonNegative:YES], [[HTMLPurifier_AttrDef_Enum alloc] initWithValidValues:@[@"auto"]]]];
    HTMLPurifier_AttrDef* maxLength = (max==nil) ? trusted_wh:[[HTMLPurifier_AttrDef_Switch alloc] initWithTag:@"img" withTag:composite withoutTag:trusted_wh];
    
    // height
    [self.info setObject:maxLength forKey:@"height"];

    // left
    [self.info setObject:maxLength forKey:@"left"];
    
    // letter-spacing
    [self.info setObject:[[HTMLPurifier_AttrDef_CSS_Composite alloc] initWithDefs:@[[[HTMLPurifier_AttrDef_Enum alloc] initWithValidValues:@[@"normal"]], [HTMLPurifier_AttrDef_CSS_Length new]]] forKey:@"letter-spacing"];
    
    // line-height
    // see "font"
    
    // list-style-image
    [self.info setObject:uri_or_none forKey:@"list-style-image"];

    // list-style-position
    [self.info setObject:[[HTMLPurifier_AttrDef_Enum alloc] initWithValidValues:@[@"inside", @"outside"] caseSensitive:NO] forKey:@"list-style-position"];

    // list-style-type
    [self.info setObject:[[HTMLPurifier_AttrDef_Enum alloc] initWithValidValues:@[@"disc", @"circle", @"square", @"decimal", @"decimal-leading-zero", @"lower-roman", @"upper-roman", @"lower-greek", @"lower-latin", @"upper-latin", @"armenian", @"georgian", @"lower-alpha", @"upper-alpha", @"none"] caseSensitive:NO] forKey:@"list-style-type"];

    // list-style
    [self.info setObject:[[HTMLPurifier_AttrDef_CSS_ListStyle alloc] initWithConfig:config] forKey:@"list-style"];

    // margin-right margin-left margin-top margin-bottom
    HTMLPurifier_AttrDef_CSS_Composite* margin = [[HTMLPurifier_AttrDef_CSS_Composite alloc] initWithDefs:@[[HTMLPurifier_AttrDef_CSS_Length new], [HTMLPurifier_AttrDef_CSS_Percentage new], [[HTMLPurifier_AttrDef_Enum alloc] initWithValidValues:@[@"auto"]]]];
    [self.info setObject:margin forKey:@"margin-top"];
    [self.info setObject:margin forKey:@"margin-bottom"];
    [self.info setObject:margin forKey:@"margin-left"];
    [self.info setObject:margin forKey:@"margin-right"];
    
    // margin
    [self.info setObject:[[HTMLPurifier_AttrDef_CSS_Multiple alloc] initWithSingle:margin] forKey:@"margin"];

    
    [self.info setObject:[[HTMLPurifier_AttrDef_Enum alloc] initWithValidValues:@[@"left", @"right", @"center", @"justify"] caseSensitive:NO] forKey:@"text-align"];

    [self.info setObject:[[HTMLPurifier_AttrDef_Enum alloc] initWithValidValues:@[@"capitalize", @"uppercase", @"lowercase", @"none"] caseSensitive:NO] forKey:@"text-transform"];



    
    [self.info setObject:[[HTMLPurifier_AttrDef_CSS_Length alloc] initWithMin:0] forKey:@"border-radius"];



    [self.info setObject:[[HTMLPurifier_AttrDef_CSS_Composite alloc] initWithDefs:@[[[HTMLPurifier_AttrDef_Enum alloc] initWithValidValues:@[@"normal"]], [HTMLPurifier_AttrDef_CSS_Length new]]] forKey:@"word-spacing"];

    HTMLPurifier_AttrDef_CSS_Composite* padding = [[HTMLPurifier_AttrDef_CSS_Composite alloc] initWithDefs:@[[[HTMLPurifier_AttrDef_CSS_Length alloc] initWithMin:@"0"], [[HTMLPurifier_AttrDef_CSS_Percentage alloc] initWithNonNegative:YES]]];

    [self.info setObject:padding forKey:@"padding-top"];
    [self.info setObject:padding forKey:@"padding-bottom"];
    [self.info setObject:padding forKey:@"padding-left"];
    [self.info setObject:padding forKey:@"padding-right"];

    [self.info setObject:[[HTMLPurifier_AttrDef_CSS_Multiple alloc] initWithSingle:padding] forKey:@"padding"];

    [self.info setObject:[[HTMLPurifier_AttrDef_CSS_Composite alloc] initWithDefs:@[[[HTMLPurifier_AttrDef_CSS_Length alloc] init], [[HTMLPurifier_AttrDef_CSS_Percentage alloc] init]]] forKey:@"text-indent"];


    

    [self.info setObject:maxLength forKey:@"width"];
    [self.info setObject:maxLength forKey:@"max-width"];

    [self.info setObject:[[HTMLPurifier_AttrDef_CSS_TextDecoration alloc] init] forKey:@"text-decoration"];



    [self.info setObject:[[HTMLPurifier_AttrDef_Enum alloc] initWithValidValues:@[@"auto", @"fixed"]] forKey:@"table-layout"];


    [self.info setObject:[[HTMLPurifier_AttrDef_CSS_Composite alloc] initWithDefs:@[[[HTMLPurifier_AttrDef_Enum alloc] initWithValidValues:@[@"baseline", @"sub", @"super", @"top", @"text-top", @"middle", @"bottom", @"text-bottom"]], [HTMLPurifier_AttrDef_CSS_Length new], [HTMLPurifier_AttrDef_CSS_Percentage new]]] forKey:@"vertical-align"];
    
    
    
    NSArray* array = @[@"visible",@"hidden",@"collapse"];
    HTMLPurifier_AttrDef_Enum* newEnum = [[HTMLPurifier_AttrDef_Enum alloc] initWithValidValues:array];
    [self.info setObject:newEnum forKey:@"visibility"];
    
    array = @[@"visible",@"hidden",@"auto",@"scroll"];
    newEnum = [[HTMLPurifier_AttrDef_Enum alloc] initWithValidValues:array];
    [self.info setObject:newEnum forKey:@"overflow"];


    // These CSS properties don't work on many browsers, but we live
    // in THE FUTURE!
    [self.info setObject:[[HTMLPurifier_AttrDef_Enum alloc] initWithValidValues:@[@"nowrap", @"normal", @"pre", @"pre-wrap", @"pre-line"]] forKey:@"white-space"];
    
    
    /*
     if ([[config get:@"CSS.Proprietary"] boolValue])
     {
     [self doSetupProprietary:config];
     }


     if ([config get:@"CSS.Trusted"])
     {
     [self doSetupTrusted:config];
     }*/

    BOOL allow_important = [[config get:@"CSS.AllowImportant"] isEqual:@YES];


    // wrap all attr-defs with decorator that handles !important
    NSArray* allKeys = self.info.allKeys;
    for(NSString* k in allKeys)
    {
        HTMLPurifier_AttrDef* v = self.info[k];
        self.info[k] = [[HTMLPurifier_AttrDef_CSS_ImportantDecorator alloc] initWithDef:v AllowImportant:@(allow_important)];
    }


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
    if ([allowed_properties isKindOfClass:[NSDictionary class]])
    {
        NSArray* allTheKeys = self.info.allKeys;
        for(NSString* name in allTheKeys)
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
    if ([forbidden_properties isKindOfClass:[NSDictionary class]])
    {
        NSArray* allTheKeys = forbidden_properties.allKeys;
        for(NSString* name in allTheKeys)
        {
            [self.info removeObjectForKey:name];
        }
    }
}


@end
