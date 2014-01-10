//
//  HTMLPurifier_Context.h
//  HTMLPurifier
//
//  Created by Lukas Neumann on 10.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HTMLPurifier_Context : NSObject
{
    NSMutableDictionary* _storage;
}

- (void)registerName:(NSString*)name  ref:(NSObject*)ref;
- (NSObject*)getName:(NSString*)name;
- (NSObject*)getName:(NSString*)name ignoreError:(BOOL)ignoreError;
- (BOOL)existsName:(NSString*)name;
- (void)loadArrayContextArray:(NSDictionary*)contextArray;

@end
