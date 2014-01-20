//
//  HTMLPurifier_AttrTypes.m
//  HTMLPurifier
//
//  Created by Roman Priebe on 19.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_AttrTypes.h"
#import "HTMLPurifier_AttrDef.h"
#import "HTMLPurifier_AttrDef_Enum.h"
#import "HTMLPurifier_AttrDef_HTML_Bool.h"
#import "HTMLPurifier_AttrDef_Text.h"
#import "HTMLPurifier_AttrDef_HTML_ID.h"
#import "HTMLPurifier_AttrDef_HTML_Length.h"
#import "HTMLPurifier_AttrDef_HTML_MultiLength.h"
#import "HTMLPurifier_AttrDef_URI.h"
#import "HTMLPurifier_AttrDef_HTML_Nmtokens.h"
#import "HTMLPurifier_AttrDef_HTML_Pixels.h"
#import "HTMLPurifier_AttrDef_Lang.h"
#import "HTMLPurifier_AttrDef_HTML_Color.h"
#import "HTMLPurifier_AttrDef_HTML_FrameTarget.h"
#import "HTMLPurifier_AttrDef_HTML_Class.h"
#import "HTMLPurifier_AttrDef_Integer.h"
#import "HTMLPurifier_AttrDef_Clone.h"
#import "BasicPHP.h"


/**
 * Provides lookup array of attribute types to HTMLPurifier_AttrDef objects
 */
@implementation HTMLPurifier_AttrTypes

     /**
     * Constructs the info array, supplying default implementations for attribute
     * types.
     */
  - (id)init
{
    self = [super init];
    if (self) {
        info = [NSMutableDictionary new];
        // XXX This is kind of poor, since we don't actually /clone/
        // instances; instead, we use the supplied make() attribute. So,
        // the underlying class must know how to deal with arguments.
        // With the old implementation of Enum, that ignored its
        // arguments when handling a make dispatch, the IAlign
        // definition wouldn't work.

        // pseudo-types, must be instantiated via shorthand
        info[@"Enum"] = [HTMLPurifier_AttrDef_Enum new];
        info[@"Bool"] = [HTMLPurifier_AttrDef_HTML_Bool new];

        info[@"CDATA"] = [HTMLPurifier_AttrDef_Text new];
        info[@"ID"] = [HTMLPurifier_AttrDef_HTML_ID new];
        info[@"Length"] = [HTMLPurifier_AttrDef_HTML_Length new];
        info[@"MultiLength"] = [HTMLPurifier_AttrDef_HTML_MultiLength new];
        info[@"NMTOKENS"] = [HTMLPurifier_AttrDef_HTML_Nmtokens new];
        info[@"Pixels"] = [HTMLPurifier_AttrDef_HTML_Pixels new];
        info[@"Text"] = [HTMLPurifier_AttrDef_Text new];
        info[@"URI"] = [HTMLPurifier_AttrDef_URI new];
        info[@"LanguageCode"] = [HTMLPurifier_AttrDef_Lang new];
        info[@"Color"] = [HTMLPurifier_AttrDef_HTML_Color new];
        info[@"IAlign"] = [self makeEnum:@"top,middle,bottom,left,right"];
        info[@"LAlign"] = [self makeEnum:@"top,bottom,left,right"];
        info[@"FrameTarget"] = [HTMLPurifier_AttrDef_HTML_FrameTarget new];

        // unimplemented aliases
        info[@"ContentType"] = [HTMLPurifier_AttrDef_Text new];
        info[@"ContentTypes"] = [HTMLPurifier_AttrDef_Text new];
        info[@"Charsets"] = [HTMLPurifier_AttrDef_Text new];
        info[@"Character"] = [HTMLPurifier_AttrDef_Text new];

        // "proprietary" types
        info[@"Class"] = [HTMLPurifier_AttrDef_HTML_Class new];

        // number is really a positive integer (one or more digits)
        // FIXME: ^^ not always, see start and value of list items
        info[@"Number"]   = [[HTMLPurifier_AttrDef_Integer alloc] initWithNegative:@NO Zero:@NO Positive:@YES];
    }
    return self;
}



- (HTMLPurifier_AttrDef_Clone*)makeEnum:(NSString*)inString
    {
        return [[HTMLPurifier_AttrDef_Clone alloc] initWithClone:[[HTMLPurifier_AttrDef_Enum alloc] initWithValidValues:explode(@",", inString)]];
    }

    /**
     * Retrieves a type
     * @param string $type String type name
     * @return HTMLPurifier_AttrDef Object AttrDef for type
     */
- (HTMLPurifier_AttrDef*)get:(NSString*)type
    {
        NSString* string = nil;
        if(![type isKindOfClass:[NSString class]])
            return nil;

        // determine if there is any extra info tacked on
        if (strpos(type, @"#") != NSNotFound)
        {
            NSArray* pair = explodeWithLimit(@"#", type, 2);
            if(pair.count>0)
                type = pair[0];
            if(pair.count>1)
                string = pair[1];
        } else {
            string = @"";
        }

        if (!self->info[type])
        {
            TRIGGER_ERROR(@"Cannot retrieve undefined attribute type %@", type);
            return nil;
        }
        return [self->info[type] make:string];
    }

    /**
     * Sets a new implementation for a type
     * @param string $type String type name
     * @param HTMLPurifier_AttrDef $impl Object AttrDef for type
     */
- (void)set:(NSString*)type impl:(HTMLPurifier_AttrDef*)impl
    {
        self->info[type] = impl;
    }


@end
