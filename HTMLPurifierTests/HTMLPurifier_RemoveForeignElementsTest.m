//
//  HTMLPurifier_RemoveForeignElementsTest.m
//  HTMLPurifier
//
//  Created by Roman Priebe on 15.01.14.


#import <XCTest/XCTest.h>
#import "HTMLPurifier_Strategy_RemoveForeignElements.h"
#import "HTMLPurifier_Lexer_libxmlLex.h"
#import "HTMLPurifier_Harness.h"
#import "HTMLPurifier_Generator.h"
#import "HTMLPurifier_Config.h"
#import "HTMLPurifier_HTMLDefinition.h"


@interface HTMLPurifier_RemoveForeignElementsTest : HTMLPurifier_Harness
{
    HTMLPurifier_Strategy_RemoveForeignElements* obj;

    /**
     * Name of the function to be executed
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

@implementation HTMLPurifier_RemoveForeignElementsTest

- (void)setUp
{
    [super createCommon];
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    to_html = YES;
    to_tokens = YES;
    func = @selector(execute:config:context:);
    obj = [HTMLPurifier_Strategy_RemoveForeignElements new];
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

- (void)testBlankInput
{
    NSString* testString = @"";
    XCTAssertEqualObjects([self runOnString:testString], testString);
}


- (void)testPreserveRecognizedElements
{
    NSString* testString = @"This is <b>bold text</b>.";
    XCTAssertEqualObjects([self runOnString:testString], testString);
}


- (void)testRemoveForeignElements
{
    NSString* before = @"<asdf>Bling</asdf><d href=\"bang\">Bong</d><foobar />";
    NSString* after = @"BlingBong";
    before = [self runOnString:before];

    XCTAssertEqualObjects(before, after);
}

- (void)testRemoveScriptAndContents
{
    NSString* before = @"<script>alert();</script>";
    NSString* after = @"";
    before = [self runOnString:before];

    XCTAssertEqualObjects(before, after);
}

- (void)testRemoveStyleAndContents
{
    NSString* before = @"<style>.foo {blink;}</style>";
    NSString* after = @"";
    before = [self runOnString:before];

    XCTAssertEqualObjects(before, after);
}

/*
- (void)testRemoveOnlyScriptTagsLegacy
{
    [super.config setString:@"Core.RemoveScriptContents" object:@NO];
        NSString* before = @"<script>alert();</script>";
        NSString* after = @"alert();";
    before = [self runOnString:before];

    XCTAssertEqualObjects(before, after);
}


- (void)testRemoveOnlyScriptTags
{
    [super.config setString:@"Core.HiddenElements" object:@[]];
    NSString* before = @"<script>alert();</script>";
        NSString* after = @"alert();";
    before = [self runOnString:before];

        XCTAssertEqualObjects(before, after);
}
*/

- (void)testRemoveInvalidImg
{
        NSString* before = @"<img />";
        // was NSString* after = @"";
        NSString* expect = @"<img src=\"\" alt=\"Invalid image\" />";
        before = [self runOnString:before];

        XCTAssertEqualObjects(before, expect);
}

- (void)testPreserveValidImg
{
        NSString* before = @"<img src=\"foobar.gif\" alt=\"foobar.gif\" />";
        NSString* after = @"<img src=\"foobar.gif\" alt=\"foobar.gif\" />";
    before = [self runOnString:before];

        XCTAssertEqualObjects(before, after);
}

/*
- (void)testPreserveInvalidImgWhenRemovalIsDisabled
{
    [super.config setString:@"Core.RemoveInvalidImg" object:@NO];
        NSString* before = @"<img />";
        NSString* after = @"<img />";
    before = [self runOnString:before];

        XCTAssertEqualObjects(before, after);
}

- (void)testTextifyCommentedScriptContents
{
    [super.config setString:@"HTML.Trusted" object:@YES];
    [super.config setString:@"Output.CommentScriptContents" object:@NO];
    NSString* before = @"<script type=\"text/javascript\"><!--\n    alert(<b>bold</b>);\n    // --></script>";
    NSString* after = @"<script type=\"text/javascript\"><!--\n    alert(<b>bold</b>);\n    // --></script>";
    before = [self runOnString:before];

    XCTAssertEqualObjects(before, after);
}


- (void)testRequiredAttributesTestNotPerformedOnEndTag
{
    [super.config setString:@"HTML.DefinitionID" object:@{@"HTMLPurifier_Strategy_RemoveForeignElementsTest":@"testRequiredAttributesTestNotPerformedOnEndTag"}];
    HTMLPurifier_HTMLDefinition* def = [super.config getHTMLDefinition]; //parameter: YES

    [def addElement:@"f" type:@"Block" contents:@{@"Optional": @"#PCDATA"} attrCollections:nil attributes:@{@"req*" : @"Text"}];

    NSString* before = @"<f req=\"text\">Foo</f> Bar";
    NSString* after = @"<f req=\"text\">Foo</f> Bar";
    before = [self runOnString:before];

        XCTAssertEqualObjects(before, after);
    }

- (void)testPreserveCommentsWithHTMLTrusted
{
    [super.config setString:@"HTML.Trusted" object:@YES];

        NSString* before = @"<!-- foo -->";
        NSString* after = @"<!-- foo -->";

    before = [self runOnString:before];
        XCTAssertEqualObjects(before, after);
    }
    
- (void)testRemoveTrailingHyphensInComment
{
    [super.config setString:@"HTML.Trusted" object:@YES];

    NSString* before = @"<!-- foo ----->";
        NSString* after = @"<!-- foo -->";
    before = [self runOnString:before];

        XCTAssertEqualObjects(before, after);
    }
    
- (void)testCollapseDoubleHyphensInComment
{
    [super.config setString:@"HTML.Trusted" object:@YES];

    NSString* before = @"<!-- bo --- asdf--as -->";
        NSString* after = @"<!-- bo - asdf-as -->";
    before = [self runOnString:before];

        XCTAssertEqualObjects(before, after);
    }
*/



@end
