//
//  HTMLPurifieriOSTests.m
//  HTMLPurifieriOSTests
//
//  Created by Roman Priebe on 03.04.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "HTMLPurifier.h"

@interface HTMLPurifieriOSTests : XCTestCase

@end

@implementation HTMLPurifieriOSTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testImgExample
{
    NSString* testHTML = @"<img src=\"http://www.google.com\" width=\"1\" height=\"1\" border=\"0\" alt=\"Alt\" />";

    NSString* cleanedHTML = [HTMLPurifier cleanHTML:testHTML];

    NSLog(@"Output: %@", cleanedHTML);

    XCTAssertEqualObjects(testHTML, cleanedHTML);
}

- (void)testAnotherExample
{
    NSString* testHTML = @"<!DOCTYPE html><html xmlns=\"http://www.w3.org/1999/xhtml\"><head><meta name=\"generator\" content=\"HTML Tidy for HTML5 (experimental) for Mac OS X https://github.com/w3c/tidy-html5/tree/c63cc39\" /><meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" /><title>Magazin-kw2114-DE_FM</title></head><body bgcolor=\"#C7D5E7\" link=\"#2269C3\" vlink=\"#2269C3\" alink=\"#2269C3\" text=\"#000000\" topmargin=\"0\" leftmargin=\"20\" marginheight=\"0\" marginwidth=\"0\"><img src=\"https://mailings.gmx.net/action/view/11231/2o2gy1vt\" border=\"0\" width=\"1\" height=\"1\" alt=\"\" /><table width=\"100%\" border=\"0\" cellspacing=\"0\" cellpadding=\"0\"><tr><td width=\"620\"><!-- Header --><table width=\"620\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\"><tr><td width=\"1\" bgcolor=\"#C4D3E6\"><img src=\"https://img.ui-portal.de/p.gif\" alt=\"\" width=\"1\" height=\"1\" border=\"0\" /></td><td width=\"1\" bgcolor=\"#BFCEE1\"><img src=\"https://img.ui-portal.de/p.gif\" alt=\"\" width=\"1\" height=\"1\" border=\"0\" /></td><td width=\"1\" bgcolor=\"#B9C8DB\"><img src=\"https://img.ui-portal.de/p.gif\" alt=\"\" width=\"1\" height=\"1\" border=\"0\" /></td><td width=\"1\" bgcolor=\"#B2BFCF\"><img src=\"https://img.ui-portal.de/p.gif\" alt=\"\" width=\"1\" height=\"1\" border=\"0\" /></td></tr></table></body></html>";

    NSString* cleanedHTML = [HTMLPurifier cleanHTML:testHTML];

    NSLog(@"Output: %@", cleanedHTML);
}

@end
