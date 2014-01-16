//
//  HTMLPurifier_ConfigSchema.h
//  HTMLPurifier
//
//  Created by Roman Priebe on 13.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HTMLPurifier_ConfigSchema : NSObject

@property NSMutableDictionary* defaults;

@property NSDictionary* defaultPList;

@property NSMutableDictionary* info;


+ (HTMLPurifier_ConfigSchema*)singleton;


@end
