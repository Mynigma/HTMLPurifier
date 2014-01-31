//
//  HTMLPurifier_EntityLookup.m
//  HTMLPurifier
//
//  Created by Roman Priebe on 16.01.14.


#import "HTMLPurifier_EntityLookup.h"

#define BUNDLE (NSClassFromString(@"HTMLPurifierTests")!=nil)?[NSBundle bundleForClass:[NSClassFromString(@"HTMLPurifierTests") class]]:[NSBundle mainBundle]


static HTMLPurifier_EntityLookup* commonLookup;

@implementation HTMLPurifier_EntityLookup


- (id)init
{
    if(commonLookup)
        return commonLookup;

    self = [super init];
    if (self) {
        NSURL* plistURL = [BUNDLE URLForResource:@"entities" withExtension:@"plist"];

        _table = [NSDictionary dictionaryWithContentsOfURL:plistURL];

        commonLookup = self;
    }
    return self;
}

+ (HTMLPurifier_EntityLookup*)instance
{
    return [self instanceWithPrototype:nil];
}

+ (HTMLPurifier_EntityLookup*)instanceWithPrototype:(HTMLPurifier_EntityLookup*)prototype;
{
    //all moved to init
    return [HTMLPurifier_EntityLookup new];
}


@end
