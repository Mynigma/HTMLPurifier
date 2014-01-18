//
//  CSSTest.m
//  HTMLPurifier
//
//  Created by Roman Priebe on 18.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "HTMLPurifier_AttrDefHarness.h"
#import "HTMLPurifier_AttrDef_CSS.h"


@interface CSSTest : HTMLPurifier_AttrDefHarness
{
    HTMLPurifier_AttrDef_CSS* def;
}

@end

@implementation CSSTest

- (void)setUp
{
    [super setUp];
    def = [HTMLPurifier_AttrDef_CSS new];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)assertDef:(NSString*)before
{
    NSString* result = [def validateWithString:before config:super.config context:super.context];
    XCTAssertEqualObjects(result, before);
}

- (void)assertDef:(NSString*)before expected:(NSString*)expected
{
    NSString* result = [def validateWithString:before config:super.config context:super.context];
    XCTAssertEqualObjects(result, expected);
}


- (void)test
{
        [self assertDef:@"text-align:right;"];
            [self assertDef:@"border-left-style:solid;"];
            [self assertDef:@"border-style:solid dotted;"];
            [self assertDef:@"clear:right;"];
            [self assertDef:@"float:left;"];
            [self assertDef:@"font-style:italic;"];
            [self assertDef:@"font-variant:small-caps;"];
            [self assertDef:@"font-weight:bold;"];
            [self assertDef:@"list-style-position:outside;"];
            [self assertDef:@"list-style-type:upper-roman;"];
            [self assertDef:@"list-style:upper-roman inside;"];
            [self assertDef:@"text-transform:capitalize;"];
            [self assertDef:@"background-color:rgb(0,0,255);"];
            [self assertDef:@"background-color:transparent;"];
            [self assertDef:@"background:#333 url(chess.png) repeat fixed 50% top;"];
            [self assertDef:@"color:#F00;"];
            [self assertDef:@"border-top-color:#F00;"];
            [self assertDef:@"border-color:#F00 #FF0;"];
            [self assertDef:@"border-top-width:thin;"];
            [self assertDef:@"border-top-width:12px;"];
            [self assertDef:@"border-width:5px 1px 4px 2px;"];
            [self assertDef:@"border-top-width:-12px;" expected:nil];
            [self assertDef:@"letter-spacing:normal;"];
            [self assertDef:@"letter-spacing:2px;"];
            [self assertDef:@"word-spacing:normal;"];
            [self assertDef:@"word-spacing:3em;"];
            [self assertDef:@"font-size:200%;"];
            [self assertDef:@"font-size:larger;"];
            [self assertDef:@"font-size:12pt;"];
            [self assertDef:@"line-height:2;"];
            [self assertDef:@"line-height:2em;"];
            [self assertDef:@"line-height:20%;"];
            [self assertDef:@"line-height:normal;"];
            [self assertDef:@"line-height:-20%;" expected:nil];
            [self assertDef:@"margin-left:5px;"];
            [self assertDef:@"margin-right:20%;"];
            [self assertDef:@"margin-top:auto;"];
            [self assertDef:@"margin:auto 5%;"];
            [self assertDef:@"padding-bottom:5px;"];
            [self assertDef:@"padding-top:20%;"];
            [self assertDef:@"padding:20% 10%;"];
            [self assertDef:@"padding-top:-20%;" expected:nil];
            [self assertDef:@"text-indent:3em;"];
            [self assertDef:@"text-indent:5%;"];
            [self assertDef:@"text-indent:-3em;"];
            [self assertDef:@"width:50%;"];
            [self assertDef:@"width:50px;"];
            [self assertDef:@"width:auto;"];
            [self assertDef:@"width:-50px;" expected:nil];
            [self assertDef:@"text-decoration:underline;"];
            [self assertDef:@"font-family:sans-serif;"];
            [self assertDef:@"font-family:Gill, \'Times New Roman\', sans-serif;"];
            [self assertDef:@"font:12px serif;"];
            [self assertDef:@"border:1px solid #000;"];
            [self assertDef:@"border-bottom:2em double #FF00FA;"];
            [self assertDef:@"border-collapse:collapse;"];
            [self assertDef:@"border-collapse:separate;"];
            [self assertDef:@"caption-side:top;"];
            [self assertDef:@"vertical-align:middle;"];
            [self assertDef:@"vertical-align:12px;"];
            [self assertDef:@"vertical-align:50%;"];
            [self assertDef:@"table-layout:fixed;"];
            [self assertDef:@"list-style-image:url(nice.jpg);"];
            [self assertDef:@"list-style:disc url(nice.jpg) inside;"];
            [self assertDef:@"background-image:url(foo.jpg);"];
            [self assertDef:@"background-image:none;"];
            [self assertDef:@"background-repeat:repeat-y;"];
            [self assertDef:@"background-attachment:fixed;"];
            [self assertDef:@"background-position:left 90%;"];
            [self assertDef:@"border-spacing:1em;"];
            [self assertDef:@"border-spacing:1em 2em;"];

            // duplicates
            [self assertDef:@"text-align:right;text-align:left;" expected:@"text-align:left;"];

            // a few composites
            [self assertDef:@"font-variant:small-caps;font-weight:900;"];
            [self assertDef:@"float:right;text-align:right;"];

            // selective removal
            [self assertDef:@"text-transform:capitalize;destroy:it;" expected:@"text-transform:capitalize;"];

            // inherit works for everything
            [self assertDef:@"text-align:inherit;"];

            // bad props
            [self assertDef:@"nodice:foobar;" expected:nil];
            [self assertDef:@"position:absolute;" expected:nil];
            [self assertDef:@"background-image:url(javascript:alert\\(\\));" expected:nil];

            // airy input
            [self assertDef:@" font-weight : bold; color : #ff0000" expected:@"font-weight:bold;color:#ff0000;"];

            // case-insensitivity
            [self assertDef:@"FLOAT:LEFT;" expected:@"float:left;"];

            // !important stripping
            [self assertDef:@"float:left !important;" expected:@"float:left;"];

        }

- (void)testProprietary
    {
            [super.config setString:@"CSS.Proprietary" object:@YES];

            [self assertDef:@"scrollbar-arrow-color:#ff0;"];
            [self assertDef:@"scrollbar-base-color:#ff6347;"];
            [self assertDef:@"scrollbar-darkshadow-color:#ffa500;"];
            [self assertDef:@"scrollbar-face-color:#008080;"];
            [self assertDef:@"scrollbar-highlight-color:#ff69b4;"];
            [self assertDef:@"scrollbar-shadow-color:#f0f;"];
            
            [self assertDef:@"opacity:.2;"];
            [self assertDef:@"-moz-opacity:.2;"];
            [self assertDef:@"-khtml-opacity:.2;"];
            [self assertDef:@"filter:alpha(opacity=20);"];
            
        }
        
- (void)testImportant
{
            [super.config setString:@"CSS.AllowImportant" object:@YES];
            [self assertDef:@"float:left !important;"];
        }
        
- (void)testTricky
{
            [super.config setString:@"CSS.AllowTricky" object:@YES];
            [self assertDef:@"display:none;"];
            [self assertDef:@"visibility:visible;"];
            [self assertDef:@"overflow:scroll;"];
}


@end
