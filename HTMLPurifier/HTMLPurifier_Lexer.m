//
//  HTMLPurifier_Lexer.m
//  HTMLPurifier
//
//  Created by Lukas Neumann on 10.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_Lexer.h"
#import "HTMLPurifier_Lexer_libxmlLex.h"
#import "BasicPHP.h"
#import "HTMLPurifier_Config.h"
#import "HTMLPurifier_Context.h"
#import "HTMLPurifier_Encoder.h"

@implementation HTMLPurifier_Lexer

/*
- (id)init
{
    self = [super init];
    if (self) {
        tracksLineNumbers = NO;
    }
    return self;
}*/


+ (HTMLPurifier_Lexer*)createWithConfig:(HTMLPurifier_Config*)config
{
    HTMLPurifier_Lexer* inst = [HTMLPurifier_Lexer_libxmlLex new];

    return inst;
}

// -- CONVENIENCE MEMBERS ---------------------------------------------

- (id)init
{
    self = [super init];
    if (self) {
        tracksLineNumbers = NO;
        _entity_parser = [HTMLPurifier_EntityParser new];
        /**
         * Most common entity to raw value conversion table for special entities.
         * @type array
         */
        _special_entity2str = @{@"&quot;":@"\"", @"&amp;":@"&", @"&lt;":@"<", @"&gt;":@">", @"&#39;":@"'", @"&#039;":@"'", @"&#x27":@"'"};
    }
    return self;
}

/**
 * Parses special entities into the proper characters.
 *
 * This string will translate escaped versions of the special characters
 * into the correct ones.
 *
 * @warning
 * You should be able to treat the output of this function as
 * completely parsed, but that's only because all other entities should
 * have been handled previously in substituteNonSpecialEntities()
 *
 * @param string $string String character data to be parsed.
 * @return string Parsed character data.
 */
- (NSString*)parseDataWithString:(NSString*)string
{
    // following functions require at least one character
    if ([string isEqualToString:@""]) {
        return @"";
    }

    // subtracts amps that cannot possibly be escaped
    NSInteger numAmp = substr_count(string, @"&") - substr_count(string, @"& ") -
    (([string characterAtIndex:string.length - 1] == '&') ? 1 : 0);

    if (numAmp==0)
    {
        return string;
    } // abort if no entities
    NSInteger numEscAmp = substr_count(string, @"&amp;");
    string = strtr_php(string, self._special_entity2str);

    // code duplication for sake of optimization, see above
    NSInteger numAmp2 = substr_count(string, @"&") - substr_count(string, @"& ") -
    (([string characterAtIndex:string.length - 1] == '&') ? 1 : 0);

    if (numAmp2 <= numEscAmp) {
        return string;
    }

    // hmm... now we have some uncommon entities. Use the callback.
    string = [[self _entity_parser] substituteSpecialEntitiesWith:string];
    return string;
}

/**
 * Lexes an HTML string into tokens.
 * @param $string String HTML.
 * @param HTMLPurifier_Config $config
 * @param HTMLPurifier_Context $context
 * @return HTMLPurifier_Token[] array representation of HTML.
 */
- (NSArray*)tokenizeHTMLWithString:(NSString*)string config:(NSString*)config context:(NSString*)context
{
   TRIGGER_ERROR(@"Call to abstract class");
}

/**
 * Translates CDATA sections into regular sections (through escaping).
 * @param string $string HTML string to process.
 * @return string HTML with CDATA sections escaped.
 */
- (NSString*)escapeCDATAWithString:(NSString*)string
{
    return [BasicPHP pregReplace:@"/<!\\[CDATA\\[(.+?)\\]\\]>/s" callback:[HTMLPurifier_Lexer CDataCallback] haystack:string];
}

/**
 * Special CDATA case that is especially convoluted for <script>
 * @param string $string HTML string to process.
 * @return string HTML with CDATA sections escaped.
 */
- (NSString*)escapeCommentedCDATAWithString:(NSString*)string
{
    return [BasicPHP pregReplace:@"#<!--//--><!\\[CDATA\[//><!--(.+?)//--><!\\]\\]>#s" callback:[HTMLPurifier_Lexer CDataCallback] haystack:string];
}

/**
 * Special Internet Explorer conditional comments should be removed.
 * @param string $string HTML string to process.
 * @return string HTML with conditional comments removed.
 */
- (NSString*)removeIEConditionalWithString:string
{
    return preg_replace(@"#<!--\\[if [^>]+\\]>.*?<!\\[endif\\]-->#si", // probably should generalize for all strings
                        @"", string);
}

/**
 * Callback function for escapeCDATA() that does the work.
 *
 * @warning Though this is public in order to let the callback happen,
 *          calling it directly is not recommended.
 * @param array $matches PCRE matches array, with index 0 the entire match
 *                  and 1 the inside of the CDATA section.
 * @return string Escaped internals of the CDATA section.
 */
- (NSString*) CDATACallback:(NSArray*)matches
{
    // not exactly sure why the character set is needed, but whatever
    return htmlspecialchars($matches[1], ENT_COMPAT, 'UTF-8');
}

/**
 * Takes a piece of HTML and normalizes it by converting entities, fixing
 * encoding, extracting bits, and other good stuff.
 * @param string $html HTML.
 * @param HTMLPurifier_Config $config
 * @param HTMLPurifier_Context $context
 * @return string
 * @todo Consider making protected
 */
- (NSString*)normalizeWithHtml:(NSString*)html config:(HTMLPurifier_Config*)config context:(HTMLPurifier_Context*)context
{
    /*
    // normalize newlines to \n
    if ($config->get('Core.NormalizeNewlines')) {
        $html = str_replace("\r\n", "\n", $html);
        $html = str_replace("\r", "\n", $html);
    }

    if ($config->get('HTML.Trusted')) {
        // escape convoluted CDATA
        $html = $this->escapeCommentedCDATA($html);
    }*/


    // escape CDATA
    NSString* html = [self escapeCDATAWithHtml:html];

    html = [self removeIEConditionalWithHtml:html];

    /*
    // extract body from document if applicable
    if ($config->get('Core.ConvertDocumentToFragment')) {
        $e = false;
        if ($config->get('Core.CollectErrors')) {
            $e =& $context->get('ErrorCollector');
        }
        $new_html = $this->extractBody($html);
        if ($e && $new_html != $html) {
            $e->send(E_WARNING, 'Lexer: Extracted body');
        }
        $html = $new_html;
    }*/

    // expand entities that aren't the big five
    html = [self._entity_parser substituteNonSpecialEntitiesWithHtml:html];

    // clean into wellformed UTF-8 string for an SGML context: this has
    // to be done after entity expansion because the entities sometimes
    // represent non-SGML characters (horror, horror!)
    html = [HTMLPurifier_Encoder cleanUTF8WithHtml:html];

    // if processing instructions are to removed, remove them now
    //if ($config->get('Core.RemoveProcessingInstructions')) {
    html = preg_replace(@"#<\\?.+?\\?>#s", @"", html);
    // }

    return html;
}

/**
 * Takes a string of HTML (fragment or document) and returns the content
 * @todo Consider making protected
 */
- (NSString*)extractBodyWithHtml:html
{
    NSMutableArray* matches = [NSMutableArray new];
    NSString* result = preg_match(@"!<body[^>]*>(.*)</body>!is", html, matches);
    if (result) {
        return matches[1];
    } else {
        return html;
    }
}


@end
