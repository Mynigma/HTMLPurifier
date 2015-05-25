//
//   HTMLPurifier_Doctype.m
//   HTMLPurifier
//
//  Created by Roman Priebe on 14.01.14.


#import "HTMLPurifier_Doctype.h"

@implementation HTMLPurifier_Doctype

- (id)initWithName:(NSString*)name xml:(BOOL)xml modules:(NSArray*)modules tidyModules:(NSArray*)tidyModules aliases:(NSArray*)aliases dtdPublic:(NSString*)dtdPublic dtdSystem:(NSString*)dtdSystem
{
    self = [super init];
    if (self) {
        _name = name;
        _xml = xml;
        _modules = [modules mutableCopy];
        _tidyModules = [tidyModules mutableCopy];
        _aliases = [aliases mutableCopy];
        _dtdPublic = dtdPublic;
        _dtdSystem = dtdSystem;
    }
    return self;
}

- (id)initWithName:(NSString*)name
{
    return [self initWithName:name xml:YES modules:[NSMutableArray new] tidyModules:[NSMutableArray new] aliases:[NSMutableArray new] dtdPublic:nil dtdSystem:nil];
}


- (id)init
{
    return [self initWithName:nil xml:YES modules:[NSMutableArray new] tidyModules:[NSMutableArray new] aliases:[NSMutableArray new] dtdPublic:nil dtdSystem:nil];
}

- (id)copyWithZone:(NSZone *)zone
{
    HTMLPurifier_Doctype* newDoctype = [[[self class] allocWithZone:zone] init];
    [newDoctype setAliases:self.aliases];
    [newDoctype setDtdPublic:self.dtdPublic];
    [newDoctype setDtdSystem:self.dtdSystem];
    [newDoctype setModules:self.modules];
    [newDoctype setName:self.name];
    [newDoctype setTidyModules:self.tidyModules];
    [newDoctype setXml:self.xml];
    
    return newDoctype;
}

@end
