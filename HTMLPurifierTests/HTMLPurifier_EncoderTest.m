//
//   HTMLPurifier_EncoderTest.m
//   HTMLPurifier
//
//  Created by Roman Priebe on 19.01.14.


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
}

- (void)testNullByte
{
    [self assertCleanUTF8:@"null byte: \0" expect:@"null byte: "];
}

- (void)testLowBytes
{
    [self assertCleanUTF8:@"\1\2\3\4\5\6\7" expect:@""];
}

- (void)testMore
{
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

- (void) disabled_test_convertToUTF8_spuriousEncoding
{
    [super.config setString:@"Core.Encoding" object:@(-99)]; //invalid encoding
    XCTAssertEqualObjects([HTMLPurifier_Encoder convertToUTF8:@"\xF6" config:super.config context:super.context], @"");
}


- (void) d_test_convertToUTF8_iso8859_1
{
    [super.config setString:@"Core.Encoding" object:@(NSISOLatin1StringEncoding)];
    int charValue = 0xF6;
    NSData* inputData = [NSData dataWithBytes:&charValue length:1];
    NSString* inputString = [[NSString alloc] initWithData:inputData encoding:NSISOLatin1StringEncoding];
    NSString* result = [HTMLPurifier_Encoder convertToUTF8:inputString config:super.config context:super.context];
    NSString* expect = @"\xC3\xB6";
    XCTAssertEqualObjects(result, expect);
    //NSLOG"r:<%@> <%@>", [result stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@""]], [expect stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@""]]);
}

- (NSString*) getZhongWen
{
    char zhongWen[6] = { 0xE4, 0xB8, 0xAD, 0xE6, 0x96, 0x87 };
    NSMutableData* zhongWenData = [[NSMutableData alloc] initWithBytes:&zhongWen length:6];
    [zhongWenData appendData:[@" (Chinese)" dataUsingEncoding:NSUTF8StringEncoding]];
    NSString* utf8ZhongWhen = [[NSString alloc] initWithData:zhongWenData encoding:NSUTF8StringEncoding];
    return utf8ZhongWhen;
}

- (void) test_convertFromUTF8_utf8
{
    // UTF-8 means that we don't touch it
    XCTAssertEqualObjects([HTMLPurifier_Encoder convertFromUTF8:@"\xC3\xB6" config:super.config context:super.context], @"\xC3\xB6");
}



- (void) d_test_convertFromUTF8_iso8859_1
{
    [super.config setString:@"Core.Encoding" object:@(NSISOLatin1StringEncoding)];
    XCTAssertEqualObjects([HTMLPurifier_Encoder convertFromUTF8:@"\xC3\xB6" config:super.config context:super.context], @"\xF6");
}


- (void) disabled_test_convertFromUTF8_withProtection
{
    // Preserve the characters!
    [super.config setString:@"Core.Encoding" object:@(NSISOLatin1StringEncoding)];
    [super.config setString:@"Core.EscapeNonASCIICharacters" object:@YES];
    NSString* utf8ZhongWhen = [self getZhongWen];
    XCTAssertEqualObjects([HTMLPurifier_Encoder convertFromUTF8:utf8ZhongWhen  config:super.config context:super.context], @"&#20013;&#25991; (Chinese)");
}

- (void) disabled_test_convertFromUTF8_withProtectionButUtf8
{
    // Preserve the characters!
    [super.config setString:@"Core.EscapeNonASCIICharacters" object:@YES];

    XCTAssertEqualObjects([HTMLPurifier_Encoder convertFromUTF8:[self getZhongWen] config:super.config context:super.context], @"&#20013;&#25991; (Chinese)");
}

- (void) test_convertToASCIIDumbLossless
{
    char inputCData[2] = { 0xC3, 0x9E };
    NSMutableData* inputData = [NSMutableData dataWithBytes:inputCData length:2];
    [inputData appendData:[@"orn" dataUsingEncoding:NSUTF8StringEncoding]];
    NSData* resultData = [HTMLPurifier_Encoder convertToASCIIDumbLossless:inputData];
    NSString* resultString = [[NSString alloc] initWithData:resultData encoding:NSUTF8StringEncoding];
    // Uppercase thorn letter
    XCTAssertEqualObjects(resultString, @"&#222;orn");

    NSString* testString = @"an";
    NSData* testBytes = [testString dataUsingEncoding:NSUTF8StringEncoding];
    resultData = [HTMLPurifier_Encoder convertToASCIIDumbLossless:testBytes];
    resultString = [[NSString alloc] initWithData:resultData encoding:NSUTF8StringEncoding];
    XCTAssertEqualObjects(resultString, @"an");

    char testCData[4] = { 0xF3, 0xA0, 0x80, 0xA0 };
    testBytes = [NSData dataWithBytes:testCData length:4];
    resultData = [HTMLPurifier_Encoder convertToASCIIDumbLossless:testBytes];
    resultString = [[NSString alloc] initWithData:resultData encoding:NSUTF8StringEncoding];
    // test up to four bytes
     XCTAssertEqualObjects(resultString, @"&#917536;");
}


- (void) disabled_testShiftJIS
{
    [super.config setString:@"Core.Encoding" object:@(NSShiftJISStringEncoding)];
    // This actually looks like a Yen, but we're going to treat it differently
    XCTAssertEqualObjects([HTMLPurifier_Encoder convertFromUTF8:@"\\~" config:super.config context:super.context], @"\\~"
                           );
    XCTAssertEqualObjects([HTMLPurifier_Encoder convertToUTF8:@"\\~" config:super.config context:super.context], @"\\~"
                          );
}

@end
