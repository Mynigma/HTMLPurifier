//
//   HTMLPurifier_Tidy.m
//   HTMLPurifier
//
//  Created by Roman Priebe on 25.01.14.


#import "HTMLPurifier_HTMLModule_Tidy.h"
#import "HTMLPurifier_Config.h"
#import "BasicPHP.h"
#import "HTMLPurifier_ElementDef.h"



@implementation HTMLPurifier_HTMLModule_Tidy

/**
 * Lazy load constructs the module by determining the necessary
 * fixes to create and then delegating to the populate() function.
 * @param HTMLPurifier_Config $config
 * @todo Wildcard matching and error reporting when an added or
 *       subtracted fix has no effect.
 */

- (id)initWithConfig:(HTMLPurifier_Config*)config
{
    self = [super initWithConfig:config];
    if (self) {

        _fixesForLevel = [@{@"light" : @[], @"medium" : @[], @"heavy" : @[]} mutableCopy];
        _defaultLevel = nil;
        _levels = @[@"none", @"light", @"medium", @"heavy"];

    // create fixes, initialize fixesForLevel
    NSMutableDictionary* fixes = [self makeFixes];
    [self makeFixesForLevel:fixes];

    // figure out which fixes to use
    NSString* level = (NSString*)[config get:@"HTML.TidyLevel"];
    NSMutableDictionary* fixes_lookup = [self getFixesForLevel:level];

    // get custom fix declarations: these need namespace processing
    NSMutableDictionary* add_fixes = [(NSDictionary*)[config get:@"HTML.TidyAdd"] mutableCopy];
    NSMutableDictionary* remove_fixes = [(NSDictionary*)[config get:@"HTML.TidyRemove"] mutableCopy];

    for(NSString* name in fixes)
    {
        // needs to be refactored a little to implement globbing
        if (([remove_fixes isKindOfClass:[NSDictionary class]] && remove_fixes[name]) ||
            ([add_fixes isKindOfClass:[NSDictionary class]] && [fixes_lookup isKindOfClass:[NSDictionary class]] && !add_fixes[name] && !fixes_lookup[name]))
        {
            [fixes removeObjectForKey:name];
        }
    }

    // populate this module with necessary fixes
    [self populate:fixes];
    }
    return self;
}

/**
 * Retrieves all fixes per a level, returning fixes for that specific
 * level as well as all levels below it.
 * @param string $level level identifier, see $levels for valid values
 * @return array Lookup up table of fixes
 */
- (NSMutableDictionary*)getFixesForLevel:(NSString*)level
{
    if ([level isEqual:self.levels[0]])
    {
        return [NSMutableDictionary new];
    }
    NSMutableDictionary* activated_levels = [NSMutableDictionary new];
    NSInteger c = self.levels.count;
    NSInteger i;
    for (i = 1; i < c; i++)
    {
        NSString* key = [NSString stringWithFormat:@"%ld", (unsigned long)activated_levels.count];
        if (key)
            [activated_levels setObject:self.levels[i] forKey:key];
        if ([self.levels[i] isEqual:level])
        {
            break;
        }
    }
    if (i == c)
    {
        TRIGGER_ERROR(@"Tidy level %@ not recognised", htmlspecialchars(level));
        return [NSMutableDictionary new];;
    }
    NSMutableDictionary* ret = [NSMutableDictionary new];
    for(NSString* level in activated_levels)
    {
        for(NSString* fix in self.fixesForLevel[level])
        {
            ret[fix] = @YES;
        }
    }
    return ret;
}

/**
 * Dynamically populates the $fixesForLevel member variable using
 * the fixes array. It may be custom overloaded, used in conjunction
 * with $defaultLevel, or not used at all.
 * @param array $fixes
 */
- (void)makeFixesForLevel:(NSDictionary*)fixes
{
    if (!self.defaultLevel)
    {
        return;
    }
    if (!self.fixesForLevel[self.defaultLevel])
    {
        TRIGGER_ERROR(@"Defaul level %@ does not exist", self.defaultLevel);
        return;
    }
    if(fixes.allKeys)
        self.fixesForLevel[self.defaultLevel] = fixes.allKeys;
}

/**
 * Populates the module with transforms and other special-case code
 * based on a list of fixes passed to it
 * @param array $fixes Lookup table of fixes to activate
 */
- (void)populate:(NSDictionary*)fixes
{
    for(NSString* name in fixes)
    {
        NSObject* fix = fixes[name];
        // determine what the fix is for

        NSArray* pair = [self getFixType:name];
        NSString* type = pair.count>0?pair[0]:nil;
        NSMutableDictionary* params = pair.count>1?pair[1]:nil;
        NSObject* e = nil;

        if([type isEqual:@"attr_transform_pre"] || [type isEqual:@"attr_transform_post"])
        {
                NSDictionary* attr = params[@"attr"];
                if(params[@"element"])
                {
                    NSString* element = params[@"element"];
                    if (!self.info[element])
                    {
                        e = [self addBlankElement:element];
                    } else {
                        e = self.info[element];
                    }
                } else {
                    type = [NSString stringWithFormat:@"info_%@", type];
                    e = self;
                }

                NSMutableDictionary* f = [e valueForKey:type];
                if(attr)
                    f[attr] = fix;
        }
        else if([type isEqual:@"tag_transform"])
        {
            if(params[@"element"])
                self.info_tag_transform[params[@"element"]] = fix;
        }
        else if([type isEqual:@"child"] || [type isEqual:@"content_model_type"])
        {
                NSString* element = params[@"element"];
                if (!self.info[element])
                {
                    e = [self addBlankElement:element];
                } else {
                    e = self.info[element];
                }
            [(HTMLPurifier_ElementDef*)e setValue:fix forKey:type];
        }
        else
        {
                TRIGGER_ERROR(@"Fix type %@ not supported", type);
        }
    }
}

/**
 * Parses a fix name and determines what kind of fix it is, as well
 * as other information defined by the fix
 * @param $name String name of fix
 * @return array(string $fix_type, array $fix_parameters)
 * @note $fix_parameters is type dependant, see populate() for usage
 *       of these parameters
 */
- (NSArray*)getFixType:(NSString*)name
{
    // parse it
    NSMutableString* attr = nil;
    NSMutableString* property = attr;
    if(strpos(name, @"#") != NSNotFound)
    {
        NSArray* pair = explode(@"#", name);
        name = pair.count>0?pair[0]:nil;
        property = pair.count>1?pair[1]:nil;
    }
    if(strpos(name, @"@") != NSNotFound)
    {
        NSArray* pair = explode(@"@", name);
        name = pair.count>0?pair[0]:nil;
        attr = pair.count>1?pair[1]:nil;
    }

    // figure out the parameters
    NSMutableDictionary* params = [NSMutableDictionary new];
    if(![name isEqual:@""])
    {
        params[@"element"] = name;
    }
    if(attr)
    {
        params[@"attr"] = attr;
    }

    // special case: attribute transform
    if(attr) {
        if (!property)
        {
            property = [@"pre" mutableCopy];
        }
        NSMutableString* type = [NSMutableString stringWithFormat:@"attr_transform_%@", property];
        return @[type, params];
    }

    // special case: tag transform
    if (!property)
    {
        return @[@"tag_transform", params];
    }

    return @[property, params];

}

/**
 * Defines all fixes the module will perform in a compact
 * associative array of fix name to fix implementation.
 * @return array
 */
- (NSMutableDictionary*)makeFixes
{
    return nil;
}


@end
