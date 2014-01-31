//
//  HTMLPurifier_ChildDef_Custom.m
//  HTMLPurifier
//
//  Created by Roman Priebe on 19.01.14.


#import "HTMLPurifier_ChildDef_Custom.h"
#import "BasicPHP.h"
#import "HTMLPurifier_Node.h"

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
        NSString* raw = (NSString*)str_replace(@" ", @"", self.dtd_regex);
        if ([raw characterAtIndex:0] != '(')
        {
            raw = @"($raw)";
        }
        NSString* el = @"[#a-zA-Z0-9_.-]+";
        NSString* reg = raw;

        // COMPLICATED! AND MIGHT BE BUGGY! I HAVE NO CLUE WHAT I'M
        // DOING! Seriously: if there's problems, please report them.

        // collect all elements into the $elements array
        NSMutableArray* matches = [NSMutableArray new];
        preg_match_all_3(el, reg, matches);
        if(matches.count>0 && [matches[0] isKindOfClass:[NSArray class]])
            for(NSString* match in matches[0])
            {
                self.elements[match] = @YES;
            }

        // setup all elements as parentheticals with leading commas
        reg = preg_replace_3(el, @"(,\\0)", reg);

        // remove commas when they were not solicited
        reg = preg_replace_3(@"([^,(|]\(+),", @"\\1", reg);

        // remove all non-paranthetical commas: they are handled by first regex
        reg = preg_replace_3(@"/,\(/", @"(", reg);

        _pcre_regex = reg;
    }

    /**
     * @param HTMLPurifier_Node[] $children
     * @param HTMLPurifier_Config $config
     * @param HTMLPurifier_Context $context
     * @return bool
     */
- (NSObject*)validateChildren:(NSArray*)children config:(HTMLPurifier_Config*)config context:(HTMLPurifier_Context*)context
    {
        NSMutableString* list_of_children = [NSMutableString new];
        //NSInteger nesting = 0; // depth into the nest
        for(HTMLPurifier_Node* node in children)
        {
            if (!node.isWhitespace)
            {
                continue;
            }
            [list_of_children appendFormat:@"%@,", node.name];
        }
        // add leading comma to deal with stray comma declarations
        list_of_children = [NSMutableString stringWithFormat:@",%@,", rtrim([list_of_children copy])];
        BOOL okay = preg_match_2([NSString stringWithFormat:@"^,?%@$", _pcre_regex], list_of_children);
        return okay?@YES:nil;
    }



@end
