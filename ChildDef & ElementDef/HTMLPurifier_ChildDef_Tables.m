//
//  HTMLPurifier_ChildDef_Tables.m
//  HTMLPurifier
//
//  Created by Roman Priebe on 18.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_ChildDef_Tables.h"
#import "HTMLPurifier_Node.h"
#import "HTMLPurifier_Node_Comment.h"
#import "HTMLPurifier_Node_Element.h"


/**
 * Definition for tables.  The general idea is to extract out all of the
 * essential bits, and then reconstruct it later.
 *
 * This is a bit confusing, because the DTDs and the W3C
 * validators seem to disagree on the appropriate definition. The
 * DTD claims:
 *
 *      (CAPTION?, (COL*|COLGROUP*), THEAD?, TFOOT?, TBODY+)
 *
 * But actually, the HTML4 spec then has this to say:
 *
 *      The TBODY start tag is always required except when the table
 *      contains only one table body and no table head or foot sections.
 *      The TBODY end tag may always be safely omitted.
 *
 * So the DTD is kind of wrong.  The validator is, unfortunately, kind
 * of on crack.
 *
 * The definition changed again in XHTML1.1; and in my opinion, this
 * formulation makes the most sense.
 *
 *      caption?, ( col* | colgroup* ), (( thead?, tfoot?, tbody+ ) | ( tr+ ))
 *
 * Essentially, we have two modes: thead/tfoot/tbody mode, and tr mode.
 * If we encounter a thead, tfoot or tbody, we are placed in the former
 * mode, and we *must* wrap any stray tr segments with a tbody. But if
 * we don't run into any of them, just have tr tags is OK.
 */
@implementation HTMLPurifier_ChildDef_Tables


- (id)init
{
    self = [super init];
    if (self) {
        self.allow_empty = NO;
        self.typeString = @"table";
        self.elements = [@{@"tr":@YES,@"tbody":@YES,@"thead":@YES,@"tfoot":@YES,@"caption":@YES,@"colgroup":@YES,@"col":@YES} mutableCopy];

    }
    return self;
}



    /**
     * @param array $children
     * @param HTMLPurifier_Config $config
     * @param HTMLPurifier_Context $context
     * @return array
     */
- (NSObject*)validateChildren:(NSArray*)children config:(HTMLPurifier_Config *)config context:(HTMLPurifier_Context *)context
    {
        if (children.count==0) {
            return nil;
        }

        // only one of these elements is allowed in a table
        HTMLPurifier_Node* caption = nil;
        HTMLPurifier_Node* thead = nil;
        HTMLPurifier_Node* tfoot = nil;

        // whitespace
        NSMutableArray* initial_ws = [NSMutableArray new];
        NSMutableArray* after_caption_ws = [NSMutableArray new];
        NSMutableArray* after_thead_ws = [NSMutableArray new];
        NSMutableArray* after_tfoot_ws = [NSMutableArray new];

        // as many of these as you want
        NSMutableArray* cols = [NSMutableArray new];
        NSMutableArray* content = [NSMutableArray new];

        BOOL tbody_mode = NO; // if true, then we need to wrap any stray
                             // <tr>s with a <tbody>.

        NSMutableArray* ws_accum = initial_ws;

        for(HTMLPurifier_Node* node in children)
        {
            if ([node isKindOfClass:[HTMLPurifier_Node_Comment class]])
            {
                [ws_accum addObject:node];
                continue;
            }
            NSString* name = [node valueForKey:@"name"];
            if([name isEqual:@"tbody"])
            {
                    tbody_mode = YES;
                [content addObject:node];
                ws_accum = content;

            }
            else if([name isEqual:@"tr"])
            {
                [content addObject:node];
                    ws_accum = content;
            }
            else if([name isEqual:@"caption"])
            {
                    // there can only be one caption!
                    if (caption)
                        break;
                    caption = node;
                    ws_accum = after_caption_ws;
            }
            else if([name isEqual:@"thead"])
            {
                    tbody_mode = YES;
                    // XXX This breaks rendering properties with
                    // Firefox, which never floats a <thead> to
                    // the top. Ever. (Our scheme will float the
                    // first <thead> to the top.)  So maybe
                    // <thead>s that are not first should be
                    // turned into <tbody>? Very tricky, indeed.
                    if (!thead) {
                        thead = node;
                        ws_accum = after_thead_ws;
                    } else {
                        // Oops, there's a second one! What
                        // should we do?  Current behavior is to
                        // transmutate the first and last entries into
                        // tbody tags, and then put into content.
                        // Maybe a better idea is to *attach
                        // it* to the existing thead or tfoot?
                        // We don't do this, because Firefox
                        // doesn't float an extra tfoot to the
                        // bottom like it does for the first one.
                        node.name = @"tbody";
                        [content addObject:node];
                        ws_accum = content;
                    }
            }
            else if([name isEqual:@"tfoot"])
            {
                // see above for some aveats
                    tbody_mode = YES;
                    if (!tfoot) {
                        tfoot = node;
                        ws_accum = after_tfoot_ws;
                    } else {
                        node.name = @"tbody";
                        [content addObject:node];
                        ws_accum = content;
                    }
            }
            else if([name isEqual:@"colgroup"] || [name isEqual:@"col"])
            {
                    [cols addObject:node];
                    ws_accum = cols;
            }
            else if([name isEqual:@"#PCDATA"])
            {
                    // How is whitespace handled? We treat is as sticky to
                    // the *end* of the previous element. So all of the
                    // nonsense we have worked on is to keep things
                    // together.
                    if(node.isWhitespace)
                    {
                        [ws_accum addObject:node];
                    }
                    break;
            }
        }

        if (!content) {
            return nil;
        }

        NSMutableArray* ret = initial_ws;
        if (caption) {
            [ret addObject:caption];
            [ret addObjectsFromArray:after_caption_ws];
        }
        if (cols) {
            [ret addObjectsFromArray:cols];
        }
        if (thead) {
            [ret addObject:thead];
            [ret addObjectsFromArray:after_thead_ws];
        }
        if (tfoot) {
            [ret addObject:tfoot];
            [ret addObjectsFromArray:after_tfoot_ws];
        }

        if (tbody_mode)
        {
            // we have to shuffle tr into tbody
            HTMLPurifier_Node_Element* current_tr_tbody = nil;

            for(HTMLPurifier_Node_Element* node in content)
            {
                if([[node valueForKey:@"name"] isEqual:@"tbody"])
                {
                        current_tr_tbody = nil;
                        [ret addObject:node];
                }
                else if([[node valueForKey:@"name"] isEqual:@"tr"])
                {
                    if (!current_tr_tbody)
                        {
                            current_tr_tbody = [[HTMLPurifier_Node_Element alloc] initWithName:@"tbody"];
                            [ret addObject:current_tr_tbody];
                        }
                        [current_tr_tbody.children addObject:node];
                }
                else if([[node valueForKey:@"name"] isEqual:@"#PCDATA"])
                {
                        assert([node valueForKey:@"is_whitespace"]);
                        if (!current_tr_tbody) {
                            [ret addObject:node];
                        } else {
                            [current_tr_tbody.children addObject:node];
                        }
                }
            }
        } else {
            if (content)
                [ret addObjectsFromArray:content];
        }
        
        return ret;
        
    }





@end
