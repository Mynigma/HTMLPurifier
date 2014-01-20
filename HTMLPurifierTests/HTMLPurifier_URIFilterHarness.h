//
//  HTMLPurifier_URIFilterHarness.h
//  HTMLPurifier
//
//  Created by Lukas Neumann on 20.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_URIHarness.h"

@class HTMLPurifier_URIFilter;

@interface HTMLPurifier_URIFilterHarness : HTMLPurifier_URIHarness;

@property HTMLPurifier_URIFilter* filter;

@end
