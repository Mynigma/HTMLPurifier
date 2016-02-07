//
//  HTMLPurifier_PerformanceTest.m
//  HTMLPurifier
//
//  Created by Roman Priebe on 07/02/2016.
//  Copyright © 2016 Mynigma. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "HTMLPurifier.h"





@interface HTMLPurifier_PerformanceTest : XCTestCase

@end

@implementation HTMLPurifier_PerformanceTest



- (void)testSampleMessage1
{
    NSURL* url = [[NSBundle bundleForClass:[self class]] URLForResource:@"SampleMessage1" withExtension:@"txt"];
    NSData* data = [NSData dataWithContentsOfURL:url];
    NSString* HTMLString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    [self measureBlock:^{
        
        HTMLPurifier* purifier = [HTMLPurifier new];
        
        NSString* result = [purifier purify:HTMLString];
        
        XCTAssertNotNil(result);
    }];
}


- (void)testSampleMessage2
{
    NSURL* url = [[NSBundle bundleForClass:[self class]] URLForResource:@"SampleMessage2" withExtension:@"txt"];
    NSData* data = [NSData dataWithContentsOfURL:url];
    NSString* HTMLString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    [self measureBlock:^{
        
        HTMLPurifier* purifier = [HTMLPurifier new];
        
        NSString* result = [purifier purify:HTMLString];
        
        XCTAssertNotNil(result);
    }];
}


- (void)testSampleMessage3
{
    NSURL* url = [[NSBundle bundleForClass:[self class]] URLForResource:@"SampleMessage3" withExtension:@"txt"];
    NSData* data = [NSData dataWithContentsOfURL:url];
    NSString* HTMLString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    [self measureBlock:^{
    
        HTMLPurifier* purifier = [HTMLPurifier new];
        
        NSString* result = [purifier purify:HTMLString];
        
        XCTAssertNotNil(result);
    }];
}

@end
