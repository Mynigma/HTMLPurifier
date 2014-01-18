//
//  HTMLPurifier_AttrTransform_ImgRequired.h
//  HTMLPurifier
//
//  Created by Roman Priebe on 18.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_AttrTransform.h"

@interface HTMLPurifier_AttrTransform_ImgRequired : HTMLPurifier_AttrTransform


- (NSArray*)transform:(NSDictionary*)attr config:(HTMLPurifier_Config*)config context:(HTMLPurifier_Context*)context;


@end
