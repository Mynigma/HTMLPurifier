//
//  HTMLPurifier_AttrDef_Enum.m
//  HTMLPurifier
//
//  Created by Roman Priebe on 10.01.14.


#import "HTMLPurifier_AttrDef_Enum.h"
#import "BasicPHP.h"

@implementation HTMLPurifier_AttrDef_Enum

- (id)init
{
    return [self initWithValidValues:nil caseSensitive:NO];
}

- (id)initWithValidValues:(NSArray*)array
{
    return [self initWithValidValues:array caseSensitive:NO];
}


- (id)initWithValidValues:(NSArray*)array caseSensitive:(BOOL)newCaseSensitive
{
    self = [super init];
    if (self) {
        _validValues = [array mutableCopy];
        _caseSensitive = newCaseSensitive;
    }
    return self;
}

- (NSString*)validateWithString:(NSString*)string config:(HTMLPurifier_Config*)config context:(HTMLPurifier_Context *)context
{
    NSString* newString = trim(string);
    if(!self.caseSensitive)
    {
        newString = [newString lowercaseString];
    }
    BOOL result = NO;

    //TO DO: fix
    //validValues is occasionally set to a string
    if([self.validValues isKindOfClass:[NSString class]])
        @throw [NSException exceptionWithName:@"AttrDef_Enum" reason:[NSString stringWithFormat:@"Valid values set to string: %@", self.validValues] userInfo:nil];
    
    if([self.validValues isKindOfClass:[NSArray class]])
        result = [self.validValues containsObject:newString];

    return result?newString:nil;
}

- (HTMLPurifier_AttrDef_Enum*)make:(NSString*)string;
{
    BOOL sensitive;
    if (string.length > 2 && [string characterAtIndex:0] == 's' && [string characterAtIndex:1] == ':') {
        string = substr(string, 2);
        sensitive = YES;
    } else {
        sensitive = NO;
    }
    NSArray* values = explode(@",", string);
    return [[HTMLPurifier_AttrDef_Enum alloc] initWithValidValues:values caseSensitive:sensitive];
}

- (id)copyWithZone:(NSZone *)zone
{
    HTMLPurifier_AttrDef_Enum* newAttrDef = [super copyWithZone:zone];

    [newAttrDef setValidValues:self.validValues];
    [newAttrDef setCaseSensitive:self.caseSensitive];

    return newAttrDef;
}

// For testing
-(BOOL) isEqual:(HTMLPurifier_AttrDef_Enum*)object
{
    if(![object isKindOfClass:[HTMLPurifier_AttrDef_Enum class]])
        return NO;

    return [_validValues isEqual:object.validValues] && (_caseSensitive == object.caseSensitive);
}

-(NSUInteger) hash
{
    return [_validValues hash] + [[NSNumber numberWithBool:_caseSensitive] hash];
}

@end
