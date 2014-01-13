//
//  HTMLPurifier_Doctype.m
//  HTMLPurifier
//
//  Created by Roman Priebe on 14.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_Doctype.h"

@implementation HTMLPurifier_Doctype

- (id)initWithName:(NSString*)name xml:(BOOL)xml modules:(NSMutableArray*)modules tidyModules:(NSMutableDictionary*)tidyModules aliases:(NSMutableDictionary*)aliases dtdPublic:(NSString*)dtdPublic dtdSystem:(NSString*)dtdSystem
{
    self = [super init];
    if (self) {
        _name = name;
        _xml = xml;
        _modules = modules;
        _tidyModules = tidyModules;
        _aliases = aliases;
        _dtdPublic = dtdPublic;
        _dtdSystem = dtdSystem;
    }
    return self;
}

- (id)init
{
    return [self initWithName:nil xml:YES modules:[NSMutableArray new] tidyModules:[NSMutableDictionary new] aliases:[NSMutableDictionary new] dtdPublic:nil dtdSystem:nil];
}

@end
