//
//   HTMLPurifier_ChildDef_StrictBlockquote.m
//   HTMLPurifier
//
//  Created by Lukas Neumann on 24.01.14.


#import "HTMLPurifier_ChildDef_StrictBlockquote.h"
#import "HTMLPurifier_Config.h"
#import "HTMLPurifier_HTMLDefinition.h"
#import "HTMLPurifier_Node.h"
#import "HTMLPurifier_Node_Text.h"
#import "HTMLPurifier_Node_Element.h"

/**
 * Takes the contents of blockquote when in strict and reformats for validation.
 */
@implementation HTMLPurifier_ChildDef_StrictBlockquote

@synthesize real_elements;

@synthesize fake_elements;

@synthesize allow_empty; // = true;

@synthesize type; // = 'strictblockquote';

@synthesize setup; // = false;


-(id) init
{
    self = [super init];
    allow_empty = true;
    type = @"strictblockquote";
    setup = false;
    return self;
}

/**
 * @param HTMLPurifier_Config $config
 * @return array
 * @note We don't want MakeWellFormed to auto-close inline elements since
 *       they might be allowed.
 */
-(NSMutableDictionary*) getAllowedElements:(HTMLPurifier_Config*)config
{
    [self setup:config];
    return fake_elements;
}

/**
 * @param array $children
 * @param HTMLPurifier_Config $config
 * @param HTMLPurifier_Context $context
 * @return array
 */
- (NSObject*)validateChildren:(NSArray *)children config:(HTMLPurifier_Config *)config context:(HTMLPurifier_Context *)context
{
    [self setup:config];
    
    // trick the parent class into thinking it allows more
    self.elements = fake_elements;
    NSObject* result = [super validateChildren:children config:config context:context];
    self.elements = real_elements;
    
    if (result == false)
    {
        return @[];
    }
    if ((BOOL)result == true)
    {
        result = children;
    }
    
    HTMLPurifier_HTMLDefinition* def = [config getHTMLDefinition];
    // unused NSString* block_wrap_name = [def info_block_wrapper];
    NSMutableArray* ret = [NSMutableArray new];
    
    HTMLPurifier_Node_Element* block_wrap;
    
    for (HTMLPurifier_Node* node in (NSArray*)result)
    {
        if (block_wrap)
        {
            if (([node isKindOfClass:[HTMLPurifier_Node_Text class]] && ![node isWhitespace]) ||
                ([node isKindOfClass:[HTMLPurifier_Node_Element class]] && !self.elements[[node name]]))
            {
                block_wrap = [[HTMLPurifier_Node_Element alloc]
                                                              initWithName:[def info_block_wrapper]];
                [ret addObject:block_wrap];
            }
        }
        else
        {
            if ([node isKindOfClass:[HTMLPurifier_Node_Element class]] && self.elements[[node name]])
            {
                block_wrap = nil;
            }
        }
        if (block_wrap)
        {
            [[block_wrap children] addObject:node];
        }
        else
        {
            [ret addObject:node];
        }
    }
    return ret;
}

/**
 * @param HTMLPurifier_Config $config
 */
-(void) setup:(HTMLPurifier_Config*)config
{
    if (!setup)
    {
        HTMLPurifier_HTMLDefinition* def = [config getHTMLDefinition];
        // allow all inline elements
        real_elements = self.elements;
        
        NSSet* set = [def info_content_sets][@"Flow"];
        fake_elements = [NSMutableDictionary new];
        
        for (NSString* key in set)
        {
            [fake_elements setObject:@YES forKey:key];
        }
        
        fake_elements[@"#PCDATA"] = @YES;
        setup = true;
    }
}


@end
