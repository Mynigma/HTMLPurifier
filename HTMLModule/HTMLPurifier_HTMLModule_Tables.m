//
//  HTMLPurifier_HTMLModule_Tables.m
//  HTMLPurifier
//
//  Created by Roman Priebe on 18.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_HTMLModule_Tables.h"
#import "HTMLPurifier_ChildDef_Tables.h"

/**
 * XHTML 1.1 Tables Module, fully defines accessible table elements.
 */
@implementation HTMLPurifier_HTMLModule_Tables

- (id)initWithConfig:(HTMLPurifier_Config*)config
{
    self = [super initWithConfig:config];
    if (self) {
        self.name = @"Tables";
        [self addElement:@"caption" type:nil contents:@"Inline" attrIncludes:@"Common" attr:nil];
        [self addElement:@"table" type:@"Block" contents:[HTMLPurifier_ChildDef_Tables new] attrIncludes:@"Common" attr:@{@"border":@"Pixels", @"cellpadding":@"Length", @"cellspacing":@"Length", @"frame":@"Enum#void,above,below,hsides,lhs,rhs,vsides,box,border", @"rules":@"Enum#none,groups,rows,cols,all", @"summary":@"Text", @"width":@"Length"}];


        // common attributes

        NSDictionary* cell_align = @{@"align":@"Enum#left,center,right,justify,char", @"charoff":@"Length", @"valign":@"Enum#top,middle,bottom,baseline"};

        NSMutableDictionary* cell_t = [cell_align mutableCopy];
        [cell_t addEntriesFromDictionary:@{@"abbr":@"Text", @"colspan":@"Number", @"rowspan":@"Number", @"scope":@"Enum#row,col,rowgroup,colgroup"}];

        [self addElement:@"td" type:nil contents:@"Flow" attrIncludes:@"Common" attr:cell_t];

        [self addElement:@"th" type:nil contents:@"Flow" attrIncludes:@"Common" attr:cell_t];

        [self addElement:@"tr" type:nil contents:@"Required: td | th" attrIncludes:@"Common" attr:cell_align];

        NSMutableDictionary* cell_col = [cell_align mutableCopy];
        [cell_col addEntriesFromDictionary:@{@"span":@"Number",@"width":@"MultiLength"}];

        [self addElement:@"col" type:nil contents:@"Empty" attrIncludes:@"Common" attr:cell_col];
        [self addElement:@"colgroup" type:nil contents:@"Optional: col" attrIncludes:@"Common" attr:cell_col];

        [self addElement:@"tbody" type:nil contents:@"Required: tr" attrIncludes:@"Common" attr:cell_align];
        [self addElement:@"thead" type:nil contents:@"Required: tr" attrIncludes:@"Common" attr:cell_align];
        [self addElement:@"tfoot" type:nil contents:@"Required: tr" attrIncludes:@"Common" attr:cell_align];
    }
    return self;
}



@end
