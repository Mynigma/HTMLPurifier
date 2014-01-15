//
//  HTMLPurifier_Generator.h
//  HTMLPurifier
//
//  Created by Lukas Neumann on 10.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HTMLPurifier_Context, HTMLPurifier_Config;

@interface HTMLPurifier_Generator : NSObject

- (id)initWithConfig:(HTMLPurifier_Config*)config context:(HTMLPurifier_Context*)context;

@end
