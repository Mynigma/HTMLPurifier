//
//  ValidateAttributesTest.m
//  HTMLPurifier
//
//  Created by Roman Priebe on 17.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "HTMLPurifier_Harness.h"
#import "HTMLPurifier_Strategy_ValidateAttributes.h"
#import "HTMLPurifier_Lexer_libxmlLex.h"
#import "HTMLPurifier_Generator.h"

@interface ValidateAttributesTest : HTMLPurifier_Harness
{
    HTMLPurifier_Strategy_ValidateAttributes* obj;

    /**
     * Name of the - (void) to be executed
     */
    SEL func;

    /**
     * Whether or not the method deals in tokens. If set to true, assertResult()
     * will transparently convert HTML to and back from tokens.
     */
    BOOL to_tokens;

    /**
     * Whether or not to convert tokens back into HTML before performing
     * equality check, has no effect on bools.
     */
    BOOL to_html;

    /**
     * Instance of an HTMLPurifier_Lexer implementation.
     */
    HTMLPurifier_Lexer_libxmlLex* lexer;
    
}

@end

static HTMLPurifier_Lexer_libxmlLex* commonLexer;

@implementation ValidateAttributesTest

- (void)setUp
{
    [super createCommon];
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    obj = [HTMLPurifier_Strategy_ValidateAttributes new];
    to_html = YES;
    to_tokens = YES;
    func = @selector(execute:config:context:);
    if(!commonLexer)
        commonLexer = (HTMLPurifier_Lexer_libxmlLex*)[HTMLPurifier_Lexer_libxmlLex createWithConfig:[super config]];
    lexer = commonLexer;
}


- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


- (NSString*)runOnString:(NSString*)string
{
    //NSString* stringCopy = [string copy];
    NSArray* tokenizedString = [lexer tokenizeHTMLWithString:string config:[super config] context:[super context]];


    IMP imp = [obj methodForSelector:func];
    NSArray* (*function)(id, SEL, NSArray*, HTMLPurifier_Config*, HTMLPurifier_Context*) = (void *)imp;
    NSArray* result = function(obj, func, tokenizedString, [super config], [super context]);

    HTMLPurifier_Generator* generator = [[HTMLPurifier_Generator alloc] initWithConfig:[super config] context:[super context]];
    NSString* htmlString = [generator generateFromTokens:result];

    return htmlString;
}


- (void)testEmptyInput
{
    NSString* before = @"";
    NSString* after = [self runOnString:before];
    NSString* expected = @"";
    XCTAssertEqualObjects(after, expected);
}

- (void)testRemoveIDByDefault
{
        NSString* before = @"<div id=\"valid\">Kill the ID.</div>";
        NSString* after = [self runOnString:before];
        NSString* expected = @"<div>Kill the ID.</div>";
        XCTAssertEqualObjects(after, expected);
}

- (void)testRemoveInvalidDir
{
        NSString* before = @"<span dir=\"up-to-down\">Bad dir.</span>";
        NSString* after = [self runOnString:before];
        NSString* expected = @"<span>Bad dir.</span>";
        XCTAssertEqualObjects(after, expected);
}

- (void)testPreserveValidClass
{
        NSString* before = @"<div class=\"valid\">Valid</div>";
        NSString* after = [self runOnString:before];
        NSString* expected = @"<div class=\"valid\">Valid</div>";
        XCTAssertEqualObjects(after, expected);
}


                              /*
 testSelectivelyRemoveInvalidClasses
{
       $this->config->set('HTML.Doctype', 'XHTML 1.1');
        $this->assertResult(
                            '<div class="valid 0invalid">Keep valid.</div>',
                            '<div class="valid">Keep valid.</div>'
                            );
    }*/

- (void) testPreserveTitle
{
        NSString* before = @"<acronym title=\"PHP: Hypertext Preprocessor\">PHP</acronym>";
        NSString* after = [self runOnString:before];
        NSString* expected = @"<acronym title=\"PHP: Hypertext Preprocessor\">PHP</acronym>";
        XCTAssertEqualObjects(after, expected);
    }

- (void) testAddXMLLang
{
        NSString* before = @"<span lang=\"fr\">La soupe.</span>";
        NSString* after = [self runOnString:before];
        NSString* expected = @"<span lang=\"fr\" xml:lang=\"fr\">La soupe.</span>";
        XCTAssertEqualObjects(after, expected);
}

                              /*
    - (void) testOnlyXMLLangInXHTML11
{
        $this->config->set('HTML.Doctype', 'XHTML 1.1');
        $this->assertResult(
                            '<b lang="en">asdf</b>',
                            '<b xml:lang="en">asdf</b>'
                            );
    }*/

- (void) testBasicURI
{
        NSString* before = @"<a href=\"http://www.google.com/\">Google</a>";
        NSString* after = [self runOnString:before];
        NSString* expected = @"<a href=\"http://www.google.com/\">Google</a>";
    XCTAssertEqualObjects(after, expected);
}

- (void) testInvalidURI
{
        NSString* before = @"<a href=\"javascript:badstuff();\">Google</a>";
        NSString* after = [self runOnString:before];
        NSString* expected = @"<a>Google</a>";
        XCTAssertEqualObjects(after, expected);
}

- (void) testBdoAddMissingDir
{
        NSString* before = @"<bdo>Go left.</bdo>";
        NSString* after = [self runOnString:before];
        NSString* expected = @"<bdo dir=\"ltr\">Go left.</bdo>";
        XCTAssertEqualObjects(after, expected);
}

- (void)testBdoReplaceInvalidDirWithDefault
{
        NSString* before = @"<bdo dir=\"blahblah\">Invalid value!</bdo>";
        NSString* after = [self runOnString:before];
        NSString* expected = @"<bdo dir=\"ltr\">Invalid value!</bdo>";
        XCTAssertEqualObjects(after, expected);
}

                              /*
    - (void) testBdoAlternateDefaultDir
{
        $this->config->set('Attr.DefaultTextDir', 'rtl');
        $this->assertResult(
                            '<bdo>Go right.</bdo>',
                            '<bdo dir="rtl">Go right.</bdo>'
                            );
    }*/

- (void) testRemoveDirWhenNotRequired
{
        NSString* before = @"<span dir=\"blahblah\">Invalid value!</span>";
        NSString* after = [self runOnString:before];
        NSString* expected = @"<span>Invalid value!</span>";
        XCTAssertEqualObjects(after, expected);
}

- (void) testTableAttributes
{
    NSString* before = @"<table frame=\"above\" rules=\"rows\" summary=\"A test table\" border=\"2\" cellpadding=\"5%\" cellspacing=\"3\" width=\"100%\">\n<col align=\"right\" width=\"4*\" />\n<col charoff=\"5\" align=\"char\" width=\"*\" />\n<tr valign=\"top\">\n<th abbr=\"name\">Fiddly name</th>\n<th abbr=\"price\">Super-duper-price</th>\n</tr>\n<tr>\n<td abbr=\"carrot\">Carrot Humungous</td>\n<td>$500.23</td>\n</tr>\n<tr>\n<td colspan=\"2\">Taken off the market</td>\n</tr>\n</table>";
        NSString* after = [self runOnString:before];
        NSString* expected = before;
        XCTAssertEqualObjects(after, expected);
}

- (void) testColSpanIsNonZero
{
        NSString* before = @"<col span=\"0\" />";
        NSString* after = [self runOnString:before];
        NSString* expected = @"<col />";
        XCTAssertEqualObjects(after, expected);
}

                              /*
    - (void) testImgAddDefaults
{
        $this->config->set('Core.RemoveInvalidImg', false);
        $this->assertResult(
                            '<img />',
                            '<img src="" alt="Invalid image" />'
                            );
    }*/

- (void) testImgGenerateAlt
{
    NSString* before = @"<img src=\"foobar.jpg\" />";
    NSString* after = [self runOnString:before];
    NSString* expected = @"<img src=\"foobar.jpg\" alt=\"foobar.jpg\" />";
    XCTAssertEqualObjects(after, expected);
}

                              /*
    - (void) testImgAddDefaultSrc
{
        $this->config->set('Core.RemoveInvalidImg', false);
        $this->assertResult(
                            '<img alt="pretty picture" />',
                            '<img alt="pretty picture" src="" />'
                            );
    }

    - (void) testImgRemoveNonRetrievableProtocol
{
        $this->config->set('Core.RemoveInvalidImg', false);
        $this->assertResult(
                            '<img src="mailto:foo@example.com" />',
                            '<img alt="mailto:foo@example.com" src="" />'
                            );
    }

    - (void) testPreserveRel
{
        $this->config->set('Attr.AllowedRel', 'nofollow');
        $this->assertResult('<a href="foo" rel="nofollow" />');
    }

    - (void) testPreserveTarget
{
        $this->config->set('Attr.AllowedFrameTargets', '_top');
        $this->config->set('HTML.Doctype', 'XHTML 1.0 Transitional');
        $this->assertResult('<a href="foo" target="_top" />');
    }

    - (void) testRemoveTargetWhenNotSupported
{
        $this->config->set('HTML.Doctype', 'XHTML 1.0 Strict');
        $this->config->set('Attr.AllowedFrameTargets', '_top');
        $this->assertResult(
                            '<a href="foo" target="_top" />',
                            '<a href="foo" />'
                            );
    }*/

- (void) testKeepAbsoluteCSSWidthAndHeightOnImg
{
    NSString* before = @"<img src=\"\" alt=\"\" style=\"width:10px;height:10px;border:1px solid #000;\" />";
    NSString* after = [self runOnString:before];
    NSString* expected = before;
    XCTAssertEqualObjects(after, expected);
}

- (void) testRemoveLargeCSSWidthAndHeightOnImg
{
    NSString* before = @"<img src=\"\" alt=\"\" style=\"width:10000000px;height:10000000px;border:1px solid #000;\" />";
    NSString* after = [self runOnString:before];
    NSString* expected = @"<img src=\"\" alt=\"\" style=\"border:1px solid #000;\" />";
    XCTAssertEqualObjects(after, expected);
}

                              /*
    - (void) testRemoveLargeCSSWidthAndHeightOnImgWithUserConf
{
        $this->config->set('CSS.MaxImgLength', '1px');
        $this->assertResult(
                            '<img src="" alt="" style="width:1mm;height:1mm;border:1px solid #000;" />',
                            '<img src="" alt="" style="border:1px solid #000;" />'
                            );
    }
    
    - (void) testKeepLargeCSSWidthAndHeightOnImgWhenToldTo
{
        $this->config->set('CSS.MaxImgLength', null);
        $this->assertResult(
                            '<img src="" alt="" style="width:10000000px;height:10000000px;border:1px solid #000;" />'
                            );
    }
    
    - (void) testKeepPercentCSSWidthAndHeightOnImgWhenToldTo
{
        $this->config->set('CSS.MaxImgLength', null);
        $this->assertResult(
                            '<img src="" alt="" style="width:100%;height:100%;border:1px solid #000;" />'
                            );
    }*/
    
- (void)testRemoveRelativeCSSWidthAndHeightOnImg
{
    NSString* before = @"<img src=\"\" alt=\"\" style=\"width:10em;height:10em;border:1px solid #000;\" />";
    NSString* after = [self runOnString:before];
    NSString* expected = @"<img src=\"\" alt=\"\" style=\"border:1px solid #000;\" />";
    XCTAssertEqualObjects(after, expected);
}
    
- (void)testRemovePercentCSSWidthAndHeightOnImg
{
    NSString* before = @"<img src=\"\" alt=\"\" style=\"width:100%;height:100%;border:1px solid #000;\" />";
    NSString* after = [self runOnString:before];
    NSString* expected = @"<img src=\"\" alt=\"\" style=\"border:1px solid #000;\" />";
    XCTAssertEqualObjects(after, expected);
}


@end
