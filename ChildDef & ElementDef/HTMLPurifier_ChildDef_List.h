//
//  HTMLPurifier_ChildDef_List.h
//  HTMLPurifier
//
//  Created by Roman Priebe on 18.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_ChildDef.h"

@interface HTMLPurifier_ChildDef_List : HTMLPurifier_ChildDef


- (NSObject*)validateChildren:(NSArray*)children config:(HTMLPurifier_Config *)config context:(HTMLPurifier_Context *)context;

@end
