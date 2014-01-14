//
//  HTMLPurifier_URI.h
//  HTMLPurifier
//
//  Created by Lukas Neumann on 13.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HTMLPurifier_URI : NSObject

/**
 * @type string
 */
@property NSString* scheme;

/**
 * @type string
 */
@property NSString* userinfo;

/**
 * @type string
 */
@property NSString* host;

/**
 * @type int
 */
@property NSNumber* port;

/**
 * @type string
 */
@property NSString* path;

/**
 * @type string
 */
@property NSString* query;

/**
 * @type string
 */
@property NSString* fragment;



@end
