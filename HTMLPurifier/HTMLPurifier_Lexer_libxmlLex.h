//
//  HTMLPurifier_Lexer_libxmlLex.h
//  HTMLPurifier
//
//  Created by Roman Priebe on 12.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_Lexer.h"

@class HTMLPurifier_TokenFactory, HTMLPurifier_Token, xmlNode;

@interface HTMLPurifier_Lexer_libxmlLex : HTMLPurifier_Lexer
{
    /**
     * @type HTMLPurifier_TokenFactory
     */
    HTMLPurifier_TokenFactory* factory;
}

- (id)init;

    /**
     * @param string $html
     * @param HTMLPurifier_Config $config
     * @param HTMLPurifier_Context $context
     * @return HTMLPurifier_Token[]
     */
- (NSArray*)tokenizeHTMLWithString:(NSString *)string config:(NSString *)config context:(NSString *)context;

     /**
      * Iterative function that tokenizes a node, putting it into an accumulator.
      * To iterate is human, to recurse divine - L. Peter Deutsch
      * @param DOMNode $node DOMNode to be tokenized.
      * @param HTMLPurifier_Token[] $tokens   Array-list of already tokenized tokens.
      * @return HTMLPurifier_Token of node appended to previously passed tokens.
      */
- (HTMLPurifier_Token*)tokenizeDOMNode:(xmlNode*)node tokens:(NSArray*)tokens;
     /**
      * @param DOMNode $node DOMNode to be tokenized.
      * @param HTMLPurifier_Token[] $tokens   Array-list of already tokenized tokens.
      * @param bool $collect  Says whether or start and close are collected, set to
      *                    false at first recursion because it's the implicit DIV
      *                    tag you're dealing with.
      * @return bool if the token needs an endtoken
      * @todo data and tagName properties don't seem to exist in DOMNode?
      */
- (BOOL)createStartNode:(xmlNode*)node tokens:(NSMutableArray*)tokens collect:(BOOL)collect;                                   

                                    /**
                                     * @param DOMNode $node
                                     * @param HTMLPurifier_Token[] $tokens
                                     */
- (void)createEndNode:(xmlNode*)node tokens:(NSMutableArray*)tokens;


                                    /**
                                     * Converts a DOMNamedNodeMap of DOMAttr objects into an assoc array.
                                     *
                                     * @param DOMNamedNodeMap $node_map DOMNamedNodeMap of DOMAttr objects.
                                     * @return array Associative array of attributes.
                                     */
- (NSDictionary*)transformAttrToAssoc:node_map;

                                    /**
                                     * Callback function for undoing escaping of stray angled brackets
                                     * in comments
                                     * @param array $matches
                                     * @return string
                                     */
- (NSString*)callbackUndoCommentSubst:(NSArray*)matches;

                                    /**
                                     * Callback function that entity-izes ampersands in comments so that
                                     * callbackUndoCommentSubst doesn't clobber them
                                     * @param array $matches
                                     * @return string
                                     */
- (NSString*)callbackArmorCommentEntities:(NSArray*)matches;

                                    /**
                                     * Wraps an HTML fragment in the necessary HTML
                                     * @param string $html
                                     * @param HTMLPurifier_Config $config
                                     * @param HTMLPurifier_Context $context
                                     * @return string
                                     */
                                    - (NSString*)wrapHTML:(NSString*)html config:(HTMLPurifier_Config*)config context:(HTMLPurifier_Context*)context;

@end
