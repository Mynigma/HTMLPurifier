//
//   HTMLPurifier_VarParser.m
//   HTMLPurifier
//
//  Created by Roman Priebe on 13.01.14.


#import "HTMLPurifier_VarParser.h"

static NSDictionary* typesLookup;

static NSDictionary* types;

static NSDictionary* stringTypes;


@implementation HTMLPurifier_VarParser

- (id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

    /**
     * Validate a variable according to type.
     * It may return NULL as a valid type if $allow_null is true.
     *
     * @param mixed $var Variable to validate
     * @param int $type Type of variable, see HTMLPurifier_VarParser->types
     * @param bool $allow_null Whether or not to permit null as a value
     * @return string Validated and type-coerced variable
     * @throws HTMLPurifier_VarParserException
     */
- (NSString*)parse:(NSObject*)var type:(NSNumber*)type
{
    return [self parse:var type:type allowNull:NO];
}

- (NSString*)parse:(NSObject*)v type:(NSNumber*)type allowNull:(BOOL)allow_null
    {
        if ([type isKindOfClass:[NSString class]])
        {
            if (![HTMLPurifier_VarParser types][type]) {
                @throw [NSException exceptionWithName:@"VarParser" reason:[NSString stringWithFormat:@"Invalid type '%@'", type] userInfo:nil];
            } else {
                type = [HTMLPurifier_VarParser types][type];
            }
        }
        NSObject* var = [self parseImplementation:v type:type allowNull:allow_null];
        if (allow_null && !var) {
            return nil;
        }
        // These are basic checks, to make sure nothing horribly wrong
        // happened in our implementations.
        switch (type.integerValue) {
            case 1:
            case 2:
            case 3:
            case 4:
                if (![var isKindOfClass:[NSString class]])
                {
                    break;
                }
                if (type.integerValue == V_ISTRING.integerValue || type.integerValue == V_ITEXT.integerValue)
                {
                    var = [(NSString*)var lowercaseString];
                }
                return (NSString*)var;
            case 5:
            case 6:
            case 7:
                if (![var isKindOfClass:[NSNumber class]])
                {
                    break;
                }
                return [(NSNumber*)var stringValue];
            case 8:
            case 9:
            case 10:
                if (![var isKindOfClass:[NSDictionary class]] && ![var isKindOfClass:[NSArray class]]) {
                    break;
                }
                if (type.integerValue == V_LOOKUP.integerValue) {
                    for(NSObject* k in (id<NSFastEnumeration>)var)
                    {
                        if (![k isEqual:@YES])
                        {
                            NSLog(@"Lookup table contains value other than true");
                        }
                    }
                } else if (type.integerValue == V_ALIST.integerValue) {
                    NSArray* keys = [(NSDictionary*)var allKeys];
                    if (![[(NSDictionary*)keys allKeys] isEqual:keys]) {
                        NSLog(@"Indices for list are not uniform");
                    }
                }
                return [var description];
            case 11:
                return [var description];
            default:
                [self errorInconsistent:[self classDescription] type:type];
        }
        [self errorGeneric:var type:type];

        return nil;
    }

    /**
     * Actually implements the parsing. Base implementation does not
     * do anything to $var. Subclasses should overload this!
     * @param mixed $var
     * @param int $type
     * @param bool $allow_null
     * @return string
     */
- (NSString*)parseImplementation:(NSObject*)var type:(NSNumber*)type allowNull:(BOOL)allow_null
    {
        return [var description];
    }

    /**
     * Throws an exception.
     * @throws HTMLPurifier_VarParserException
     */
- (void)error:(NSString*)msg
    {
        NSException* e = [NSException exceptionWithName:@"VarParser" reason:msg userInfo:nil];
        @throw e;
    }

    /**
     * Throws an inconsistency exception.
     * @note This should not ever be called. It would be called if we
     *       extend the allowed values of HTMLPurifier_VarParser without
     *       updating subclasses.
     * @param string $class
     * @param int $type
     * @throws HTMLPurifier_Exception
     */
- (void)errorInconsistent:(NSClassDescription*)class type:(NSNumber*)type
    {
        @throw [NSException exceptionWithName:[NSString stringWithFormat:@"Inconsistency in %@: %@ not implemented" , class, [HTMLPurifier_VarParser getTypeName:type]] reason:@"" userInfo:nil];
    }

    /**
     * Generic error for if a type didn't work.
     * @param mixed $var
     * @param int $type
     */
- (void)errorGeneric:(NSObject*)var type:(NSNumber*)type
    {
        NSString* vtype = [var className];
        NSLog(@"Expected type %@, got %@", [HTMLPurifier_VarParser getTypeName:type], vtype);
    }

+ (NSDictionary*)types
{
    if(!types)
        types = @{@"string":V_STRING,
           @"istring":V_ISTRING,
           @"text":V_TEXT,
           @"itext":V_ITEXT,
           @"int":V_INT,
           @"float":V_FLOAT,
           @"bool":V_BOOL,
           @"lookup":V_LOOKUP,
           @"list":V_ALIST,
           @"hash":V_HASH,
           @"mixed":V_MIXED};
    return types;
}

+ (NSDictionary*)stringTypes
{
    if(!stringTypes)
        stringTypes = @{V_STRING : @YES,
                 V_ISTRING : @YES,
                 V_TEXT : @YES,
                 V_ITEXT : @YES};
    return stringTypes;
}


+ (NSDictionary*)lookup
{
    if(!typesLookup)
        typesLookup = @{V_STRING:@"string",
                 V_ISTRING:@"istring",
                 V_TEXT:@"text",
                 V_ITEXT:@"itext",
                 V_INT:@"int",
                 V_FLOAT:@"float",
                 V_BOOL:@"bool",
                 V_LOOKUP:@"lookup",
                 V_ALIST:@"list",
                 V_HASH:@"hash",
                 V_MIXED:@"mixed"};
    return typesLookup;
}

    /**
     * @param int $type
     * @return string
     */
+ (NSString*)getTypeName:(NSNumber*)type
    {
        NSDictionary* newLookup = [HTMLPurifier_VarParser lookup];
        if (newLookup[type]) {
            return @"unknown";
        }
        return newLookup[type];
    }





@end
