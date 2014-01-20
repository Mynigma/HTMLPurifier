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


- (void)testUpperRomanInside
{
    [self assertDef:@"list-style:upper-roman inside;"];
}

- (void)testSome
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
}

- (void)testTextTransformCapitalize
{
    [self assertDef:@"text-transform:capitalize;"];
}

- (void)testBackgroundColorRGB
{
    [self assertDef:@"background-color:rgb(0,0,255);"];
}

- (void)testBackgroundColorTransparent
{
    [self assertDef:@"background-color:transparent;"];
}

- (void)testBackgroundImage
{
    [self assertDef:@"background:#333 url(\"chess.png\") repeat fixed 50% top;"];
}

- (void)testColorHex
{
    [self assertDef:@"color:#F00;"];
}

- (void)testBorderTopColor
{
    [self assertDef:@"border-top-color:#F00;"];
}

- (void)testBorderColor
{
    [self assertDef:@"border-color:#F00 #FF0;"];
}

- (void)testBorderTopWidthThin
{
    [self assertDef:@"border-top-width:thin;"];
}

- (void)testBorderTopWidth12px
{
    [self assertDef:@"border-top-width:12px;"];
}

- (void)testBorderWidth
{
    [self assertDef:@"border-width:5px 1px 4px 2px;"];
}

- (void)testBorderTopWidth
{
    [self assertDef:@"border-top-width:-12px;" expected:nil];
}

- (void)testLetterSpacingNormal
{
    [self assertDef:@"letter-spacing:normal;"];
}

- (void)testLetterSpacing2px
{
    [self assertDef:@"letter-spacing:2px;"];
}

- (void)testWordSpacingNormal
{
    [self assertDef:@"word-spacing:normal;"];
}

- (void)testWordSpacing3em
{
    [self assertDef:@"word-spacing:3em;"];
}

- (void)testFontSize200
{
    [self assertDef:@"font-size:200%;"];
}

- (void)testFontSizeLarger
{
    [self assertDef:@"font-size:larger;"];
    [self assertDef:@"font-size:12pt;"];
    [self assertDef:@"line-height:2;"];
    [self assertDef:@"line-height:2em;"];
    [self assertDef:@"line-height:20%;"];
    [self assertDef:@"line-height:normal;"];
}

- (void)testLineHeightMinus
{
    [self assertDef:@"line-height:-20%;" expected:nil];
}

- (void)testMarginLeft
{
    [self assertDef:@"margin-left:5px;"];
}

- (void)testMarginRight
{
    [self assertDef:@"margin-right:20%;"];
}

- (void)testMarginTop
{
    [self assertDef:@"margin-top:auto;"];
}

- (void)testMarginAuto
{
    [self assertDef:@"margin:auto 5%;"];
}

- (void)testPaddingBottom
{
    [self assertDef:@"padding-bottom:5px;"];
}

- (void)testPaddingTop
{
    [self assertDef:@"padding-top:20%;"];
}

- (void)testPaddingPercent
{
    [self assertDef:@"padding:20% 10%;"];
}

- (void)testPaddingTopNegativePercent
{
    [self assertDef:@"padding-top:-20%;" expected:nil];
}

- (void)testTextIndentEm
{
    [self assertDef:@"text-indent:3em;"];
}

- (void)testTextIndentPercent
{
   [self assertDef:@"text-indent:5%;"];
}

- (void)testTextIndentNegativeEm
{
    [self assertDef:@"text-indent:-3em;"];
}

- (void)testEvenMore
{
    [self assertDef:@"width:50%;"];
}

- (void)testWidth
{
    [self assertDef:@"width:50px;"];
}

- (void)testWithAuto
{
    [self assertDef:@"width:auto;"];
}

- (void)testWidthNegative
{
    [self assertDef:@"width:-50px;" expected:nil];
}

- (void)testTextDeco
{
    [self assertDef:@"text-decoration:underline;"];
}

- (void)testFontSans
{
    [self assertDef:@"font-family:sans-serif;"];
}

- (void)testFontGill
{
    [self assertDef:@"font-family:Gill, \'Times New Roman\', sans-serif;"];
}

- (void)testFont12px
{
    [self assertDef:@"font:12px serif;"];
}

- (void)testBorder
{
    [self assertDef:@"border:1px solid #000;"];
}

- (void)testBorderBottom
{
    [self assertDef:@"border-bottom:2em double #FF00FA;"];
}

- (void)testBorderCollapse
{
    [self assertDef:@"border-collapse:collapse;"];
}

- (void)testBorderSeparate
{
    [self assertDef:@"border-collapse:separate;"];
}

- (void)testCaptionSide
{
    [self assertDef:@"caption-side:top;"];
}

- (void)testVerticalAlignMiddle
{
    [self assertDef:@"vertical-align:middle;"];
}

- (void)testVerticalAlign
{
    [self assertDef:@"vertical-align:12px;"];
}

- (void)testVerticalAlignPercent
{
    [self assertDef:@"vertical-align:50%;"];
}

- (void)testTableLayout
{
    [self assertDef:@"table-layout:fixed;"];
}

- (void)testListStyleImage
{
    [self assertDef:@"list-style-image:url(\"nice.jpg\");"];
}

- (void)testListStyle
{
    [self assertDef:@"list-style:disc url(\"nice.jpg\") inside;"];
}

- (void)testBackgroundImageUrl
{
    [self assertDef:@"background-image:url(\"foo.jpg\");"];
}

- (void)testBackgroundImageNone
{
    [self assertDef:@"background-image:none;"];
}

- (void)testBackgroundRepeat
{
    [self assertDef:@"background-repeat:repeat-y;"];
}

- (void)testBackgroundAttachment
{
    [self assertDef:@"background-attachment:fixed;"];
}

- (void)testBackgroundPosition
{
    [self assertDef:@"background-position:left 90%;"];
}

- (void)testBorderSpacing
{
    [self assertDef:@"border-spacing:1em;"];
}

- (void)testBorderSpacingTwo
{
    [self assertDef:@"border-spacing:1em 2em;"];

}

- (void)testTextAlignSeveral
{
    // duplicates
    [self assertDef:@"text-align:right;text-align:left;" expected:@"text-align:left;"];

}

- (void)testFontVariant
{
    // a few composites
    [self assertDef:@"font-variant:small-caps;font-weight:900;"];
}

- (void)testFloat
{
    [self assertDef:@"float:right;text-align:right;"];

}

- (void)testTestTransform
{
    // selective removal
    [self assertDef:@"text-transform:capitalize;destroy:it;" expected:@"text-transform:capitalize;"];

}

- (void)testTextAlignInherit
{
    // inherit works for everything
    [self assertDef:@"text-align:inherit;"];

}

- (void)testNodice
{
    // bad props
    [self assertDef:@"nodice:foobar;" expected:nil];
}

- (void)testPositionAbsolute
{
    [self assertDef:@"position:absolute;" expected:nil];
}

- (void)testBackgroundImageUrlScript
{
    [self assertDef:@"background-image:url(javascript:alert\\(\\));" expected:nil];

}

- (void)testAiry
{
    // airy input
    [self assertDef:@" font-weight : bold; color : #ff0000" expected:@"font-weight:bold;color:#ff0000;"];

    // case-insensitivity
}

- (void)testFLOATLEFT
{
    [self assertDef:@"FLOAT:LEFT;" expected:@"float:left;"];

}

- (void)testImportant
{
    // !important stripping
    [self assertDef:@"float:left !important;" expected:@"float:left;"];

}


/*
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
}*/


@end
