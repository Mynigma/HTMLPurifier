//
//  HTMLPurifier_AttrDef_Clone.m
//  HTMLPurifier
//
//  Created by Lukas Neumann on 13.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

/**
 * Dummy AttrDef that mimics another AttrDef, BUT it generates clones
 * with make.
 */

#import "HTMLPurifier_AttrDef_Clone.h"

@implementation HTMLPurifier_AttrDef_Clone

/**
 * What we're cloning.
 * @type HTMLPurifier_AttrDef
 */
@synthesize clone;

/**
 * @param HTMLPurifier_AttrDef $clone
 */
-(id) initWithClone:(HTMLPurifier_AttrDef*)nclone
{
    self = [super init];
    clone = nclone;
    return self;
}

/**
 * @param string $v
 * @param HTMLPurifier_Config $config
 * @param HTMLPurifier_Context $context
 * @return bool|string
 */
-(NSString*) validateWithString:(NSString *)string config:(HTMLPurifier_Config *)config context:(HTMLPurifier_Context *)context
{
    return [clone validateWithString:string config:config context:context];
}

/**
 * @param string $string
 * @return HTMLPurifier_AttrDef
 */
-(HTMLPurifier_AttrDef*) make:(NSString*)string
{
    return [clone copy];
}

- (id)copyWithZone:(NSZone *)zone
{
    HTMLPurifier_AttrDef_Clone* newClone = [[[self class] allocWithZone:zone] init];

    [newClone setClone:self.clone];

    return newClone;
}




@end
