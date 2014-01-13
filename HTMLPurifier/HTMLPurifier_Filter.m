//
//  HTMLPurifier_Filter.m
//  HTMLPurifier
//
//  Created by Lukas Neumann on 10.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_Filter.h"
#import "HTMLPurifier_Config.h"
#import "HTMLPurifier_Context.h"


@implementation HTMLPurifier_Filter

    /**
     * Pre-processor function, handles HTML before HTML Purifier
     * @param string $html
     * @param HTMLPurifier_Config $config
     * @param HTMLPurifier_Context $context
     * @return string
     */
    - (NSString*)preFilter:(NSString*)html config:(HTMLPurifier_Config*)config context:(HTMLPurifier_Context*)context
    {
        return html;
    }

    /**
     * Post-processor function, handles HTML after HTML Purifier
     * @param string $html
     * @param HTMLPurifier_Config $config
     * @param HTMLPurifier_Context $context
     * @return string
     */
    - (NSString*)postFilter:(NSString*)html config:(HTMLPurifier_Config*)config context:(HTMLPurifier_Context*)context
    {
        return html;
    }



@end
