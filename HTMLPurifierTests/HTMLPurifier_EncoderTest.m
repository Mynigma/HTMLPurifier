//
//  HTMLPurifier_EncoderTest.m
//  HTMLPurifier
//
//  Created by Roman Priebe on 19.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "HTMLPurifier_Harness.h"
#import "HTMLPurifier_EntityLookup.h"
#import "HTMLPurifier_Encoder.h"
#import "HTMLPurifier_Config.h"
#import "HTMLPurifier_Context.h"


@interface HTMLPurifier_EncoderTest : HTMLPurifier_Harness
{
    HTMLPurifier_EntityLookup* entityLookup;
}

@end

@implementation HTMLPurifier_EncoderTest

- (void)setUp
{
    entityLookup = [HTMLPurifier_EntityLookup instance];
    [super createCommon];
    [super setUp];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


- (void)assertCleanUTF8:(NSString*)string
{
    [self assertCleanUTF8:string expect:nil];
}

- (void)assertCleanUTF8:(NSString*)string expect:(NSString*)expect
{
    if (expect == nil)
        expect = string;
    NSString* cleaned = [HTMLPurifier_Encoder cleanUTF8:string];

    XCTAssertEqualObjects(cleaned, expect);
}

- (void) test_cleanUTF8
{
    [self assertCleanUTF8:@"Normal string."];
    [self assertCleanUTF8:@"Test\tAllowed\nControl\rCharacters"];
    [self assertCleanUTF8:@"null byte: \0" expect:@"null byte: "];
    [self assertCleanUTF8:@"\1\2\3\4\5\6\7" expect:@""];
    [self assertCleanUTF8:@"\x7F" expect:@""]; // one byte invalid SGML char
    [self assertCleanUTF8:@"\xC2\x80" expect:@""]; // two byte invalid SGML
    [self assertCleanUTF8:@"\xF3\xBF\xBF\xBF"]; // valid four byte
    [self assertCleanUTF8:@"\xDF\xFF" expect:@""]; // malformed UTF8
    // invalid codepoints
    [self assertCleanUTF8:@"\xED\xB0\x80" expect:@""];
}

- (void) test_convertToUTF8_noConvert
{
    // UTF-8 means that we don't touch it
    XCTAssertEqualObjects([HTMLPurifier_Encoder convertToUTF8:@"\xF6" config:super.config context:super.context], @"\xF6");
}

- (void) test_convertToUTF8_spuriousEncoding
{
    [super.config setString:@"Core.Encoding" object:@(-99)]; //invalid encoding
    XCTAssertEqualObjects([HTMLPurifier_Encoder convertToUTF8:@"\xF6" config:super.config context:super.context], @"");
}


- (void) test_convertToUTF8_iso8859_1
{
    [super.config setString:@"Core.Encoding" object:@(NSISOLatin1StringEncoding)];
    XCTAssertEqualObjects([HTMLPurifier_Encoder convertToUTF8:@"\xF6" config:super.config context:super.context], @"\xC3\xB6");
}

- (NSString*) getZhongWen
{
    return @"\xE4\xB8\xAD\xE6\x96\x87 (Chinese)";
}

- (void) test_convertFromUTF8_utf8
{
    // UTF-8 means that we don't touch it
    XCTAssertEqualObjects([HTMLPurifier_Encoder convertFromUTF8:@"\xC3\xB6" config:super.config context:super.context], @"\xC3\xB6");
}



- (void) test_convertFromUTF8_iso8859_1
{
    [super.config setString:@"Core.Encoding" object:@(NSISOLatin1StringEncoding)];
    XCTAssertEqualObjects([HTMLPurifier_Encoder convertFromUTF8:@"\xC3\xB6" config:super.config context:super.context], @"\xF6");
}


- (void) test_convertFromUTF8_withProtection
{
    // Preserve the characters!
    [super.config setString:@"Core.Encoding" object:@(NSISOLatin1StringEncoding)];
    [super.config setString:@"Core.EscapeNonASCIICharacters" object:@YES];
    XCTAssertEqualObjects([HTMLPurifier_Encoder convertFromUTF8:[self getZhongWen] config:super.config context:super.context], @"&#20013;&#25991; (Chinese)");
}

- (void) test_convertFromUTF8_withProtectionButUtf8
{
    // Preserve the characters!
    [super.config setString:@"Core.EscapeNonASCIICharacters" object:@YES];

    XCTAssertEqualObjects([HTMLPurifier_Encoder convertFromUTF8:[self getZhongWen] config:super.config context:super.context], @"&#20013;&#25991; (Chinese)");
}

- (void) test_convertToASCIIDumbLossless
{
    // Uppercase thorn letter
    XCTAssertEqualObjects([HTMLPurifier_Encoder convertToASCIIDumbLossless:@"\xC3\x9Eorn"], @"&#222;orn");

    XCTAssertEqualObjects([HTMLPurifier_Encoder convertToASCIIDumbLossless:@"an"], @"an");


    // test up to four bytes
     XCTAssertEqualObjects([HTMLPurifier_Encoder convertToASCIIDumbLossless:@"\xF3\xA0\x80\xA0"], @"&#917536;");
}


- (void) testShiftJIS
{
    [super.config setString:@"Core.Encoding" object:@(NSShiftJISStringEncoding)];
    // This actually looks like a Yen, but we're going to treat it differently
    XCTAssertEqualObjects([HTMLPurifier_Encoder convertFromUTF8:@"\\~" config:super.config context:super.context], @"\\~"
                           );
    XCTAssertEqualObjects([HTMLPurifier_Encoder convertToUTF8:@"\\~" config:super.config context:super.context], @"\\~"
                          );
}

@end
