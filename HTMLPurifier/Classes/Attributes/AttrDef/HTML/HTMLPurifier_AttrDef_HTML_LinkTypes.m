//
//   HTMLPurifier_AttrDef_HTML_LinkTypes.m
//   HTMLPurifier
//
//  Created by Lukas Neumann on 12.01.14.


#import "HTMLPurifier_AttrDef_HTML_LinkTypes.h"
#import "HTMLPurifier.h"
#import "BasicPHP.h"

@implementation HTMLPurifier_AttrDef_HTML_LinkTypes

/**
 * Name config attribute to pull.
 * @type string
 */
@synthesize name;

/**
 * @param string $name
 */
-(id) initWithName:(NSString*)newName
{
    self = [super init];
    NSDictionary* configLookup = @{@"rel":@"AllowedRel", @"rev":@"AllowedRev"};
    
    if (!([newName isEqual:@"rel"] || [newName isEqual:@"rev"]))
    {
        TRIGGER_ERROR(@"Unrecognized attribute name for link relationship.");
        return nil;
    }
    name = [configLookup objectForKey:newName];
    return self;
}

/**
 * @param string $string
 * @param HTMLPurifier_Config $config
 * @param HTMLPurifier_Context $context
 * @return bool|string
 */
-(NSString*) validateWithString:(NSString *)string config:(HTMLPurifier_Config *)config context:(HTMLPurifier_Context *)context
{
    NSArray* allowed = (NSArray*)[config get:[NSString stringWithFormat:@"Attr.%@",name]];
    
    //Not sure if allowed can be equal @"", since it should be an NSArray
    if (!allowed || ![allowed isKindOfClass:[NSArray class]] || [allowed count] == 0)
    {
        return nil;
    }
    
    string = [self parseCDATAWithString:string];
    NSArray* parts = explode(@" ",string);
    
    // lookup to prevent duplicates
    NSMutableArray* ret_lookup = [NSMutableArray new];
    
    for (NSString* part in parts)
    {
        NSString* thisPart = [part mutableCopy];
        thisPart = [trim(thisPart) lowercaseString];
        if (![allowed containsObject:thisPart])
        {
            continue;
        }
        [ret_lookup addObject:thisPart];
    }
    
    if ([ret_lookup count] == 0)
    {
        return nil;
    }
    string = implode(@" ",ret_lookup);
    return string;
}

@end
