//
//  HTMLPurifier_DefinitionCacheFactory.m
//  HTMLPurifier
//
//  Created by Roman Priebe on 15.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_DefinitionCacheFactory.h"


static HTMLPurifier_DefinitionCacheFactory* theFactory;

@implementation HTMLPurifier_DefinitionCacheFactory

- (id)init
{
    self = [super init];
    if (self) {
        caches = [@{@"Serializer":@[]} mutableCopy];
        implementations = [NSMutableDictionary new];
        decorators = [NSMutableDictionary new];
    }
    return self;
}

+ (HTMLPurifier_DefinitionCacheFactory*)instance
{
    if(!theFactory)
    {
        theFactory = [HTMLPurifier_DefinitionCacheFactory new];
        [theFactory setup];
    }
    return theFactory;
}

+ (HTMLPurifier_DefinitionCacheFactory*)instanceWithPrototype:(HTMLPurifier_DefinitionCacheFactory*)prototype
{
    if(prototype)
        return prototype;

    return [HTMLPurifier_DefinitionCacheFactory instance];
}

-(void)setup
{
    [self addDecorator:@"Cleanup"];
}

/**
 * Factory method that creates a cache object based on configuration
 * @param string $type Name of definitions handled by cache
 * @param HTMLPurifier_Config $config Config instance
 * @return mixed
 */
- (NSObject*)create:(NSString*)type config:(HTMLPurifier_Config *)config
{
    return nil;

    /*
    $method = $config->get('Cache.DefinitionImpl');
    if ($method === null) {
        return new HTMLPurifier_DefinitionCache_Null($type);
    }
    if (!empty($this->caches[$method][$type])) {
        return $this->caches[$method][$type];
    }
    if (isset($this->implementations[$method]) &&
        class_exists($class = $this->implementations[$method], false)) {
        $cache = new $class($type);
    } else {
        if ($method != 'Serializer') {
            trigger_error("Unrecognized DefinitionCache $method, using Serializer instead", E_USER_WARNING);
        }
        $cache = new HTMLPurifier_DefinitionCache_Serializer($type);
    }
    foreach ($this->decorators as $decorator) {
        $new_cache = $decorator->decorate($cache);
        // prevent infinite recursion in PHP 4
        unset($cache);
        $cache = $new_cache;
    }
    $this->caches[$method][$type] = $cache;
    return $this->caches[$method][$type];*/
}


- (void)addDecorator:(NSString*)decorator
{
    /*
    HTMLPurifier_DefinitionCache_Decorator* decorator;
    if ([decorator isKindOfClass:[NSString class]])
    {
        NSString* className = [NSString stringWithFormat:@"HTMLPurifier_DefinitionCache_Decorator_%@", decorator];
        decorator = [NSClassFromString(className) new];
        [self decorators[decorator.name] = decorator;
     }*/
}

- (void)registerWithShortName:(NSString*)shortName longName:(NSString*)longName
{

}

@end
