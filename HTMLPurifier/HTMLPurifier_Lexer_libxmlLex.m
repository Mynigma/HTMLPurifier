//
//  HTMLPurifier_Lexer_libxmlLex.m
//  HTMLPurifier
//
//  Created by Roman Priebe on 12.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_Lexer_libxmlLex.h"
#import "HTMLPurifier_TokenFactory.h"
#import "BasicPHP.h"
#import "HTMLPurifier_TokenFactory.h"
#import <libxml/HTMLparser.h>
#import <libxml/xmlmemory.h>

@implementation HTMLPurifier_Lexer_libxmlLex

- (id)init
{
    self = [super init];
    if (self) {
        factory = [HTMLPurifier_TokenFactory new];
    }
    return self;
}

    /**
     * @param string $html
     * @param HTMLPurifier_Config $config
     * @param HTMLPurifier_Context $context
     * @return HTMLPurifier_Token[]
     */
- (NSArray*)tokenizeHTMLWithString:(NSString *)string config:(NSString *)config context:(NSString *)context
    {
        NSString* html = [self normalizeWithHtml:string config:config context:context];

        // attempt to armor stray angled brackets that cannot possibly
        // form tags and thus are probably being used as emoticons
        //if ($config->get('Core.AggressivelyFixLt'))
        {
            NSString* chars = @"[^a-z!\\/]";
            NSString* comment = @"/<!--(.*?)(-->|\\z)/is";
            html = [BasicPHP pregReplace:comment callback:[self callbackArmorCommentEntities] haystack:html];
            NSString* old = @"";
            do {
                old = html;
                html = preg_replace([NSString stringWithFormat:@"/<(%@)/i", chars], @"&lt;\\1", html);
            } while (![html isEqualToString:old]);
            html = preg_replace_callback(comment, [self callbackUndoCommentSubst], html); // fix comments
        }

        // preprocess html, essential for UTF-8
        html = [self wrapHTMLWithHtml:html config:config context:context];


        NSMutableArray* tokens = [NSMutableArray new];

        CFStringEncoding cfenc = CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding);
        CFStringRef cfencstr = CFStringConvertEncodingToIANACharSetName(cfenc);
        const char *enc = CFStringGetCStringPtr(cfencstr, 0);
        // _doc = htmlParseDoc((xmlChar*)[string UTF8String], enc);
        int optionsHtml = HTML_PARSE_RECOVER;
        optionsHtml = optionsHtml | HTML_PARSE_NOERROR; //Uncomment this to see HTML errors
        optionsHtml = optionsHtml | HTML_PARSE_NOWARNING;
        doc = htmlReadDoc ((xmlChar*)[string UTF8String], NULL, enc, optionsHtml);

        [self tokenizeDOM:                           $doc->getElementsByTagName('html')->item(0)-> // <html>
                           getElementsByTagName('body')->item(0)-> //   <body>
                           getElementsByTagName('div')->item(0), //     <div>
                           $tokens
                           );
        return tokens;
    }

    /**
     * Iterative function that tokenizes a node, putting it into an accumulator.
     * To iterate is human, to recurse divine - L. Peter Deutsch
     * @param DOMNode $node DOMNode to be tokenized.
     * @param HTMLPurifier_Token[] $tokens   Array-list of already tokenized tokens.
     * @return HTMLPurifier_Token of node appended to previously passed tokens.
     */
- (HTMLPurifier_Token*)tokenizeDOMNode:(xmlNode*)node tokens:(NSArray*)tokens
    {
        NSNumber* level = @0;
        NSMutableDictionary* nodes = @{level: HTMLPurifier_Queue(array($node))};
        NSMutableArray* closingNodes = [NSMutableArray new];
        do {
            while ([nodes objectForKey:level]) {
                node = [[nodes objectForKey:level] shift]; // FIFO
                BOOL collect = level.integerValue > 0 ? true : false;
                BOOL needEndingTag = [self createStartNode:node tokens:tokens collect:collect];
                if (needEndingTag) {
                    [[closingNodes objectForKey:level] addObject:node];
                }
                if ([node childNodes] && [node childNodes].length) {
                    level = @(level.integerValue+1);
                    [nodes setObject:[HTMLPurifier_Queue new] forKey:level];
                    for(xmlNode* childNode in [node childNodes])
                    {
                        [[nodes objectForKey:level] push:childNode];
                    }
                }
            }
            level = @(level.integerValue-1);
            if (level && [closingNodes objectForKey:level]) {
                while (node = array_pop([closingNodes objectForKey:level])) {
                    [self createEndNode:node tokens:tokens];
                }
            }
        } while (level.integerValue > 0);
    }

    /**
     * @param DOMNode $node DOMNode to be tokenized.
     * @param HTMLPurifier_Token[] $tokens   Array-list of already tokenized tokens.
     * @param bool $collect  Says whether or start and close are collected, set to
     *                    false at first recursion because it's the implicit DIV
     *                    tag you're dealing with.
     * @return bool if the token needs an endtoken
     * @todo data and tagName properties don't seem to exist in DOMNode?
     */
- (BOOL)createStartNode:(xmlNode*)node tokens:(NSMutableArray*)tokens collect:(BOOL)collect
    {
        // intercept non element nodes. WE MUST catch all of them,
        // but we're not getting the character reference nodes because
        // those should have been preprocessed
        if (node.type === XML_TEXT_NODE) {
            [tokens addObject:[self.factory createText:node->data]]);
            return NO;
        } else if ([nodetype] == XML_CDATA_SECTION_NODE) {
            // undo libxml's special treatment of <script> and <style> tags
            HTMLPurifierToken* last = [tokens objectAtIndex:tokens.length-1];
            data = $node->data;
            // (note $node->tagname is already normalized)
            if ([last isKindOfClass:[HTMLPurifier_Token_Start]] && ([last.name isEqual:@"script"] || [last.name isEqual:@"style"]))
            {
                $new_data = trim($data);
                if (substr($new_data, 0, 4) === '<!--') {
                    $data = substr($new_data, 4);
                    if (substr($data, -3) === '-->') {
                        $data = substr($data, 0, -3);
                    } else {
                        // Highly suspicious! Not sure what to do...
                    }
                }
            }
            [tokens addObject:[[self factory] createText:[self parseDataWithString:data]]];
            return NO;
        } else if ([node type] === XML_COMMENT_NODE) {
            // this is code is only invoked for comments in script/style in versions
            // of libxml pre-2.6.28 (regular comments, of course, are still
            // handled regularly)
            [tokens addObject:[self.factory createComment:node.data]];
            return NO;
        } else if (node.type != XML_ELEMENT_NODE) {
            // not-well tested: there may be other nodes we have to grab
            return NO;
        }

        NSArray* attr = node->hasAttributes() ? [self transformAttrToAssoc:node->attributes] : @[];

        // We still have to make sure that the element actually IS empty
        if (!node->childNodes->length) {
            if (collect) {
                [tokens addObject:[self.factory createEmpty:$node->tagName attr:attr]];
            }
            return NO;
        } else {
            if (collect) {
                [tokens addObject:[self.factory createStart(
                                                        $tag_name = $node->tagName, // somehow, it get's dropped
                                                        $attr
                                                        );
            }
            return true;
        }
    }

    /**
     * @param DOMNode $node
     * @param HTMLPurifier_Token[] $tokens
     */
- (void)createEndNode:(xmlNode*)node tokens:(NSMutableArray*)tokens
    {
        [tokens addObject:[self.factory createEnd:node->tagName]];
    }


    /**
     * Converts a DOMNamedNodeMap of DOMAttr objects into an assoc array.
     *
     * @param DOMNamedNodeMap $node_map DOMNamedNodeMap of DOMAttr objects.
     * @return array Associative array of attributes.
     */
- (NSDictionary*)transformAttrToAssoc:node_map
    {
        // NamedNodeMap is documented very well, so we're using undocumented
        // features, namely, the fact that it implements Iterator and
        // has a ->length attribute
        if ($node_map->length === 0) {
            return array();
        }
        $array = array();
        foreach ($node_map as $attr) {
            $array[$attr->name] = $attr->value;
        }
        return $array;
    }

    /**
     * Callback function for undoing escaping of stray angled brackets
     * in comments
     * @param array $matches
     * @return string
     */
- (NSString*)callbackUndoCommentSubst:(NSArray*)matches
    {
        return [NSString stringWithFormat:@"<!--%@%@", strtr(matches[1], @{@"&amp;" : @"&", @"&lt;" : @"<"}) . matches[2]];
    }

    /**
     * Callback function that entity-izes ampersands in comments so that
     * callbackUndoCommentSubst doesn't clobber them
     * @param array $matches
     * @return string
     */
- (NSString*)callbackArmorCommentEntities:(NSArray*)matches
    {
        return [NSString stringWithFormat:@"<!--%@%@", str_replace(@"&", @"&amp;", matches[1]), matches[2]];
    }

    /**
     * Wraps an HTML fragment in the necessary HTML
     * @param string $html
     * @param HTMLPurifier_Config $config
     * @param HTMLPurifier_Context $context
     * @return string
     */
- (NSString*)wrapHTML:(NSString*)html config:(HTMLPurifier_Config*)config context:(HTMLPurifier_Context*)context
    {
        HTMLPurifier_Definition* def = [HTMLPurifier_Definition new];

        NSMutableString* ret = [NSMutableString new];
        if ([[def doctype] dtdPublic]) || [[def doctype] dtdSystem])) {
            [ret appendString:@"<!DOCTYPE html "];
            if ([[def doctype] dtdPublic]) {
                [ret appendFormat:@"PUBLIC \"%@\" ", [[def doctype] dtdPublic]];
            }
            if ([[def doctype] dtdSystem])) {
                [ret appendFormat:@"\"%@\" ", [[def doctype] dtdSystem]];
            }
            [ret appendString:@">"];
        }
        
        [ret appendString:@"<html><head>"];
        [ret appendString:@"<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />"];
        // No protection if $html contains a stray </div>!
        [ret appendFormat:@"</head><body><div>%@</div></body></html>", html];
        return ret;
}
                                   
@end
