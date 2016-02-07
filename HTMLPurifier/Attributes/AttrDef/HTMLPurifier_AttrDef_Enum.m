//
//   HTMLPurifier_AttrDef_Enum.m
//   HTMLPurifier
//
//  Created by Roman Priebe on 10.01.14.


#import "HTMLPurifier_AttrDef_Enum.h"
#import "BasicPHP.h"

@implementation HTMLPurifier_AttrDef_Enum

- (id)init
{
    return [self initWithValidValues:nil caseSensitive:@NO];
}

- (id)initWithValidValues:(NSArray*)array
{
    return [self initWithValidValues:array caseSensitive:@NO];
}


- (id)initWithValidValues:(NSArray*)array caseSensitive:(NSNumber*)newCaseSensitive
{
    self = [super init];
    if (self) {
        _validValues = [array mutableCopy];
        _caseSensitive = newCaseSensitive;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder*)coder
{
    self = [super init];
    if (self) {
        _validValues = [coder decodeObjectForKey:@"validValues"];
        _caseSensitive = [coder decodeObjectForKey:@"caseSensitive"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder*)encoder
{
    [encoder encodeObject:_validValues forKey:@"validValues"];
    [encoder encodeObject:_caseSensitive forKey:@"caseSensitive"];
}


- (BOOL)isEqual:(HTMLPurifier_AttrDef_Enum*)other
{
    if (other == self)
        return YES;
    
    if (![super isEqual:other])
        return NO;
    
    if(![other isKindOfClass:[HTMLPurifier_AttrDef_Enum class]])
        return NO;
    
    BOOL validValuesEqual = (!self.validValues && ![other validValues]) || [self.validValues isEqual:[other validValues]];
    BOOL caseSensitiveEqual = (!self.caseSensitive && ![other caseSensitive]) || [self.caseSensitive isEqual:[other caseSensitive]];
    
    return validValuesEqual && caseSensitiveEqual;
}

- (NSUInteger)hash
{
    return [_validValues hash] ^ [_caseSensitive hash] ^ [super hash];
}














- (NSString*)validateWithString:(NSString*)string config:(HTMLPurifier_Config*)config context:(HTMLPurifier_Context *)context
{
    NSString* newString = trim(string);
    if(!self.caseSensitive.boolValue)
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
    return [[HTMLPurifier_AttrDef_Enum alloc] initWithValidValues:values caseSensitive:@(sensitive)];
}

- (id)copyWithZone:(NSZone *)zone
{
    HTMLPurifier_AttrDef_Enum* newAttrDef = [super copyWithZone:zone];

    [newAttrDef setValidValues:self.validValues];
    [newAttrDef setCaseSensitive:self.caseSensitive];

    return newAttrDef;
}


@end
