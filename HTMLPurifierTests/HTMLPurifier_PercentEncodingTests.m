//
//  HTMLPurifier_PercentEncodingTests.m
//  HTMLPurifier
//
//  Created by Roman Priebe on 14.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "HTMLPurifier_PercentEncoder.h"
#import "HTMLPurifier_Harness.m"

@interface HTMLPurifier_PercentEncodingTests : HTMLPurifier_Harness
{
    HTMLPurifier_PercentEncoder* PercentEncoder;
    SEL func;
}

@end

@implementation HTMLPurifier_PercentEncodingTests

- (void)setUp
{
    [super setUp];
    PercentEncoder = [HTMLPurifier_PercentEncoder new];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample
{
}

- (void)assertDecode:(NSString*)string
{
    [self assertDecode:string expect:@YES];
}

- (void)assertDecode:(NSString*)string expect:(NSObject*)expect
{
    if([expect isEqual:@YES])
    {
        expect = string;
    }
    [self assertEqual:[PercentEncoder performSelector:func withObject:string] to:expect];
}

- (void)testNormalize
{
        func = @selector(normalize:);

        [self assertDecode:@"Aw.../-$^8"]; // no change
        [self assertDecode:@"%%41%%77%%7E%%2D%%2E%%5F" expect:@"Aw~-._"]; // decode unreserved chars
        [self assertDecode:@"%%3A%%2F%%3F%%23%%5B%%5D%%40%%21%%24%%26%%27%%28%%29%%2A%%2B%%2C%%3B%%3D"]; // preserve reserved chars
        [self assertDecode:@"%%2b" expect:@"%%2B"]; // normalize to uppercase
        [self assertDecode:@"%%2B2B%%3A3A"]; // extra text
        [self assertDecode:@"%%2b2B%%4141' expect:'%%2B2BA41"]; // extra text, with normalization
        [self assertDecode:@"%%" expect:@"%%25"]; // normalize stray percent sign
        [self assertDecode:@"%%5%%25" expect:@"%%255%%25"]; // permaturely terminated encoding
        [self assertDecode:@"%%GJ" expect:@"%%25GJ"]; // invalid hexadecimal chars

        // contested behavior, if this changes, we'll also have to have
        // outbound encoding
        [self assertDecode:@"%%FC"]; // not reserved or unreserved, preserve

    }

- (void) assertEncode:(NSString*)string
{
    [self assertEncode:string expect:@YES preserve:nil];
}

- (void) assertEncode:(NSString*)string expect:(NSObject*)expect
{
    [self assertEncode:string expect:expect preserve:nil];
}

    - (void) assertEncode:(NSString*)string expect:(NSObject*)expect preserve:(NSString*)preserve
    {
        if ([expect isEqual:@YES])
            expect = string;
        HTMLPurifier_PercentEncoder* encoder = [[HTMLPurifier_PercentEncoder alloc] initWithPreservedChars:preserve];
        NSString* result = [encoder encode:string];
        [self assertEqual:result to:expect];
    }

    - (void) test_encode_noChange {
        [self assertEncode:@"abc012-_~."];
    }

    - (void) test_encode_encode {
        [self assertEncode:@">" expect:@"%%3E"];
    }

    - (void) test_encode_preserve {
        [self assertEncode:@"<>" expect:@"<%%3E" preserve:@"<"];
    }

    - (void) test_encode_low {
        [self assertEncode:@"\1" expect:@"%%01"];
    }



@end
