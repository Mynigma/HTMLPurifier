//
//   HTMLPurifier_DoctypeRegistry.m
//   HTMLPurifier
//
//  Created by Roman Priebe on 19.01.14.


#import "HTMLPurifier_DoctypeRegistry.h"
#import "HTMLPurifier_Doctype.h"
#import "BasicPHP.h"
#import "HTMLPurifier_Config.h"

@implementation HTMLPurifier_DoctypeRegistry

- (id)init
{
    self = [super init];
    if (self) {
        doctypes = [NSMutableDictionary new];
        aliases = [NSMutableDictionary new];
    }
    return self;
}

    /**
     * Registers a doctype to the registry
     * @note Accepts a fully-formed doctype object, or the
     *       parameters for constructing a doctype object
     * @param string $doctype Name of doctype or literal doctype object
     * @param bool $xml
     * @param array $modules Modules doctype will load
     * @param array $tidy_modules Modules doctype will load for certain modes
     * @param array $aliases Alias names for doctype
     * @param string $dtd_public
     * @param string $dtd_system
     * @return HTMLPurifier_Doctype Editable registered doctype
     */
- (HTMLPurifier_Doctype*)registerDoctype:(NSObject*)doctype xml:(NSNumber*)xml modules:(NSArray*)modules tidy_modules:(NSArray*)tidy_modules aliases:(NSArray*)newAliases dtdPublic:(NSString*)dtd_public dtdSystem:(NSString*)dtd_system
{

    if (![modules isKindOfClass:[NSArray class]])
        {
            modules = @[modules];
        }
        if (![tidy_modules isKindOfClass:[NSArray class]])
        {
            tidy_modules = @[tidy_modules];
        }
        if (![newAliases isKindOfClass:[NSArray class]])
        {
            newAliases = @[newAliases];
        }
        if ([doctype isKindOfClass:[NSString class]])
        {
            doctype = [[HTMLPurifier_Doctype alloc] initWithName:(NSString*)doctype xml:xml modules:modules tidyModules:tidy_modules aliases:newAliases dtdPublic:dtd_public dtdSystem:dtd_system];
         }
        NSString* name = [(HTMLPurifier_Doctype*)doctype name];
        doctypes[name] = doctype;
        // hookup aliases
        for(NSString* alias in [(HTMLPurifier_Doctype*)doctype aliases])
        {
            if(doctypes[alias])
                continue;

            aliases[alias] = name;
        }
        // remove old aliases
        if (aliases[name])
        {
            [aliases removeObjectForKey:name];
        }
        return (HTMLPurifier_Doctype*)doctype;
    }

    /**
     * Retrieves reference to a doctype of a certain name
     * @note This function resolves aliases
     * @note When possible, use the more fully-featured make()
     * @param string $doctype Name of doctype
     * @return HTMLPurifier_Doctype Editable doctype object
     */
- (HTMLPurifier_Doctype*)getDoctype:(NSString*)doctype
    {
        if (aliases[doctype])
        {
            doctype = aliases[doctype];
        }
        if (!doctypes[doctype])
        {
            TRIGGER_ERROR(@"Doctype %@ does not exist", htmlspecialchars(doctype));
            HTMLPurifier_Doctype* anon = [[HTMLPurifier_Doctype alloc] initWithName:doctype];
            return anon;
        }
        return doctypes[doctype];
    }

    /**
     * Creates a doctype based on a configuration object,
     * will perform initialization on the doctype
     * @note Use this function to get a copy of doctype that config
     *       can hold on to (this is necessary in order to tell
     *       Generator whether or not the current document is XML
     *       based or not).
     * @param HTMLPurifier_Config $config
     * @return HTMLPurifier_Doctype
     */
- (HTMLPurifier_Doctype*)make:(HTMLPurifier_Config*)config
    {
        return [[self getDoctype:[self getDoctypeFromConfig:config]] copy];
    }

    /**
     * Retrieves the doctype from the configuration object
     * @param HTMLPurifier_Config $config
     * @return string
     */
- (NSString*)getDoctypeFromConfig:(HTMLPurifier_Config*)config
    {
        // recommended test
        NSString* doctype = (NSString*)[config get:@"HTML.Doctype"];
        if ([doctype length]>0)
        {
            return doctype;
        }
        doctype = (NSString*)[config get:@"HTML.CustomDoctype"];
        if ([doctype length]>0)
        {
            return doctype;
        }
        // backwards-compatibility
        if ([config get:@"HTML.XHTML"])
        {
            doctype = @"XHTML 1.0";
        } else {
            doctype = @"HTML 4.01";
        }
        if ([config get:@"HTML.Strict"])
        {
            doctype = [doctype stringByAppendingString:@" Strict"];
        } else {
            doctype = [doctype stringByAppendingString:@" Transitional"];
        }
        return doctype;
    }


@end