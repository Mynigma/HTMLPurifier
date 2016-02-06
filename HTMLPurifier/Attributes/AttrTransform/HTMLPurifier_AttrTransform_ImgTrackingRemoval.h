//
//  HTMLPurifier_AttrTransform_ImgTrackingRemoval.h
//  HTMLPurifier
//
//  Created by Lukas Neumann on 06.02.16.
//  Copyright © 2016 Mynigma. All rights reserved.
//

#import "HTMLPurifier_AttrTransform.h"


@interface HTMLPurifier_AttrTransform_ImgTrackingRemoval : HTMLPurifier_AttrTransform


- (NSDictionary*)transform:(NSDictionary*)attr sortedKeys:(NSMutableArray*)sortedKeys config:(HTMLPurifier_Config*)config context:(HTMLPurifier_Context*)context;


@end