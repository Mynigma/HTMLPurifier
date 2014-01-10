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

- (void)registerWithName:(NSString*)name ref:(NSObject*)ref;
- (NSObject*)getWithName:(NSString*)name;
- (NSObject*)getWithName:(NSString*)name ignoreError:(BOOL)ignoreError;
- (BOOL)existsWithName:(NSString*)name;
- (void)loadArrayWithContextArray:(NSDictionary*)contextArray;

@end
