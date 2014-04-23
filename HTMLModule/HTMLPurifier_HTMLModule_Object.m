//
//  HTMLPurifer_HTMLModule_Object.m
//   HTMLPurifier
//
//  Created by Roman Priebe on 18.01.14.


#import "HTMLPurifier_HTMLModule_Object.h"

@implementation HTMLPurifier_HTMLModule_Object

- (id)initWithConfig:(HTMLPurifier_Config*)config
{
    self = [super initWithConfig:config];
    if(self)
    {
        self.name = @"Object";
        self.safe = NO;

        [self addElement:@"object" type:@"Inline" contents:@"Optional: #PCDATA | Flow | param" attrIncludes:@"Common" attr:@{@"archive" : @"URI", @"classid" : @"URI", @"codebase" : @"URI", @"codetype" : @"Text", @"data" : @"URI", @"declare" : @"Bool#declare", @"height" : @"Length", @"name" : @"CDATA", @"standby" : @"Text", @"tabindex" : @"Number", @"type" : @"ContentType", @"width" : @"Length"}];

        [self addElement:@"param" type:nil contents:@"Empty" attrIncludes:nil attr:@{@"id":@"ID", @"name*":@"Text", @"type":@"Text", @"value":@"Text", @"valuetype":@"Enum#data,ref,object"}];
    }
    return self;
}


@end
