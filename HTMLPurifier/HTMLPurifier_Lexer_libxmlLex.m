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
#import "HTMLPurifier_Config.h"
#import "HTMLPurifier_Context.h"
#import "HTMLPurifier_Queue.h"
#import "HTMLPurifier_Token.h"
#import "HTMLPurifier_Token_Start.h"
#import "HTMLPurifier_HTMLDefinition.h"
#import "HTMLPurifier_Doctype.h"
#import "HTMLPurifier_DOMNode.h"



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
- (NSArray*)tokenizeHTMLWithString:(NSString*)string config:(HTMLPurifier_Config*)config context:(HTMLPurifier_Context*)context
{
    NSString* html = [self normalizeWithHtml:string config:config context:context];

    // attempt to armor stray angled brackets that cannot possibly
    // form tags and thus are probably being used as emoticons
    //if ($config->get('Core.AggressivelyFixLt'))
    {
        NSString* chars = @"[^a-z!\\/]";
        NSString* comment = @"/<!--(.*?)(-->|\\z)/is";
        html = [BasicPHP pregReplace:comment callback:^(NSArray* array)
                {
                    return [self callbackArmorCommentEntities:array];
                } haystack:html];
        NSString* old = @"";
        do {
            old = html;
            html = preg_replace_3([NSString stringWithFormat:@"<(%@)", chars], @"&lt;\\1", html);
        } while (html && ![html isEqualToString:old]);
        html = [BasicPHP pregReplace:comment callback:^(NSArray* array){ return [self callbackUndoCommentSubst:array]; } haystack:html]; // fix comments
    }

    // preprocess html, essential for UTF-8
    html = [self wrapHTML:html config:config context:context];


    NSMutableArray* tokens = [NSMutableArray new];

    CFStringEncoding cfenc = CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding);
    CFStringRef cfencstr = CFStringConvertEncodingToIANACharSetName(cfenc);
    const char *enc = CFStringGetCStringPtr(cfencstr, 0);
    // _doc = htmlParseDoc((xmlChar*)[string UTF8String], enc);
    int optionsHtml = HTML_PARSE_RECOVER;
    optionsHtml = optionsHtml;// | HTML_PARSE_NOERROR; //Uncomment this to see HTML errors
    optionsHtml = optionsHtml;// | HTML_PARSE_NOWARNING;
    htmlDocPtr doc = htmlReadDoc ((xmlChar*)[html UTF8String], NULL, enc, optionsHtml);

    HTMLPurifier_DOMNode* domNode = [self domifyXMLDoc:doc];

    [self tokenizeDOMNode:domNode tokens:tokens];

    return tokens;
}

/**
 * Iterative function that tokenizes a node, putting it into an accumulator.
 * To iterate is human, to recurse divine - L. Peter Deutsch
 * @param DOMNode $node DOMNode to be tokenized.
 * @param HTMLPurifier_Token[] $tokens   Array-list of already tokenized tokens.
 * @return HTMLPurifier_Token of node appended to previously passed tokens.
 */



//extracts the data from an xmlDoc and puts them into an ARC-controlled HTMLPurifier_DOMNode structure
- (HTMLPurifier_DOMNode*)domifyXMLDoc:(xmlDoc*)xmlDocument
{
    if(xmlDocument==NULL)
        return nil;

    if(xmlDocument->children)
    {
        xmlNode* docNode = xmlDocument->children;

        if(docNode->next)
        {
            xmlNode* htmlDiv = docNode->next;

            if(htmlDiv->children)
            {
                xmlNode* metaDiv = htmlDiv->children;

                if(metaDiv->next)
                {
                    xmlNode* bodyDiv = metaDiv->next;

                if(bodyDiv->children)
                {
                    xmlNode* divNode = bodyDiv->children;

                    return [self domifyXMLNode:divNode];
                }
                }
            }
        }
    }
    return nil;
}

- (HTMLPurifier_DOMNode*)domifyXMLNode:(xmlNode*)node
{
    HTMLPurifier_DOMNode* domNode = [HTMLPurifier_DOMNode new];
    if(node->content)
        [domNode setContent:[NSString stringWithCString:(char*)node->content encoding:NSUTF8StringEncoding]];
    if(node->name)
        [domNode setName:[NSString stringWithCString:(char*)node->name encoding:NSUTF8StringEncoding]];
    if(node->type)
        [domNode setType:node->type];
    if(node->properties)
        [domNode setAttr:[self transformAttrToAssoc:node->properties]];
    if(node->children)
    {
        xmlNode* child = node->children;

        NSMutableArray* newChildren = [NSMutableArray new];

        while(child)
        {
            [newChildren addObject:[self domifyXMLNode:child]];
            child = child->next;
        }
        [domNode setChildren:newChildren];
    }
    return domNode;
}


//TO DO: double-check
//PHP comment indicates return type HTMLPurifier_Token, but no value is returned!?!?!

- (void)tokenizeDOMNode:(HTMLPurifier_DOMNode*)n tokens:(NSMutableArray*)tokens
{
    NSNumber* level = @0;
    NSMutableDictionary* nodes = [@{level: [[HTMLPurifier_Queue alloc] initWithInput:@[n]]} mutableCopy];
    NSMutableDictionary* closingNodes = [NSMutableDictionary new];
    do {
        while ([nodes objectForKey:level] && ![[nodes objectForKey:level] isEmpty])
        {
            HTMLPurifier_DOMNode* node = (HTMLPurifier_DOMNode*)[(HTMLPurifier_Queue*)[nodes objectForKey:level] shift]; // FIFO

            BOOL collect = level.integerValue > 0 ? YES : NO;
            BOOL needEndingTag = [self createStartNode:node tokens:tokens collect:collect];
            if (needEndingTag) {
                NSMutableArray* newClosingNodes = closingNodes[level];
                if(!newClosingNodes)
                    newClosingNodes = [NSMutableArray new];
                [newClosingNodes addObject:node];
                closingNodes[level] = newClosingNodes;
            }
            if(node.children)
            {
                level = @(level.integerValue+1);
                [nodes setObject:[HTMLPurifier_Queue new] forKey:level];
                for(HTMLPurifier_DOMNode* childNode in node.children)
                {
                    [[nodes objectForKey:level] push:childNode];
                }
            }
        }
        level = @(level.integerValue-1);
        if (level && level.integerValue>0 && [closingNodes objectForKey:level])
        {
            HTMLPurifier_DOMNode* node = (HTMLPurifier_DOMNode*)array_pop([closingNodes objectForKey:level]);
            while (node) {
                [self createEndNode:node tokens:tokens];
                node = (HTMLPurifier_DOMNode*)array_pop([closingNodes objectForKey:level]);
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
- (BOOL)createStartNode:(HTMLPurifier_DOMNode*)node tokens:(NSMutableArray*)tokens collect:(BOOL)collect
{
    // intercept non element nodes. WE MUST catch all of them,
    // but we're not getting the character reference nodes because
    // those should have been preprocessed
    if (node.type == XML_TEXT_NODE) {
        [tokens addObject:[factory createTextWithData:node.content]];
        return NO;
    } else if (node.type == XML_CDATA_SECTION_NODE) {
        // undo libxml's special treatment of <script> and <style> tags
        HTMLPurifier_Token* last = [tokens objectAtIndex:tokens.count-1];
        NSString* data = node.content;
        // (note $node->tagname is already normalized)
        if ([last isKindOfClass:[HTMLPurifier_Token_Start class]] && ([[last valueForKey:@"name"] isEqual:@"script"] || [[last valueForKey:@"name"] isEqual:@"style"]))
        {
            NSMutableString* new_data = [trim(data) mutableCopy];
            if ([[new_data substringWithRange:NSMakeRange(0, 4)] isEqualTo:@"<!--"]) {
                data = substr(new_data, 4);
                if ([substr(data, -3) isEqualToString:@"-->"]) {
                    data = [data substringWithRange:NSMakeRange(data.length-3, 3)];
                } else {
                    // Highly suspicious! Not sure what to do...
                }
            }
        }
        [tokens addObject:[self->factory createTextWithData:[self parseDataWithString:data]]];
        return NO;
    } else if (node.type == XML_COMMENT_NODE) {
        // this is code is only invoked for comments in script/style in versions
        // of libxml pre-2.6.28 (regular comments, of course, are still
        // handled regularly)

        [tokens addObject:[self->factory createCommentWithData:node.content]];
        return NO;
    } else if (node.type != XML_ELEMENT_NODE) {
        // not-well tested: there may be other nodes we have to grab
        return NO;
    }

    NSMutableDictionary* attr = [node.attr mutableCopy];

    // We still have to make sure that the element actually IS empty

    if(!node.children)
    {
        if (collect) {
            NSString* name = node.name;
            [tokens addObject:[self->factory createEmptyWithName:name attr:attr]];
        }
        return NO;
    } else {
        if (collect) {
            NSString* name = node.name;
            [tokens addObject:[self->factory createStartWithName:name attr:attr]];
        }
        return true;
    }
}

/**
 * @param DOMNode $node
 * @param HTMLPurifier_Token[] $tokens
 */
- (void)createEndNode:(HTMLPurifier_DOMNode*)node tokens:(NSMutableArray*)tokens
{
    [tokens addObject:[self->factory createEndWithName:node.name]];
}


/**
 * Converts a DOMNamedNodeMap of DOMAttr objects into an assoc array.
 *
 * @param DOMNamedNodeMap $node_map DOMNamedNodeMap of DOMAttr objects.
 * @return array Associative array of attributes.
 */
- (NSDictionary*)transformAttrToAssoc:(xmlAttr*)properties
{
    NSMutableDictionary* propertiesLookup = [NSMutableDictionary new];
    while(properties)
    {
        NSString* name = [NSString stringWithCString:(char*)properties->name encoding:NSUTF8StringEncoding];

        //TO DO:
        //IS THIS RIGHT?!?!?!?
        NSString* value = [NSString stringWithCString:(char*)properties->children->content encoding:NSUTF8StringEncoding];
        if(name && value)
            propertiesLookup[name] = value;
        else
            TRIGGER_ERROR(@"Parse error: trying to assign propertiesLookup[%@] = %@", name, value);
        properties = properties->next;
    }
    return propertiesLookup;
}

/**
 * Callback function for undoing escaping of stray angled brackets
 * in comments
 * @param array $matches
 * @return string
 */
- (NSString*)callbackUndoCommentSubst:(NSArray*)matches
{
    return [NSString stringWithFormat:@"<!--%@%@", strtr_php(matches[1], @{@"&amp;" : @"&", @"&lt;" : @"<"}), matches[2]];
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
    //HTMLPurifier_HTMLDefinition* def = [config getDefinition:@"HTML"];
    HTMLPurifier_HTMLDefinition* def = (HTMLPurifier_HTMLDefinition*)[HTMLPurifier_HTMLDefinition new];

    NSMutableString* ret = [NSMutableString new];
    if ([[def doctype] dtdPublic] || [[def doctype] dtdSystem]) {
        [ret appendString:@"<!DOCTYPE html "];
        if ([[def doctype] dtdPublic])
        {
            [ret appendFormat:@"PUBLIC \"%@\" ", [[def doctype] dtdPublic]];
        }
        if ([[def doctype] dtdSystem])
        {
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
