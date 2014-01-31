//
//  HTMLPurifier_AttrDef_LangTest.m
//  HTMLPurifier
//
//  Created by Lukas Neumann on 22.01.14.


#import <XCTest/XCTest.h>
#import "HTMLPurifier_AttrDefHarness.h"
#import "HTMLPurifier_AttrDef_Lang.h"

@interface HTMLPurifier_AttrDef_LangTest : HTMLPurifier_AttrDefHarness
{
    HTMLPurifier_AttrDef_Lang* def;
}
@end

@implementation HTMLPurifier_AttrDef_LangTest

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

- (void) assertDef:(NSString*)string expect:(NSObject*)expect
{
    // expect can be a string or bool
    if ([expect isEqual:@YES])
        expect = string;
    
    NSString* result = [def validateWithString:string config:[super config] context:[super context]];
    XCTAssertEqualObjects(expect, result, @"");
}

-(void) test
{
    def = [HTMLPurifier_AttrDef_Lang new];
    
    // basic good uses
    [self assertDef:@"en" expect:@YES];
    [self assertDef:@"en-us" expect:@YES];
    
    [self assertDef:@" en " expect:@"en"]; // trim
    [self assertDef:@"EN" expect:@"en"]; // case insensitivity
    
    // (thanks Eugen Pankratz for noticing the typos!)
    [self assertDef:@"En-Us-Edison" expect:@"en-us-edison"]; // complex ci
    
    [self assertDef:@"fr en" expect:nil]; // multiple languages
    [self assertDef:@"%" expect:nil]; // bad character
    
    // test overlong language according to syntax
    [self assertDef:@"thisistoolongsoitgetscut" expect:nil];
    
    // primary subtag rules
    // I'm somewhat hesitant to allow x and i as primary language codes,
    // because they usually are never used in real life. However,
    // theoretically speaking, having them alone is permissable, so
    // I'll be lenient. No XML parser is going to complain anyway.
    [self assertDef:@"x" expect:@YES];
    [self assertDef:@"i" expect:@YES];
    // real world use-cases
    [self assertDef:@"x-klingon" expect:@YES];
    [self assertDef:@"i-mingo" expect:@YES];
    // because the RFC only defines two and three letter primary codes,
    // anything with a length of four or greater is invalid, despite
    // the syntax stipulation of 1 to 8 characters. Because the RFC
    // specifically states that this reservation is in order to allow
    // for future versions to expand, the adoption of a new RFC will
    // require these test cases to be rewritten, even if backwards-
    // compatibility is largely retained (i.e. this is not forwards
    // compatible)
    [self assertDef:@"four" expect:nil];
    // for similar reasons, disallow any other one character language
    [self assertDef:@"f" expect:nil];
    
    // second subtag rules
    // one letter subtags prohibited until revision. This is, however,
    // less volatile than the restrictions on the primary subtags.
    // Also note that this test-case tests fix-behavior: chop
    // off subtags until you get a valid language code.
    [self assertDef:@"en-a" expect:@"en"];
    // however, x is a reserved single-letter subtag that is allowed
    [self assertDef:@"en-x" expect:@"en-x"];
    // 2-8 chars are permitted, but have special meaning that cannot
    // be checked without maintaining country code lookup tables (for
    // two characters) or special registration tables (for all above).
    [self assertDef:@"en-uk" expect:@YES];
    
    // further subtag rules: only syntactic constraints
    [self assertDef:@"en-us-edison" expect:@YES];
    [self assertDef:@"en-us-toolonghaha" expect:@"en-us"];
    [self assertDef:@"en-us-a-silly-long-one" expect:@YES];
    
    // rfc 3066 stipulates that if a three letter and a two letter code
    // are available, the two letter one MUST be used. Without a language
    // code lookup table, we cannot implement this functionality.
    
    // although the HTML protocol, technically speaking, allows you to
    // omit language tags, this implicitly means that the parent element's
    // language is the one applicable, which, in some cases, is incorrect.
    // Thus, we allow und, only slightly defying the RFC's SHOULD NOT
    // designation.
    [self assertDef:@"und" expect:@YES];
    
    // because attributes only allow one language, mul is allowed, complying
    // with the RFC's SHOULD NOT designation.
    [self assertDef:@"mul" expect:@YES];
    
}


@end
