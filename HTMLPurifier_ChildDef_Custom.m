//
//  HTMLPurifier_ChildDef_Custom.m
//  HTMLPurifier
//
//  Created by Roman Priebe on 19.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_ChildDef_Custom.h"

@implementation HTMLPurifier_ChildDef_Custom


- (id)initWithDtdRegex:(NSString*)new_dtd_regex
{
    self = [super init];
    if (self) {
        self.typeString = @"custom";
        self.allow_empty = NO;

        self.dtd_regex = new_dtd_regex;
        [self _compileRegex];
    }
    return self;
}

    /**
     * Compiles the PCRE regex from a DTD regex ($dtd_regex to $_pcre_regex)
     */
- (void)_compileRegex
    {
//        $raw = str_replace(' ', '', $this->dtd_regex);
//        if ($raw{0} != '(') {
//            $raw = "($raw)";
//        }
//        $el = '[#a-zA-Z0-9_.-]+';
//        $reg = $raw;
//
//        // COMPLICATED! AND MIGHT BE BUGGY! I HAVE NO CLUE WHAT I'M
//        // DOING! Seriously: if there's problems, please report them.
//
//        // collect all elements into the $elements array
//        preg_match_all("/$el/", $reg, $matches);
//        foreach ($matches[0] as $match) {
//            $this->elements[$match] = true;
//        }
//
//        // setup all elements as parentheticals with leading commas
//        $reg = preg_replace("/$el/", '(,\\0)', $reg);
//
//        // remove commas when they were not solicited
//        $reg = preg_replace("/([^,(|]\(+),/", '\\1', $reg);
//
//        // remove all non-paranthetical commas: they are handled by first regex
//        $reg = preg_replace("/,\(/", '(', $reg);
//
//        $this->_pcre_regex = $reg;
    }

    /**
     * @param HTMLPurifier_Node[] $children
     * @param HTMLPurifier_Config $config
     * @param HTMLPurifier_Context $context
     * @return bool
     */
- (NSObject*)validateChildren:(NSArray*)children config:(HTMLPurifier_Config*)config context:(HTMLPurifier_Context*)context
    {
        return nil;
//        $list_of_children = '';
//        $nesting = 0; // depth into the nest
//        foreach ($children as $node) {
//            if (!empty($node->is_whitespace)) {
//                continue;
//            }
//            $list_of_children .= $node->name . ',';
//        }
//        // add leading comma to deal with stray comma declarations
//        $list_of_children = ',' . rtrim($list_of_children, ',');
//        $okay =
//        preg_match(
//                   '/^,?' . $this->_pcre_regex . '$/',
//                   $list_of_children
//                   );
//        return (bool)$okay;
    }



@end
