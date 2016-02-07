//
//   HTMLPurifier_HTMLModule_Legacy.m
//   HTMLPurifier
//
//  Created by Roman Priebe on 18.01.14.


#import "HTMLPurifier_HTMLModule_Legacy.h"
#import "HTMLPurifier_ElementDef.h"
#import "HTMLPurifier_AttrDef_Integer.h"

/**
 * XHTML 1.1 Legacy module defines elements that were previously
 * deprecated.
 *
 * @note Not all legacy elements have been implemented yet, which
 *       is a bit of a reverse problem as compared to browsers! In
 *       addition, this legacy module may implement a bit more than
 *       mandated by XHTML 1.1.
 *
 * This module can be used in combination with TransformToStrict in order
 * to transform as many deprecated elements as possible, but retain
 * questionably deprecated elements that do not have good alternatives
 * as well as transform elements that don't have an implementation.
 * See docs/ref-strictness.txt for more details.
 */
@implementation HTMLPurifier_HTMLModule_Legacy

- (id)initWithConfig:(HTMLPurifier_Config*)config
{
    self = [super initWithConfig:config];
    if (self) {
        self.name = @"Legacy";

        [self addElement:@"basefont" type:@"Inline" contents:@"Empty" attrIncludes:nil attr:@{@"color":@"Color", @"face":@"Text",@"size":@"Text",@"id":@"ID"}];

        [self addElement:@"center" type:@"Block" contents:@"Flow" attrIncludes:@"Common" attr:nil];

        [self addElement:@"dir" type:@"Block" contents:@"Required: li" attrIncludes:@"Common" attr:@{@"compact":@"Bool#compact"}];

        [self addElement:@"font" type:@"Inline" contents:@"Inline" attrIncludes:@[@"Core", @"I18N"] attr:@{@"color":@"Color",@"face":@"Text",@"size":@"Text"}];

        [self addElement:@"menu" type:@"Block" contents:@"Required: li" attrIncludes:@"Common" attr:@{@"compact":@"Bool#compact"}];

        HTMLPurifier_ElementDef* s = [self addElement:@"s" type:@"Inline" contents:@"Inline" attrIncludes:@"Common" attr:nil];
        s.formatting = @YES;

        HTMLPurifier_ElementDef* strike = [self addElement:@"strike" type:@"Inline" contents:@"Inline" attrIncludes:@"Common" attr:nil];
        strike.formatting = @YES;

        HTMLPurifier_ElementDef* u = [self addElement:@"u" type:@"Inline" contents:@"Inline" attrIncludes:@"Common" attr:nil];
        u.formatting = @YES;

        // setup modifications to old elements

        NSString* align = @"Enum#left,right,center,justify";

        HTMLPurifier_ElementDef* address = [self addBlankElement:@"address"];
        address.content_model = @"Inline | #PCDATA | p";
        address.content_model_type = @"optional";
        address.child = nil;

        HTMLPurifier_ElementDef* blockquote = [self addBlankElement:@"blockquote"];
        blockquote.content_model = @"Flow | #PCDATA";
        blockquote.content_model_type = @"optional";
        blockquote.child = nil;

        HTMLPurifier_ElementDef* br = [self addBlankElement:@"br"];
        br.attr[@"clear"] = @"Enum#left,all,right,none";

        HTMLPurifier_ElementDef* caption = [self addBlankElement:@"caption"];
        caption.attr[@"align"] = @"Enum#top,bottom,left,right";

        HTMLPurifier_ElementDef* div = [self addBlankElement:@"div"];
        div.attr[@"align"] = align;

        HTMLPurifier_ElementDef* dl = [self addBlankElement:@"dl"];
        dl.attr[@"compact"] = @"Bool#compact";

        for(NSInteger i=1; i<=6; i++)
        {
            HTMLPurifier_ElementDef* h = [self addBlankElement:[NSString stringWithFormat:@"h%ld", (long)i]];
            h.attr[@"align"] = align;
        }

        HTMLPurifier_ElementDef* hr = [self addBlankElement:@"hr"];
        hr.attr[@"align"] = align;
        hr.attr[@"noshade"] = @"Bool#noshade";
        hr.attr[@"size"] = @"Pixels";
        hr.attr[@"width"] = @"Length";

        HTMLPurifier_ElementDef* img = [self addBlankElement:@"img"];
        img.attr[@"align"] = @"IAlign";
        img.attr[@"border"] = @"Pixels";
        img.attr[@"hspace"] = @"Pixels";
        img.attr[@"vspace"] = @"Pixels";

        // figure out this integer business

        HTMLPurifier_ElementDef* li = [self addBlankElement:@"li"];
        li.attr[@"value"] = [HTMLPurifier_AttrDef_Integer new];
        li.attr[@"type"] = @"Enum#s:1,i,I,a,A,disc,square,circle";

        HTMLPurifier_ElementDef* ol = [self addBlankElement:@"ol"];
        ol.attr[@"compact"] = @"Bool#compact";
        ol.attr[@"start"] = [HTMLPurifier_AttrDef_Integer new];
        ol.attr[@"type"] = @"Enum#s:1,i,I,a,A";

        HTMLPurifier_ElementDef* p = [self addBlankElement:@"p"];
        p.attr[@"align"] = align;

        HTMLPurifier_ElementDef* pre = [self addBlankElement:@"pre"];
        pre.attr[@"width"] = @"Number";

        // script omitted

        HTMLPurifier_ElementDef* table = [self addBlankElement:@"table"];
        table.attr[@"align"] = @"Enum#left,center,right";
        table.attr[@"bgcolor"] = @"Color";

        HTMLPurifier_ElementDef* tr = [self addBlankElement:@"tr"];
        tr.attr[@"bgcolor"] = @"Color";

        HTMLPurifier_ElementDef* th = [self addBlankElement:@"th"];
        th.attr[@"bgcolor"] = @"Color";
        th.attr[@"height"] = @"Length";
        th.attr[@"nowrap"] = @"Bool#nowrap";
        th.attr[@"width"] = @"Length";

        HTMLPurifier_ElementDef* td = [self addBlankElement:@"td"];
        td.attr[@"bgcolor"] = @"Color";
        td.attr[@"height"] = @"Length";
        td.attr[@"nowrap"] = @"Bool#nowrap";
        td.attr[@"width"] = @"Length";

        HTMLPurifier_ElementDef* ul = [self addBlankElement:@"ul"];
        ul.attr[@"compact"] = @"Bool#compact";
        ul.attr[@"type"] = @"Enum#square,disc,circle";


        // "safe" modifications to "unsafe" elements
        // WARNING: If you want to add support for an unsafe, legacy
        // attribute, make a new TrustedLegacy module with the trusted
        // bit set appropriately

        HTMLPurifier_ElementDef* form = [self addBlankElement:@"form"];
        form.content_model = @"Flow | #PCDATA";
        form.content_model_type = @"optional";
        form.attr[@"target"] = @"FrameTarget";

        HTMLPurifier_ElementDef* input = [self addBlankElement:@"input"];
        input.attr[@"align"] = @"IAlign";

        HTMLPurifier_ElementDef* legend = [self addBlankElement:@"legend"];
        legend.attr[@"align"] = @"LAlign";
    }
    return self;
}



@end
