//
//  HTMLPurifier_URIHarness.h
//  HTMLPurifier
//
//  Created by Lukas Neumann on 20.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_Harness.h"

@class HTMLPurifier_URI;

@interface HTMLPurifier_URIHarness : HTMLPurifier_Harness

@property  HTMLPurifier_Config* config;
@property  HTMLPurifier_Context* context;

-(HTMLPurifier_URI*) createURI:(NSString*)uri;

-(void) prepareURI:(NSObject**)uri expect:(NSObject**)expect_uri;

@end
