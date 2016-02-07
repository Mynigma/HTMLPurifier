//
//  AutoCodingObject.m
//  HTMLPurifier
//
//  Created by Roman Priebe on 07/02/2016.
//  Copyright © 2016 Mynigma. All rights reserved.
//

#import "AutoCodingObject.h"
#import <objc/runtime.h>




@implementation AutoCodingObject

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        
        @autoreleasepool
        {
            unsigned int numberOfProperties = 0;
            objc_property_t* propertyArray = class_copyPropertyList([self class], &numberOfProperties);
            
            for (NSUInteger i = 0; i < numberOfProperties; i++)
            {
                objc_property_t property = propertyArray[i];
                NSString *propertyName = [[NSString alloc] initWithUTF8String:property_getName(property)];
                
                NSObject* value = [coder decodeObjectForKey:propertyName];
                [self setValue:value forKey:propertyName];
            }
            free(propertyArray);
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder*)coder
{
    @autoreleasepool
    {
        unsigned int numberOfProperties = 0;
        objc_property_t* propertyArray = class_copyPropertyList([self class], &numberOfProperties);
        
        for (NSUInteger i = 0; i < numberOfProperties; i++)
        {
            objc_property_t property = propertyArray[i];
            NSString *propertyName = [[NSString alloc] initWithUTF8String:property_getName(property)];
            
            [coder encodeObject:[self valueForKey:propertyName] forKey:propertyName];
        }
        free(propertyArray);
    }
}





- (BOOL)isEqual:(id)other
{
    if (other == self)
        return YES;
    
    //AutoCodingObjects are equal iff the class and all properties match
    if(![[self class] isEqual:[other class]])
        return NO;
    
    @autoreleasepool
    {
        unsigned int numberOfProperties = 0;
        objc_property_t* propertyArray = class_copyPropertyList([self class], &numberOfProperties);
        
        for (NSUInteger i = 0; i < numberOfProperties; i++)
        {
            objc_property_t property = propertyArray[i];
            NSString *propertyName = [[NSString alloc] initWithUTF8String:property_getName(property)];
            
            NSObject* ownObject = [self valueForKey:propertyName];
            NSObject* otherObject = [other valueForKey:propertyName];
            
            if((ownObject || otherObject) && ![ownObject isEqual:otherObject])
            {
                free(propertyArray);
                return NO;
            }
        }
        free(propertyArray);
    }
    
    return YES;
}


/**
 * not hugely efficient, but at least it is guaranteed to match for identical elements
 * could extract some properties, but this implementation is obviously faster
 **/
- (NSUInteger)hash
{
    return [[self class] hash];
}



/**
 *  Simply create another object of the same class and copy all properties
 **/
- (id)copyWithZone:(NSZone *)zone
{
    AutoCodingObject* codingObject = [[[self class] allocWithZone:zone] init];
    
    @autoreleasepool
    {
        unsigned int numberOfProperties = 0;
        objc_property_t* propertyArray = class_copyPropertyList([self class], &numberOfProperties);
        
        for (NSUInteger i = 0; i < numberOfProperties; i++)
        {
            objc_property_t property = propertyArray[i];
            NSString *propertyName = [[NSString alloc] initWithUTF8String:property_getName(property)];
            
            NSObject* value = [self valueForKey:propertyName];
            [self setValue:value forKey:propertyName];
        }
        free(propertyArray);
    }
    
    return codingObject;
}



@end
