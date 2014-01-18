//
//  HTMLPurifier_DOMNode.h
//  HTMLPurifier
//
//  Created by Roman Priebe on 17.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HTMLPurifier_DOMNode : NSObject

@property NSInteger type;

@property NSString* name;

@property NSString* content;

@property NSDictionary* attr;

@property NSArray* children;

@end
