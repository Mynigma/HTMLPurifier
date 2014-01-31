//
//  HTMLPurifier_AttrDef_HTML_ID.m
//  HTMLPurifier
//
//  Created by Lukas Neumann on 11.01.14.


#import "HTMLPurifier_AttrDef_HTML_ID.h"
#import "BasicPHP.h"
#import "HTMLPurifier_IDAccumulator.h"

/**
 * Validates the HTML attribute ID.
 * @warning Even though this is the id processor, it
 *          will ignore the directive Attr:IDBlacklist, since it will only
 *          go according to the ID accumulator. Since the accumulator is
 *          automatically generated, it will have already absorbed the
 *          blacklist. If you're hacking around, make sure you use load()!
 */

@implementation HTMLPurifier_AttrDef_HTML_ID


// selector is NOT a valid thing to use for IDREFs, because IDREFs
// *must* target IDs that exist, whereas selector #ids do not.

/**
 * Determines whether or not we're validating an ID in a CSS
 * selector context.
 * @type bool
 */
@synthesize selector;


-(id) init
{
    self = [super init];
    selector = @NO;
    return self;
}
/**
 * @param bool selector
 */
-(id) initWithSelector:(NSNumber*)newSelector
{
    self = [super init];
    if (newSelector)
    {
        selector = newSelector;
    }
    else
    {
        selector = @NO;
    }
    return self;
}

/**
 * @param string $id
 * @param HTMLPurifier_Config $config
 * @param HTMLPurifier_Context $context
 * @return bool|string
 */
-(NSString*) validateWithString:(NSString*)ID config:(HTMLPurifier_Config*)config context:(HTMLPurifier_Context*)context
{
    if (!selector.boolValue && ![(NSNumber*)[config get:@"Attr.EnableID"] boolValue])
    {
        return nil;
    }
    
    ID = trim(ID); // trim it first
    
    if ([ID isEqual:@""])
    {
        return nil;
    }

    NSString* prefix = (NSString*)[config get:@"Attr.IDPrefix"];
    if (prefix && prefix.length>0)
    {
        NSString* localPrefix = (NSString*)[config get:@"Attr.IDPrefixLocal"];
        if(localPrefix)
            prefix = [prefix stringByAppendingString:localPrefix];
        // prevent re-appending the prefix
        if (strpos(ID, prefix) != 0)
        {
            ID = [prefix stringByAppendingString:ID];
        }
    }
    else if ([config get:@"Attr.IDPrefixLocal"] && ![[config get:@"Attr.IDPrefixLocal"] isEqual:@""])
    {
        TRIGGER_ERROR(@"Attr.IDPrefixLocal cannot be used unless Attr.IDPrefix is set");
    }
    
    HTMLPurifier_IDAccumulator* id_accumulator;
    if ([selector isEqual:@NO])
    {
        id_accumulator = (HTMLPurifier_IDAccumulator*)[context getWithName:@"IDAccumulator"];
        
        //CONTAINS?
        if (id_accumulator.ids[ID])
        {
            return nil;
        }
    }
    
    // we purposely avoid using regex, hopefully this is faster
    BOOL result;
    
    if (ctype_alpha(ID))
    {
         result = YES;
        
    } else
    {
        if (!ctype_alpha([NSString stringWithFormat:@"%c",[ID characterAtIndex:0]]))
    {
        return nil;
    }
        NSMutableCharacterSet* characterSet = [NSMutableCharacterSet new];
        [characterSet addCharactersInRange:NSMakeRange('a', 'z' - 'a' + 1)];
        [characterSet addCharactersInRange:NSMakeRange('0', '9' - '0' + 1)];
        [characterSet addCharactersInString:@":-._"];
        NSString* trim = trimCharacters(ID, characterSet);
        result = ([trim isEqual:@""]);
    }
    
    NSString* regexp = (NSString*)[config get:@"Attr.IDBlacklistRegexp"];

    //Preg_match returns Array. TODO
    if (regexp && preg_match_2(regexp, ID))
    {
        return nil;
    }
    
    if ([selector isEqual:@NO] && result)
    {
        [id_accumulator addWithID:ID];
    }
    
    // if no change was made to the ID, return the result
    // else, return the new id if stripping whitespace made it
    //     valid, or return false.
    return result ? ID : nil;
}


@end
