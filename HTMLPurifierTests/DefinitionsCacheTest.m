//
//  DefinitionsCacheTest.m
//  HTMLPurifier
//
//  Created by Roman Priebe on 07/02/2016.
//  Copyright © 2016 Mynigma. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "HTMLPurifier_Harness.h"
#import "HTMLPurifier_CSSDefinition.h"
#import "HTMLPurifier_HTMLDefinition.h"




@interface DefinitionsCacheTest : HTMLPurifier_Harness

@end

@implementation DefinitionsCacheTest


- (void)testCSSDefinitionSerialisation
{
    HTMLPurifier_CSSDefinition* CSSDefinition = [HTMLPurifier_CSSDefinition new];
    [CSSDefinition setup:self.config];
    
    NSMutableData* serialisedDefinition = [NSMutableData new];
    NSKeyedArchiver* keyedArchiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:serialisedDefinition];
    
    [keyedArchiver encodeObject:CSSDefinition forKey:@"CSS"];
    [keyedArchiver finishEncoding];
    
    NSKeyedUnarchiver* keyedUnarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:serialisedDefinition];
    
    HTMLPurifier_CSSDefinition* deserialisedCSSDefinition = [keyedUnarchiver decodeObjectForKey:@"CSS"];
    [keyedUnarchiver finishDecoding];
    
    for(NSString* key in CSSDefinition.info.allKeys)
    {
        NSObject* expectedObject = CSSDefinition.info[key];
        NSObject* actualObject = deserialisedCSSDefinition.info[key];
        XCTAssertEqualObjects(expectedObject, actualObject, @"\n\nKey: %@\n\n", key);
    }
    
    
    //NSError* error = nil;
    
    //[serialisedDefinition writeToURL:url atomically:YES];
    
    XCTAssertEqualObjects(CSSDefinition, deserialisedCSSDefinition);
}

- (void)testHTMLDefinitionSerialisation
{
    HTMLPurifier_HTMLDefinition* HTMLDefinition = [HTMLPurifier_HTMLDefinition new];
    [HTMLDefinition doSetup:self.config];
    
    NSMutableData* serialisedDefinition = [NSMutableData new];
    NSKeyedArchiver* keyedArchiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:serialisedDefinition];
    
    [keyedArchiver encodeObject:HTMLDefinition forKey:@"HTML"];
    [keyedArchiver finishEncoding];
    
    NSKeyedUnarchiver* keyedUnarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:serialisedDefinition];
    
    HTMLPurifier_HTMLDefinition* deserialisedHTMLDefinition = [keyedUnarchiver decodeObjectForKey:@"HTML"];
    [keyedUnarchiver finishDecoding];
    
    for(NSString* key in HTMLDefinition.info.allKeys)
    {
        NSObject* expectedObject = HTMLDefinition.info[key];
        NSObject* actualObject = deserialisedHTMLDefinition.info[key];
        XCTAssertEqualObjects(expectedObject, actualObject, @"\n\nKey: %@\n\n", key);
    }
    
    
    //NSError* error = nil;
    
//    NSURL* url = [NSURL URLWithString:@"file:///Users/romanpriebe/Desktop/HTMLDefinition.data"];
//
//    [serialisedDefinition writeToURL:url atomically:YES];
    
    XCTAssertEqualObjects(HTMLDefinition, deserialisedHTMLDefinition);
}

- (void)testCSSGenerationPerformance
{
    [self measureBlock:^{
        for(int i=0;i<100;i++)
        {
        HTMLPurifier_CSSDefinition* CSSDefinition = [HTMLPurifier_CSSDefinition new];
        [CSSDefinition doSetup:self.config];
        }
    }];
}

- (void)testCSSSerialisationExample
{
    [self measureBlock:^{
       
        for(int i=0;i<100;i++)
        {
        NSURL* url = [[NSBundle bundleForClass:[self class]] URLForResource:@"CSSDefinition" withExtension:@"data"];
        NSData* loadedData = [NSData dataWithContentsOfURL:url];
       
        NSKeyedUnarchiver* keyedUnarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:loadedData];
        
        [keyedUnarchiver decodeObjectForKey:@"CSS"];
        [keyedUnarchiver finishDecoding];
        }
    }];
}








- (void)testHTMLGenerationPerformance
{
    [self measureBlock:^{
        for(int i=0;i<100;i++)
        {
            HTMLPurifier_HTMLDefinition* HTMLDefinition = [HTMLPurifier_HTMLDefinition new];
            [HTMLDefinition doSetup:self.config];
        }
    }];
}

- (void)testHTMLSerialisationExample
{
    [self measureBlock:^{
        
        for(int i=0;i<100;i++)
        {
            NSURL* url = [[NSBundle bundleForClass:[self class]] URLForResource:@"HTMLDefinition" withExtension:@"data"];
            NSData* loadedData = [NSData dataWithContentsOfURL:url];
            
            NSKeyedUnarchiver* keyedUnarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:loadedData];
            
            [keyedUnarchiver decodeObjectForKey:@"HTML"];
            [keyedUnarchiver finishDecoding];
        }
    }];
}




@end
