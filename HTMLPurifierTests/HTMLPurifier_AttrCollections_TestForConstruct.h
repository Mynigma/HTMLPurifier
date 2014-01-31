//
//   HTMLPurifier_AttrCollections_TestForConstruct.h
//   HTMLPurifier
//
//  Created by Roman Priebe on 22.01.14.


#import "HTMLPurifier_AttrCollections.h"
#import "HTMLPurifier_AttrTypes.h"

@interface HTMLPurifier_AttrCollections_TestForConstruct : HTMLPurifier_AttrCollections

- (void)performInclusions:(NSMutableDictionary*)attr;

- (void)expandIdentifiers:(NSMutableDictionary*)attr attrTypes:(HTMLPurifier_AttrTypes*)attr_types;

@end
