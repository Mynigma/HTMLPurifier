//
//   HTMLPurifier_ChildDef_Chameleon.m
//   HTMLPurifier
//
//  Created by Roman Priebe on 18.01.14.


#import "HTMLPurifier_ChildDef_Chameleon.h"
#import "HTMLPurifier_ChildDef_Optional.h"
#import "HTMLPurifier_Config.h"
#import "HTMLPurifier_Context.h"


@implementation HTMLPurifier_ChildDef_Chameleon


- (id)initWithInline:(NSArray*)inlineArray block:(NSArray*)blockArray
{
    self = [super init];
    if (self) {
        self.typeString = @"chameleon";

        self.inlineDef = [[HTMLPurifier_ChildDef_Optional alloc] initWithElements:inlineArray];
        self.block = [[HTMLPurifier_ChildDef_Optional alloc] initWithElements:blockArray];
        self.elements = self.block.elements;
    }
    return self;
}

- (id)init
{
    return [self initWithInline:@[] block:@[]];
}

/**
 * @param array $children
 * @param HTMLPurifier_Config $config
 * @param HTMLPurifier_Context $context
 * @return array
 */
- (NSObject*)validateChildren:(NSArray*)children config:(HTMLPurifier_Config *)config context:(HTMLPurifier_Context *)context
{
    if(![(NSNumber*)[context getWithName:@"IsInline"] boolValue])
    {
        return [self.block validateChildren:children config:config context:context];
    }
    else
    {
        return [self.inlineDef validateChildren:children config:config context:context];
    }
}

//    /**
//     * @param HTMLPurifier_Node[] $children
//     * @param HTMLPurifier_Config $config
//     * @param HTMLPurifier_Context $context
//     * @return bool
//     */
//    public function validateChildren($children, $config, $context)
//    {
//        if ($context->get('IsInline') === false) {
//            return $this->block->validateChildren(
//                                                  $children,
//                                                  $config,
//                                                  $context
//                                                  );
//        } else {
//            return $this->inline->validateChildren(
//                                                   $children,
//                                                   $config,
//                                                   $context
//                                                   );
//        }
//    }


@end
