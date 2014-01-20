//
//  HTMLPurifier_Token_Tag.m
//  HTMLPurifier
//
//  Created by Roman Priebe on 12.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_Token_Tag.h"
#import "HTMLPurifier_Node_Element.h"

@implementation HTMLPurifier_Token_Tag



    /**
     * Non-overloaded constructor, which lower-cases passed tag name.
     *
     * @param string $name String name.
     * @param array $attr Associative array of attributes.
     * @param int $line
     * @param int $col
     * @param array $armor
     */
- (id)initWithName:(NSString*)n attr:(NSDictionary*)passed_att sortedAttrKeys:(NSArray*)sortedAttrKeys line:(NSNumber*)l col:(NSNumber*)c armor:(NSMutableDictionary*)arm
{
    self = [super init];
    if (self) {
        self.name = [n lowercaseString];
        NSMutableDictionary* att = [passed_att mutableCopy];
        NSMutableArray* newSortedAttrKeys = [NSMutableArray new];
        for(NSString* key in sortedAttrKeys)
        {
            NSString* newKey = [key lowercaseString];
            [newSortedAttrKeys addObject:newKey];
            if(![att objectForKey:newKey])
            {
                [att setObject:[att objectForKey:key] forKey:newKey];
            }
            if(![newKey isEqual:key])
            {
                [att removeObjectForKey:key];
            }
        }
        self.attr = att;
        self.sortedAttrKeys = newSortedAttrKeys;

        self.isTag = YES;
        self.line = l;
        self.col = c;
        self.armor = arm;
    }
    return self;
}

- (id)initWithName:(NSString*)n attr:(NSDictionary*)att sortedAttrKeys:(NSArray *)sortedAttrKeys
{
    return [self initWithName:n attr:att sortedAttrKeys:sortedAttrKeys line:nil col:nil armor:[NSMutableDictionary new]];
}

- (id)initWithName:(NSString*)n
{
    return [self initWithName:n attr:[NSDictionary new] sortedAttrKeys:@[] line:nil col:nil armor:[NSMutableDictionary new]];
}


- (HTMLPurifier_Node_Element*)toNode
    {
        return [[HTMLPurifier_Node_Element alloc] initWithName:self.name attr:self.attr sortedAttrKeys:self.sortedAttrKeys line:self.line col:self.col armor:self.armor];
    }




@end
