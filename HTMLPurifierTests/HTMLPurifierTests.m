//
//   HTMLPurifierTests.m
//   HTMLPurifierTests
//
//  Created by Lukas Neumann on 10.01.14.



#import <XCTest/XCTest.h>
#import "HTMLPurifier_Harness.h"
#import "HTMLPurifier.h"
#import "HTMLPurifier_Config.h"
#import "HTMLPurifier_Context.h"

#define BUNDLE (NSClassFromString(@"HTMLPurifierTests")!=nil)?[NSBundle bundleForClass:[NSClassFromString(@"HTMLPurifierTests") class]]:[NSBundle bundleForClass:[NSClassFromString(@"HTMLPurifier") class]]

@interface HTMLPurifierTests : HTMLPurifier_Harness
{
    /**
     * @type HTMLPurifier
     */
    HTMLPurifier* purifier;
}

@end

@implementation HTMLPurifierTests

- (void)setUp
{
    [super createCommon];
    [super.config setString:@"Output.Newline" object:@"\n"];
    purifier = [HTMLPurifier new];
    [super setUp];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


- (void)testSomethingOrOther
{
NSString* testHTML = @"<!DOCTYPE html><html xmlns=\"http://www.w3.org/1999/xhtml\"><head><meta name=\"generator\" content=\"HTML Tidy for HTML5 (experimental) for Mac OS X https://github.com/w3c/tidy-html5/tree/c63cc39\" /><meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" /><title>Magazin-kw2114-DE_FM</title></head><body bgcolor=\"#C7D5E7\" link=\"#2269C3\" vlink=\"#2269C3\" alink=\"#2269C3\" text=\"#000000\" topmargin=\"0\" leftmargin=\"20\" marginheight=\"0\" marginwidth=\"0\"><img src=\"https://mailings.gmx.net/action/view/11231/2o2gy1vt\" border=\"0\" width=\"1\" height=\"1\" alt=\"\" /><table width=\"100%\" border=\"0\" cellspacing=\"0\" cellpadding=\"0\"><tr><td width=\"620\"><!-- Header --><table width=\"620\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\"><tr><td width=\"1\" bgcolor=\"#C4D3E6\"><img src=\"https://img.ui-portal.de/p.gif\" alt=\"\" width=\"1\" height=\"1\" border=\"0\" /></td><td width=\"1\" bgcolor=\"#BFCEE1\"><img src=\"https://img.ui-portal.de/p.gif\" alt=\"\" width=\"1\" height=\"1\" border=\"0\" /></td><td width=\"1\" bgcolor=\"#B9C8DB\"><img src=\"https://img.ui-portal.de/p.gif\" alt=\"\" width=\"1\" height=\"1\" border=\"0\" /></td><td width=\"1\" bgcolor=\"#B2BFCF\"><img src=\"https://img.ui-portal.de/p.gif\" alt=\"\" width=\"1\" height=\"1\" border=\"0\" /></td></tr></table></body></html>";

NSString* cleanedHTML = [HTMLPurifier cleanHTML:testHTML];

NSLog(@"Output: %@", cleanedHTML);
}

- (void)testNull
{
    [self assertPurification:@"Null byte\0" expect:@"Null byte"];
}

- (void)test_purifyArray
{
    NSArray* result = [purifier purifyArray:@[@"Good", @"<b>Sketchy", @"<script>bad</script>"]];
    NSArray* expect = @[@"Good", @"<b>Sketchy</b>", @""];
    XCTAssertEqualObjects(result, expect);

    XCTAssertTrue([purifier.context isKindOfClass:[NSArray class]]);
}

- (void)testGetInstance
{
    HTMLPurifier* purifier1  = [HTMLPurifier instance];
    HTMLPurifier* purifier2 = [HTMLPurifier instance];
    XCTAssertEqual(purifier1, purifier2);
}

- (void)testLinkify
{
    NSString* result = [purifier purify:@"Hi Lukas, hier ist ein Link: http://www.mynigma.org/test.html"];
    NSString* expect = @"Hi Lukas, hier ist ein Link: <a href=\"http://www.mynigma.org/test.html\">http://www.mynigma.org/test.html</a>";
    XCTAssertEqualObjects(result, expect);
}

-(void) testLinkfyWithWWW
{
    NSString* result = [purifier purify:@"Ich teste diesen Link www.test.de test"];
    XCTAssertEqualObjects(result, @"Ich teste diesen Link <a href=\"http://www.test.de\">www.test.de</a> test");
}

-(void) testLinkfyWithComma
{
    NSString* result = [purifier purify:@"Ich teste diesen Link http://forum.golem.de/read.php?93325,4185103,4185150#msg-4185150 test"];
    XCTAssertEqualObjects(result, @"Ich teste diesen Link <a href=\"http://forum.golem.de/read.php?93325,4185103,4185150#msg-4185150\">http://forum.golem.de/read.php?93325,4185103,4185150#msg-4185150</a> test");
}

-(void) d_testDebug
{
    NSString* data = [[NSString alloc] initWithContentsOfFile:@"/Users/Lukas/Desktop/email.txt" encoding:NSUTF8StringEncoding error:nil];
    NSString* result = [purifier purify:data];
    NSString* expect = @"";
    XCTAssertEqualObjects(result, expect);
    
}

-(void) testForEmail
{
    NSString* result = [purifier purify:@"<img src='cid:foo.foo@bar.de'>"];
    XCTAssertEqualObjects(result, @"<img src=\"cid:foo.foo@bar.de\" alt=\"cid:foo.foo@bar.de\" />");
}


-(void) testURIwithTilde
{
    NSString* result = [purifier purify:@"<a style=\"color: #538dc2;\" href=\"http://www.quora.com/l/2Ql8wc3~QpE0iGHY4wndQxPuYryrn-Y98PAIkbcx2wzAAzYFuqwwIMMB0iGa4-oTP9pwagDtxGKcFVDsp3xalMcqBYvImPGXzjyI1S9qQN~eKQVuqOwFdYiCYwqeunnUaEK9r-KRczlSWGdHnETebteAQ3ZVfwT-gXMmUae-OWmNL1Cyg68mzlLSBXKuggJ3LQHsndlvcnA9oDUXZztolszXg8UDGoA5yJcdV6Cbk6M~ReeiU3ndrDUHmHyetF00EOxoY-W6e88x~~u82sypv1\">http://www.quora.com/login/auto_login?...</a>"];
    XCTAssertEqualObjects(result, @"<a style=\"color:#538dc2;\" href=\"http://www.quora.com/l/2Ql8wc3~QpE0iGHY4wndQxPuYryrn-Y98PAIkbcx2wzAAzYFuqwwIMMB0iGa4-oTP9pwagDtxGKcFVDsp3xalMcqBYvImPGXzjyI1S9qQN~eKQVuqOwFdYiCYwqeunnUaEK9r-KRczlSWGdHnETebteAQ3ZVfwT-gXMmUae-OWmNL1Cyg68mzlLSBXKuggJ3LQHsndlvcnA9oDUXZztolszXg8UDGoA5yJcdV6Cbk6M~ReeiU3ndrDUHmHyetF00EOxoY-W6e88x~~u82sypv1\">http://www.quora.com/login/auto_login?...</a>");
}


-(void) EXMPLRDISABLEDtestMassiveTableNesting
{
    NSError *error = nil;
    NSString* result = [NSString stringWithContentsOfURL:[BUNDLE URLForResource:@"bufferORIG" withExtension:@"html"] encoding:NSUTF8StringEncoding error:&error];
    NSString* cleaned = [NSString stringWithContentsOfURL:[BUNDLE URLForResource:@"bufferCLEAN" withExtension:@"html"] encoding:NSUTF8StringEncoding error:&error];
    result = [purifier purify:result];
    XCTAssertEqualObjects(result,cleaned);
}

-(void) testMinimalTableFuckUp
{
    NSString* test = @"<table><tr><td>valid1</td></tr><tr><table><tr><td>blah</td></tr></table></tr><tr><td>valid2</td></tr><table><tr><td>blub</td></tr></table></table>";    
    NSString* result = [purifier purify:test];

    // Note Fix Nesting should get rid of the empty <tr></tr> which was added by make well formed.
    XCTAssertEqualObjects(result,@"<table><tr><td>valid1</td></tr></table><table><tr><td>blah</td></tr></table>valid2<table><tr><td>blub</td></tr></table>");
}

-(void) testVisibility
{
    NSString* test = @"<span style=\"display: none !important; visibility: hidden; width: 0; height: 0; opacity: 0; color: transparent;\"> Popular video by EinKamel: \"WM 2014 Müller boarisch\"</span>";
    NSString* result = [purifier purify:test];
    XCTAssertEqualObjects(result,@"<span style=\"display:none;visibility:hidden;width:0;height:0;opacity:0;\"> Popular video by EinKamel: \"WM 2014 Müller boarisch\"</span>");
}

-(void) testBase64Img
{
    NSString* test = @"<img height=\"36px\" src=\"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAoAAAAKCAYAAACNMs+9AAAABGdBTUEAALGPC/xhBQAAAAlwSFlzAAALEwAACxMBAJqcGAAAAAd0SU1FB9YGARc5KB0XV+IAAAAddEVYdENvbW1lbnQAQ3JlYXRlZCB3aXRoIFRoZSBHSU1Q72QlbgAAAF1JREFUGNO9zL0NglAAxPEfdLTs4BZM4DIO4C7OwQg2JoQ9LE1exdlYvBBeZ7jqch9//q1uH4TLzw4d6+ErXMMcXuHWxId3KOETnnXXV6MJpcq2MLaI97CER3N0vr4MkhoXe0rZigAAAABJRU5ErkJggg==\" width=\"170px\" alt=\"image\">";
    NSString* result = [purifier purify:test];
    XCTAssertEqualObjects(result,@"<img height=\"36\" src=\"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAoAAAAKCAYAAACNMs+9AAAABGdBTUEAALGPC/xhBQAAAAlwSFlzAAALEwAACxMBAJqcGAAAAAd0SU1FB9YGARc5KB0XV+IAAAAddEVYdENvbW1lbnQAQ3JlYXRlZCB3aXRoIFRoZSBHSU1Q72QlbgAAAF1JREFUGNO9zL0NglAAxPEfdLTs4BZM4DIO4C7OwQg2JoQ9LE1exdlYvBBeZ7jqch9//q1uH4TLzw4d6+ErXMMcXuHWxId3KOETnnXXV6MJpcq2MLaI97CER3N0vr4MkhoXe0rZigAAAABJRU5ErkJggg==\" width=\"170\" alt=\"image\" />");
}


-(void) testListWithoutClosingTags
{
    NSString* test = @"<ol><li>1<li>2<li>3</li></ol>";
    NSString* correct = @"<ol><li>1</li><li>2</li><li>3</li></ol>";
    
    NSString* result = [purifier purify:test];
    
    XCTAssertEqualObjects(result, correct);
}


-(void) testorrick
{
    NSError *error = nil;
    NSString* result = [NSString stringWithContentsOfURL:[BUNDLE URLForResource:@"orrickTest" withExtension:@"html"] encoding:NSUTF8StringEncoding error:&error];
    
    NSString* correct = [NSString stringWithContentsOfURL:[BUNDLE URLForResource:@"orrickClean" withExtension:@"html"] encoding:NSUTF8StringEncoding error:&error];
    
    result = [purifier purify:result];
    
    XCTAssertEqualObjects(result, correct);

}


-(void) testImageWidth
{
    NSString* result = @"<img src=\"https://gallery.mailchimp.com/f.png\" style=\"width: 75%;height: auto !important;\" width=\"75%\">";
    NSString* correct = @"<img src=\"https://gallery.mailchimp.com/f.png\" style=\"width:75%;height:auto;\" alt=\"f.png\" />";
    
    result = [purifier purify:result];
    XCTAssertEqualObjects(result, correct);
}

-(void) testTrackingPixelRemoval
{
    NSString* html = @"<img src=\"http://nextdraft.us2.list-manage.com/track/open.php?u=02783e87fee61c1a534a9d&id=3D2b6db345cb&e=0a04e4c145\" height=\"1\" width=\"1\">";
    
    NSString* exchangedTracker = @"<img src=\"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAIAAACQd1PeAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAB3RJTUUH4AIGDTonDUBF3wAAAB1pVFh0Q29tbWVudAAAAAAAQ3JlYXRlZCB3aXRoIEdJTVBkLmUHAAAADElEQVQI12NQi+gHAAG1AQ6Ex5VQAAAAAElFTkSuQmCC\" height=\"1\" width=\"1\" alt=\"open.php?u=02783e87fee61c1a534a9d&amp;id=3D2\" id=\"MynigmaTrackingPixelReplacement4711\" />";
    
    // activate Tracking config (has currently effect)
    // [super.config setString:@"Core.RemoveTrackingPixel" object:@(YES)];
    HTMLPurifier* localPurifier = [HTMLPurifier new];

    NSString* result = [localPurifier purify:html];
    XCTAssertEqualObjects(result, exchangedTracker);
}

-(void) testOutlookHTML1
{
    NSString* html = @"<p class=MsoNormal><span lang=DE>Was Freitagabend abseits der Tagesordnung noch geschah&#8230;<o:p></o:p></span></p>";
    NSString* correct = @"<p class=\"MsoNormal\"><span lang=\"de\" xml:lang=\"de\">Was Freitagabend abseits der Tagesordnung noch geschah…</span></p><p></p>";
    
    NSString* result = [purifier purify:html];
    
    XCTAssertEqualObjects(result, correct);
}

-(void) testOutlookHTML2
{
    NSString* html = @"<p class=MsoListParagraph style='text-indent:-18.0pt;mso-list:l0 level1 lfo1'><![if !supportLists]><span lang=DE style='font-family:Wingdings'><span style='mso-list:Ignore'>§<span style='font:7.0pt \"Times New Roman\"'>&nbsp; </span></span></span><![endif]><span lang=DE>Text<o:p></o:p></span></p>";

    NSString* correct = @"<p class=\"MsoListParagraph\" style=\"text-indent:-18.0pt;\"><span lang=\"de\" style=\"font-family:Wingdings;\" xml:lang=\"de\"><span>§<span style=\"font:7.0pt 'times new roman';\">  </span></span></span><span lang=\"de\" xml:lang=\"de\">Text</span></p><p></p>";
    NSString* result = [purifier purify:html];
    
    XCTAssertEqualObjects(result, correct);
}



// Setting the config does not work

//-(void) testTrackingPixelIgnore
//{
//
//    NSString* html = @"<img src=\"http://nextdraft.us2.list-manage.com/track/open.php?u=02783e87fee61c1a534a9d&id=3D2b6db345cb&e=0a04e4c145\" height=\"1\" width=\"1\">";
//
//    NSString* filteredTrackingEnabled = @"<img src=\"http://nextdraft.us2.list-manage.com/track/open.php?u=02783e87fee61c1a534a9d&amp;id=3D2b6db345cb&amp;e=0a04e4c145\" height=\"1\" width=\"1\" alt=\"open.php?u=02783e87fee61c1a534a9d&amp;id=3D2\" />";
//
//    [super.config setString:@"Core.RemoveTrackingPixel" object:@(NO)];
//    HTMLPurifier* localPurifier = [[HTMLPurifier alloc] initWithConfig:super.config];
//    
//    NSString* result = [localPurifier purify:html];
//    XCTAssertEqualObjects(result, filteredTrackingEnabled);
//}


/*
- (void)testMakeAbsolute
{
    config set('URI.Base', 'http://example.com/bar/baz.php');
    $this->config->set('URI.MakeAbsolute', true);
    $this->assertPurification(
                              '<a href="foo.txt">Foobar</a>',
                              '<a href="http://example.com/bar/foo.txt">Foobar</a>'
                              );
}

- (void)testDisableResources()
{
    $this->config->set('URI.DisableResources', true);
    $this->assertPurification('<img src="foo.jpg" />', '');
}

- (void)test_addFilter_deprecated()
{
    $this->expectError('HTMLPurifier->addFilter() is deprecated, use configuration directives in the Filter namespace or Filter.Custom');
    generate_mock_once('HTMLPurifier_Filter');
    $this->purifier->addFilter($mock = new HTMLPurifier_FilterMock());
    $mock->expectOnce('preFilter');
    $mock->expectOnce('postFilter');
    $this->purifier->purify('foo');
}*/


@end
