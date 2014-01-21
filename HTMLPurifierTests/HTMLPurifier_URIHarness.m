//
//  HTMLPurifier_URIHarness.m
//  HTMLPurifier
//
//  Created by Lukas Neumann on 20.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_URIHarness.h"
#import "HTMLPurifier_URIParser.h"
#import "HTMLPurifier_URI.h"
#import "HTMLPurifier_Config.h"
#import "HTMLPurifier_Context.h"

@implementation HTMLPurifier_URIHarness

@synthesize config;
@synthesize context;

- (void)setUp
{
    [super setUp];
    config = [HTMLPurifier_Config createDefault];
    context = [HTMLPurifier_Context new];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)prepareURI:(NSObject**)uri expect:(NSObject**)expect_uri
{
    HTMLPurifier_URIParser* parser = [HTMLPurifier_URIParser new];
    if ([*expect_uri isEqual:@YES])
        *expect_uri = *uri;
    *uri = [parser parse:(NSString*)*uri];

    if (![*expect_uri isEqual:@NO])
        *expect_uri = [parser parse:(NSString*)*expect_uri];
}

/**
 * Generates a URI object from the corresponding string
 */
-(HTMLPurifier_URI*) createURI:(NSString*)uri
{
    HTMLPurifier_URIParser* parser = [HTMLPurifier_URIParser new];
    return [parser parse:uri];
}


@end
