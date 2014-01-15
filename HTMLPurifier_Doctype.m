//
//  HTMLPurifier_Doctype.m
//  HTMLPurifier
//
//  Created by Roman Priebe on 15.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_Doctype.h"

@implementation HTMLPurifier_Doctype

@synthesize name;
@synthesize xml;
@synthesize modules;
@synthesize tidyModules;
@synthesize aliases;
@synthesize dtdPublic;
@synthesize dtdSystem;

- (id)initWithName:(NSString*)newName xml:(BOOL)newXML modules:(NSMutableDictionary*)newModules tidyModules:(NSMutableDictionary*)newTidyModules aliases:(NSMutableDictionary*)newAliases dtdPublic:(NSString*)newDtd_public dtdSystem:(NSString*)newDtd_system
{
    self = [super init];
    if (self) {
        name = newName;
        xml = newXML;
        modules = newModules;
        tidyModules = newTidyModules;
        aliases = newAliases;
        dtdPublic = newDtd_public;
        dtdSystem = newDtd_system;
    }
    return self;
}

- (id)init
{
    return [self initWithName:nil xml:YES modules:[NSMutableDictionary new] tidyModules:[NSMutableDictionary new] aliases:[NSMutableDictionary new] dtdPublic:nil dtdSystem:nil];
}


@end
