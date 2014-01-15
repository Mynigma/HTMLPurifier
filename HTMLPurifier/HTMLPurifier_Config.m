//
//  HTMLPurifier_Config.m
//  HTMLPurifier
//
//  Created by Lukas Neumann on 10.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_Config.h"
#import "HTMLPurifier_ConfigSchema.h"
//#import "HTMLPurifier_PropertyList.h"
#import "HTMLPurifier_VarParser.h"
#import "BasicPHP.h"
#import "HTMLPurifier_Definition.h"
#import "HTMLPurifier_URIDefinition.h"
#import "HTMLPurifier_CSSDefinition.h"
#import "HTMLPurifier_HTMLDefinition.h"
#import "HTMLPurifier_VarParser_Flexible.h"

/**
 * Configuration object that triggers customizable behavior.
 *
 * @warning This class is strongly defined: that means that the class
 *          will fail if an undefined directive is retrieved or set.
 *
 * @note Many classes that could (although many times don't) use the
 *       configuration object make it a mandatory parameter.  This is
 *       because a configuration object should always be forwarded,
 *       otherwise, you run the risk of missing a parameter and then
 *       being stumped when a configuration directive doesn't work.
 *
 * @todo Reconsider some of the public member variables
 */

static HTMLPurifier_ConfigSchema* theDefinition;
static HTMLPurifier_VarParser* theParser;

@implementation HTMLPurifier_Config

- (HTMLPurifier_ConfigSchema*)definition
{
    if(!theDefinition)
        theDefinition = [HTMLPurifier_ConfigSchema singleton];
    return theDefinition;
}

- (HTMLPurifier_VarParser*)parser
{
    if(!theParser)
        theParser = [HTMLPurifier_VarParser_Flexible new];
    return theParser;
}

- (id)init
{
    return [self initWithDefinition:nil parent:nil];
}


- (id)initWithDefinition:(HTMLPurifier_ConfigSchema*)definition parent:(HTMLPurifier_PropertyList*)newParent
{
    self = [super init];
    if (self) {
        _auto_finalize = YES;
        _chatty = YES;
        //_parent = newParent ? newParent : [definition defaultPlist];
        //theDefinition = definition;
        //parser = [HTMLPurifier_VarParser_Flexible new];
    }
    return self;
}
/**
 * Convenience constructor that creates a config object based on a mixed var
 * @param mixed $config Variable that defines the state of the config
 *                      object. Can be: a HTMLPurifier_Config() object,
 *                      an array of directives based on loadArray(),
 *                      or a string filename of an ini file.
 * @param HTMLPurifier_ConfigSchema $schema Schema object
 * @return HTMLPurifier_Config Configured object
 */

+ (HTMLPurifier_Config*)createWithConfig:(HTMLPurifier_Config*)config
{
    return [self createWithConfig:config schema:nil];
}


+ (HTMLPurifier_Config*)createWithConfig:(HTMLPurifier_Config*)config schema:(HTMLPurifier_ConfigSchema*)schema
{
    if ([config isKindOfClass:[HTMLPurifier_Config class]]) {
        // pass-through
        return config;
    }
    return [HTMLPurifier_Config createDefault];
}

/**
 * Convenience constructor that creates a default configuration object.
 * @return HTMLPurifier_Config default object.
 */
+ (HTMLPurifier_Config*)createDefault
{
    HTMLPurifier_ConfigSchema* def = [HTMLPurifier_ConfigSchema singleton];
    HTMLPurifier_Config* config = [[HTMLPurifier_Config alloc] initWithDefinition:def parent:nil];
    return config;
}

/**
 * Retrieves a value from the configuration.
 *
 * @param string $key String key
 * @param mixed $a
 *
 * @return mixed
 */
- (NSObject*)get:(NSString*)key
{
    [self autoFinalize];

    if (![_def.info objectForKey:key]) {
        // can't add % due to SimpleTest bug
        TRIGGER_ERROR(@"Cannot retrieve value of undefined directive");
        return nil;
    }
    if ([[[_def.info objectForKey:key] valueForKey:@"isAlias"] boolValue])
    {

        TRIGGER_ERROR(@"Cannot get value from aliased directive, use real name");
        return nil;
    }

    if(lock)
    {
        NSArray* ns = explode(@".", key);
        if (![ns[0] isEqualToString:lock])
        {
            TRIGGER_ERROR(@"Cannot get value of namespace %@ when lock for ", lock);
            return nil;
        }
    }
    return [plist get:key];
}

/**
 * Retrieves an array of directives to values from a given namespace
 *
 * @param string $namespace String namespace
 *
 * @return array
 */
- (NSDictionary*)getBatch:(NSString*)namespace
{
    [self autoFinalize];

    NSDictionary* full = [self getAll];
    if (![full objectForKey:namespace]) {
        TRIGGER_ERROR(@"Cannot retrieve undefined namespace ");
        return nil;
    }
    return [full objectForKey:namespace];
}

/**
 * Returns a SHA-1 signature of a segment of the configuration object
 * that uniquely identifies that particular configuration
 *
 * @param string $namespace Namespace to get serial for
 *
 * @return string
 * @note Revision is handled specially and is removed from the batch
 *       before processing!
 */
- (NSString*)getBatchSerial:(NSString*)namespace
{
    return @"";
    /*
    if (!self.serials[namespace])) {
        NSMutableDictionary* batch = [[self getBatch:namespace] mutableCopy];
        [batch removeObjectForKey:@"DefinitionRev"];
        self.serials[namespace] = sha1(serialize(batch));
    }
    return self.serials[namespace];*/
}

/**
 * Returns a SHA-1 signature for the entire configuration object
 * that uniquely identifies that particular configuration
 *
 * @return string
 */
- (NSString*)getSerial
{
    return nil;
    /*
    if (self->serial.length==0) {
        self->serial = sha1(serialize([self getAll]));
    }
    return self.serial;
     */
}

/**
 * Retrieves all directives, organized by namespace
 *
 * @warning This is a pretty inefficient function, avoid if you can
 */
- (NSDictionary*)getAll
{
    if (!self->finalized) {
        [self autoFinalize];
    }
    NSMutableDictionary* ret = [NSMutableDictionary new];
    for(NSString* name in [plist squash])
    {
        NSObject* value = [self.plist valueForKey:name];
        NSArray* exploded = explode(@".", name);
        NSString* ns = @"";
        NSString* key = @"";
        if(exploded.count>0)
            ns = exploded[0];
        if(exploded.count>1)
            key = exploded[1];
        [[ret objectForKey:ns] setObject:value forKey:key];
    }
    return ret;
}

/**
 * Sets a value to configuration.
 *
 * @param string $key key
 * @param mixed $value value
 * @param mixed $a
 */
- (void)setString:(NSString*)key object:(NSObject*)value
{
    return;
//    NSArray* namespace = explode(@".", key);
//
//    if ([self isFinalized:@"Cannot set directive after finalization"])
//    {
//        return;
//    }
//    if (!self.def.info[key])
//    {
//        NSLog(@"Cannot set undefined directive '%@ to value", key);
//        return;
//    }
//    HTMLPurifier_Definition* def = self.def.info[$key];
//
//    if ([def isAlias]) {
//        if (self.aliasMode) {
//            NSLog(@"Double-aliases not allowed, please fix");
//            return;
//        }
//        [self setAliasMode:YES];
//        [self setString:def.key object:value];
//        [self setAliasMode:NO];
//        NSLog(@"%@ is an alias, preferred directive name is {%@}", key, def.key);
//        return;
//    }
//
//    // Raw type might be negative when using the fully optimized form
//    // of stdclass, which indicates allow_null == true
//    rtype = [def isKindOfClass:[NSNumber class]] ? def : def.type;
//    if (rtype < 0) {
//        type = -$rtype;
//        allow_null = true;
//    } else {
//        type = rtype;
//        allow_null = def.allow_null);
//    }
//
//    @try {
//        value = [self.parser parse:value type, $allow_null];
//    } @catch (NSException* e) {
//        NSLog(@"Value for %@ is of invalid type, should be %@", key, [HTMLPurifier_VarParser getTypeName:type]);
//        return;
//    }
//    if ([value isKindOfClass:[NSString class]] && def) {
//        // resolve value alias if defined
//        if (def.aliases[value])) {
//            value = def.aliases[value];
//        }
//        // check to see if the value is allowed
//        if (def.allowed) && !def.allowed[value])) {
//            NSLog(@"Value not supported, valid values are: %@", [self _listify:def.allowed]),
//            return;
//        }
//    }
//    [self.plist setKey:key value:value];
//
//    // reset definitions if the directives they depend on changed
//    // this is a very costly process, so it's discouraged
//    // with finalization
//    if ([namespace isEqual:@"HTML"] || [namespace isEqual:@"CSS"] || [namespace isEqual:@"URI"])
//    {
//        [self.definitions setObject:[NSNull null] forKey:namespace];
//    }
//
//    [self.serials setObject:@NO forKey:namespace];
}

/**
 * Convenience function for error reporting
 *
 * @param array $lookup
 *
 * @return string
 */
- (NSString*)_listify:(NSDictionary*)lookup
{
    NSMutableArray* list = [NSMutableArray new];
    for(NSString* name in lookup.allKeys)
    {
        [list addObject:name];
    }
    return implode(@", ", list);
}

/**
 * Retrieves object reference to the HTML definition.
 *
 * @param bool $raw Return a copy that has not been setup yet. Must be
 *             called before it's been setup, otherwise won't work.
 * @param bool $optimized If true, this method may return null, to
 *             indicate that a cached version of the modified
 *             definition object is available and no further edits
 *             are necessary.  Consider using
 *             maybeGetRawHTMLDefinition, which is more explicitly
 *             named, instead.
 *
 * @return HTMLPurifier_HTMLDefinition
 */
- (HTMLPurifier_HTMLDefinition*)getHTMLDefinition
{
    return [self getDefinition:@"HTML"];
}

/**
 * Retrieves object reference to the CSS definition
 *
 * @param bool $raw Return a copy that has not been setup yet. Must be
 *             called before it's been setup, otherwise won't work.
 * @param bool $optimized If true, this method may return null, to
 *             indicate that a cached version of the modified
 *             definition object is available and no further edits
 *             are necessary.  Consider using
 *             maybeGetRawCSSDefinition, which is more explicitly
 *             named, instead.
 *
 * @return HTMLPurifier_CSSDefinition
 */
- (HTMLPurifier_CSSDefinition*)getCSSDefinition
{
    return (HTMLPurifier_CSSDefinition*)[self getDefinition:@"CSS"];
}

/**
 * Retrieves object reference to the URI definition
 *
 * @param bool $raw Return a copy that has not been setup yet. Must be
 *             called before it's been setup, otherwise won't work.
 * @param bool $optimized If true, this method may return null, to
 *             indicate that a cached version of the modified
 *             definition object is available and no further edits
 *             are necessary.  Consider using
 *             maybeGetRawURIDefinition, which is more explicitly
 *             named, instead.
 *
 * @return HTMLPurifier_URIDefinition
 */
- (HTMLPurifier_URIDefinition*)getURIDefinition
{
    return (HTMLPurifier_URIDefinition*)[self getDefinition:@"URI"];
}

- (HTMLPurifier_Definition*)getDefinition:(NSString*)type
{
    return [self getDefinition:type raw:NO optimized:NO];
}

/**
 * Retrieves a definition
 *
 * @param string $type Type of definition: HTML, CSS, etc
 * @param bool $raw Whether or not definition should be returned raw
 * @param bool $optimized Only has an effect when $raw is true.  Whether
 *        or not to return null if the result is already present in
 *        the cache.  This is off by default for backwards
 *        compatibility reasons, but you need to do things this
 *        way in order to ensure that caching is done properly.
 *        Check out enduser-customize.html for more details.
 *        We probably won't ever change this default, as much as the
 *        maybe semantics is the "right thing to do."
 *
 * @throws HTMLPurifier_Exception
 * @return HTMLPurifier_Definition
 */
- (HTMLPurifier_Definition*)getDefinition:(NSString*)type raw:(BOOL)raw optimized:(BOOL)optimized
{
    if (![self finalized]) {
        [self autoFinalize];
    }
    // temporarily suspend locks, so we can handle recursive definition calls
    NSString* lock = self.lock;
    self.lock = nil;
    factory = [HTMLPurifier_DefinitionCacheFactory instance];
    cache = [factory create:type :self];
    [self setLock:lock];
    if (!raw) {
        // full definition
        // ---------------
        // check if definition is in memory
        if ([self.definitions[type] count]!=0)) {
            def = self.definitions[type];
            // check if the definition is setup
            if ([def setup]) {
                return def;
            } else {
                [def setup:self];
                if ([def optimized]) {
                    [cache add:def :self];
                }
                return def;
            }
        }
        // check if definition is in cache
        def = [cache get:self];
        if (def) {
            // definition in cache, save to memory and return it
            [self.definitions setObject:def forKey:type];
            return def;
        }
        // initialize it
        def = [self initDefinition:type];
        // set it up
        [self setLock:type];
        [def setSetup:self];
        [self setLock:nil];
        // save in cache
        [cache add:def self];
        // return it
        return def;
    }
    else
    {
        // raw definition
        // --------------
        // check preconditions
        def = nil;
        if (optimized)
        {
            if (![self get:[NSString stringWithFormat:@"%@.DefinitionID", type ]])
            {
                // fatally error out if definition ID not set
                @throw [NSException exceptionWithName:@"Config" reason:@"Cannot retrieve raw version without specifying $type.DefinitionID" userInfo:nil];
            }
        }
        if ([self.definitions[type] count]!=0))
        {
            def = self.definitions[type];
            if ([def setup] && !optimized)
            {
                NSString* extra = self.chatty ?
                @" (try moving this code block earlier in your initialization)" :
                @"";
                @throw [NSException exceptionWithName:@"Config" reason:[@"Cannot retrieve raw definition after it has already been setup" stringByAppendingString:extra] userInfo:nil];
            }
            if ([def optimized] == nil)
            {
                NSString* extra = self.chatty ? @" (try flushing your cache)" : @"";
                @throw [NSException exceptionWithName:@"Config" reason:[@"Optimization status of definition is unknown" stringByAppendingString:extra] userInfo:nil];
            }
            if ([def optimized] != optimized)
            {
                NSString* msg = optimized ? @"optimized" : @"unoptimized";
                extra = self.chatty ?
                @" (this backtrace is for the first inconsistent call, which was for a $msg raw definition)"
                : @"";
                @throw [NSException exceptionWithName:@"Config" reason:[@"Inconsistent use of optimized and unoptimized raw definition retrievals" stringByAppendingString:extra] userInfo:nil];
            }
        }
        // check if definition was in memory
        if (def) {
            if ([def setup]) {
                // invariant: $optimized === true (checked above)
                return nil;
            } else {
                return def;
            }
        }
        // if optimized, check if definition was in cache
        // (because we do the memory check first, this formulation
        // is prone to cache slamming, but I think
        // guaranteeing that either /all/ of the raw
        // setup code or /none/ of it is run is more important.)
        if (optimized) {
            // This code path only gets run once; once we put
            // something in $definitions (which is guaranteed by the
            // trailing code), we always short-circuit above.
            def = [cache get:self];
            if (def) {
                // save the full definition for later, but don't
                // return it yet
                self.definitions[type] = def;
                return null;
            }
        }
        // check invariants for creation
        if (!optimized)
        {
            if ([self get:[type stringByAppendingString:@".DefinitionID"]])
            {
                if (self.chatty)
                {
                    NSLog(@"Due to a documentation error in previous version of HTML Purifier, your definitions are not being cached.  If this is OK, you can remove the $type.DefinitionRev and $type.DefinitionID declaration.  Otherwise, modify your code to use maybeGetRawDefinition, and test if the returned value is null before making any edits (if it is null, that means that a cached version is available, and no raw operations are necessary).  See <a href=\"http://htmlpurifier.org/docs/enduser-customize.html#optimized\">Customize</a> for more details");
                }
                else
                {
                    NSLog(@"Useless DefinitionID declaration");
                }
            }

        }
        // initialize it
        def = [self initDefinition:type];
        def.optimized = optimized;
        return def;
    }
    @throw [NSException exceptionWithName:@"Config" reason:@"The impossible happened!" userInfo:nil];
}

/**
 * Initialise definition
 *
 * @param string $type What type of definition to create
 *
 * @return HTMLPurifier_CSSDefinition|HTMLPurifier_HTMLDefinition|HTMLPurifier_URIDefinition
 * @throws HTMLPurifier_Exception
 */
- (HTMLPurifier_Definition*)InitialiseDefinition:(NSString*)type
{
    // quick checks failed, let's create the object
    if ([type isEqualToString:@"HTML"]) {
        def = [HTMLPurifier_HTMLDefinition new];
    } else if ([type isEqualToString:@"CSS"]) {
        def = new HTMLPurifier_CSSDefinition();
    } else if ([type isEqualToString:@"URI"]) {
        def = [HTMLPurifier_URIDefinition new];
    } else {
        @throw [NSException exceptionWithName:@"Config" reason:[@"Definition of $type type not supported" stringByAppendingString:extra] userInfo:nil];
    }
    self.definitions[type] = def;
    return def;
}

- (HTMLPurifier_Definition*)maybeGetRawDefinition:(NSString*)name
{
    return [self getDefinition:name raw:YES optimized:YES];
}

- (HTMLPurifier_Definition*)maybeGetRawHTMLDefinition
{
    return [self getDefinition:@"HTML" raw:YES optimized:YES];
}

- (HTMLPurifier_Definition*)maybeGetRawCSSDefinition
{
    return [self getDefinition:@"CSS" raw:YES optimized:YES];
}

- (HTMLPurifier_Definition*)maybeGetRawURIDefinition
{
    return [self getDefinition:@"URI" raw:YES optimized:YES];
}

//    /**
//     * Loads configuration values from an array with the following structure:
//     * Namespace.Directive => Value
//     *
//     * @param array $config_array Configuration associative array
//     */
//    public function loadArray($config_array)
//    {
//        if ($this->isFinalized('Cannot load directives after finalization')) {
//            return;
//        }
//        foreach ($config_array as $key => $value) {
//            $key = str_replace('_', '.', $key);
//            if (strpos($key, '.') !== false) {
//                $this->set($key, $value);
//            } else {
//                $namespace = $key;
//                $namespace_values = $value;
//                foreach ($namespace_values as $directive => $value2) {
//                    $this->set($namespace .'.'. $directive, $value2);
//                }
//            }
//        }
//    }
//
//    /**
//     * Returns a list of array(namespace, directive) for all directives
//     * that are allowed in a web-form context as per an allowed
//     * namespaces/directives list.
//     *
//     * @param array $allowed List of allowed namespaces/directives
//     * @param HTMLPurifier_ConfigSchema $schema Schema to use, if not global copy
//     *
//     * @return array
//     */
//    public static function getAllowedDirectivesForForm($allowed, $schema = null)
//    {
//        if (!$schema) {
//            $schema = HTMLPurifier_ConfigSchema::instance();
//        }
//        if ($allowed !== true) {
//            if (is_string($allowed)) {
//                $allowed = array($allowed);
//            }
//            $allowed_ns = array();
//            $allowed_directives = array();
//            $blacklisted_directives = array();
//            foreach ($allowed as $ns_or_directive) {
//                if (strpos($ns_or_directive, '.') !== false) {
//                    // directive
//                    if ($ns_or_directive[0] == '-') {
//                        $blacklisted_directives[substr($ns_or_directive, 1)] = true;
//                    } else {
//                        $allowed_directives[$ns_or_directive] = true;
//                    }
//                } else {
//                    // namespace
//                    $allowed_ns[$ns_or_directive] = true;
//                }
//            }
//        }
//        $ret = array();
//        foreach ($schema->info as $key => $def) {
//            list($ns, $directive) = explode('.', $key, 2);
//            if ($allowed !== true) {
//                if (isset($blacklisted_directives["$ns.$directive"])) {
//                    continue;
//                }
//                if (!isset($allowed_directives["$ns.$directive"]) && !isset($allowed_ns[$ns])) {
//                    continue;
//                }
//            }
//            if (isset($def->isAlias)) {
//                continue;
//            }
//            if ($directive == 'DefinitionID' || $directive == 'DefinitionRev') {
//                continue;
//            }
//            $ret[] = array($ns, $directive);
//        }
//        return $ret;
//    }
//
//    /**
//     * Loads configuration values from $_GET/$_POST that were posted
//     * via ConfigForm
//     *
//     * @param array $array $_GET or $_POST array to import
//     * @param string|bool $index Index/name that the config variables are in
//     * @param array|bool $allowed List of allowed namespaces/directives
//     * @param bool $mq_fix Boolean whether or not to enable magic quotes fix
//     * @param HTMLPurifier_ConfigSchema $schema Schema to use, if not global copy
//     *
//     * @return mixed
//     */
//    public static function loadArrayFromForm($array, $index = false, $allowed = true, $mq_fix = true, $schema = null)
//    {
//        $ret = HTMLPurifier_Config::prepareArrayFromForm($array, $index, $allowed, $mq_fix, $schema);
//        $config = HTMLPurifier_Config::create($ret, $schema);
//        return $config;
//    }
//
//    /**
//     * Merges in configuration values from $_GET/$_POST to object. NOT STATIC.
//     *
//     * @param array $array $_GET or $_POST array to import
//     * @param string|bool $index Index/name that the config variables are in
//     * @param array|bool $allowed List of allowed namespaces/directives
//     * @param bool $mq_fix Boolean whether or not to enable magic quotes fix
//     */
//    public function mergeArrayFromForm($array, $index = false, $allowed = true, $mq_fix = true)
//    {
//        $ret = HTMLPurifier_Config::prepareArrayFromForm($array, $index, $allowed, $mq_fix, $this->def);
//        $this->loadArray($ret);
//    }
//
//    /**
//     * Prepares an array from a form into something usable for the more
//     * strict parts of HTMLPurifier_Config
//     *
//     * @param array $array $_GET or $_POST array to import
//     * @param string|bool $index Index/name that the config variables are in
//     * @param array|bool $allowed List of allowed namespaces/directives
//     * @param bool $mq_fix Boolean whether or not to enable magic quotes fix
//     * @param HTMLPurifier_ConfigSchema $schema Schema to use, if not global copy
//     *
//     * @return array
//     */
//    public static function prepareArrayFromForm($array, $index = false, $allowed = true, $mq_fix = true, $schema = null)
//    {
//        if ($index !== false) {
//            $array = (isset($array[$index]) && is_array($array[$index])) ? $array[$index] : array();
//        }
//        $mq = $mq_fix && function_exists('get_magic_quotes_gpc') && get_magic_quotes_gpc();
//
//        $allowed = HTMLPurifier_Config::getAllowedDirectivesForForm($allowed, $schema);
//        $ret = array();
//        foreach ($allowed as $key) {
//            list($ns, $directive) = $key;
//            $skey = "$ns.$directive";
//            if (!empty($array["Null_$skey"])) {
//                $ret[$ns][$directive] = null;
//                continue;
//            }
//            if (!isset($array[$skey])) {
//                continue;
//            }
//            $value = $mq ? stripslashes($array[$skey]) : $array[$skey];
//            $ret[$ns][$directive] = $value;
//        }
//        return $ret;
//    }



/**
 * Checks whether or not the configuration object is finalized.
 *
 * @param string|bool $error String error message, or false for no error
 *
 * @return bool
 */
- (BOOL)isFinalized:(NSError*)error
{
    if (_finalized && error) {
        TRIGGER_ERROR(@"%@", error);
    }
    return _finalized;
}

/**
 * Finalizes configuration only if auto finalize is on and not
 * already finalized
 */
- (void)autoFinalize
{
    [self finalize];
}

/**
 * Finalizes a configuration object, prohibiting further change
 */
- (void)finalize
{
    _finalized = YES;
    _parser = nil;
}


/**
 * Returns a serialized form of the configuration object that can
 * be reconstituted.
 *
 * @return string
 */
- (NSString*)serialize
{
    [self getDefinition:@"HTML"];
    [self getDefinition:@"CSS"];
    [self getDefinition:@"URI"];
    return serialize(self);
}




@end
