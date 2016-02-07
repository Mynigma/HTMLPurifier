//
//   HTMLPurifier_Generator.m
//   HTMLPurifier
//
//  Created by Lukas Neumann on 10.01.14.


#import "HTMLPurifier_Generator.h"
#import "HTMLPurifier_Context.h"
#import "HTMLPurifier_Config.h"
#import "HTMLPurifier_Token.h"
#import "HTMLPurifier_HTMLDefinition.h"
#import "HTMLPurifier_Doctype.h"
#import "HTMLPurifier_Token_End.h"
#import "HTMLPurifier_Token_Start.h"
#import "HTMLPurifier_Token_Empty.h"
#import "HTMLPurifier_Token_Text.h"
#import "HTMLPurifier_Token_Comment.h"
#import "HTMLPurifier_FlashStackObject.h"
#import "BasicPHP.h"


#define ENT_NOQUOTES @"ENT_NOQUOTES"

/**
 * Generates HTML from tokens.
 * @todo Refactor interface so that configuration/context is determined
 *       upon instantiation, no need for messy generateFromTokens() calls
 * @todo Make some of the more internal functions protected, and have
 *       unit tests work around that
 */
@implementation HTMLPurifier_Generator
{
    /**
     * Whether or not generator should produce XML output.
     * @type bool
     */
    NSNumber* _xhtml;

    /**
     * :HACK: Whether or not generator should comment the insides of <script> tags.
     * @type bool
     */
    NSNumber* _scriptFix;

    /**
     * Cache of HTMLDefinition during HTML output to determine whether or
     * not attributes should be minimized.
     * @type HTMLPurifier_HTMLDefinition
     */
    HTMLPurifier_HTMLDefinition* _def;

    /**
     * Cache of %Output.SortAttr.
     * @type bool
     */
    NSNumber* _sortAttr;

    /**
     * Cache of %Output.FlashCompat.
     * @type bool
     */
    NSNumber* _flashCompat;

    /**
     * Cache of %Output.FixInnerHTML.
     * @type bool
     */
    NSNumber* _innerHTMLFix;

    /**
     * Stack for keeping track of object information when outputting IE
     * compatibility code.
     * @type array
     */
    NSMutableArray* _flashStack;

    /**
     * Configuration for the generator
     * @type HTMLPurifier_Config
     */
    HTMLPurifier_Config* config;
}


- (id)initWithConfig:(HTMLPurifier_Config *)newConfig context:(HTMLPurifier_Context *)newContext
{
    self = [super init];
    if (self) {
        _flashStack = [NSMutableArray new];
        config = newConfig;
        _scriptFix = (NSNumber*)[config get:@"Output.CommentScriptContents"];
        _innerHTMLFix = (NSNumber*)[config get:@"Output.FixInnerHTML"];
        _sortAttr = (NSNumber*)[config get:@"Output.SortAttr"];
        _flashCompat = (NSNumber*)[config get:@"Output.FlashCompat"];
        _def = [config getHTMLDefinition];
        _xhtml = [[_def doctype] xml];
    }
    return self;
}

- (id)init
{
    return [self initWithConfig:nil context:nil];
}


    /**
     * Generates HTML from an array of tokens.
     * @param HTMLPurifier_Token[] $tokens Array of HTMLPurifier_Token
     * @return string Generated HTML
     */
- (NSString*)generateFromTokens:(NSArray*)passedTokens
    {
        if ([passedTokens count]==0) {
            return @"";
        }

        NSMutableArray* tokens = [passedTokens mutableCopy];

        // Basic algorithm
        NSMutableString* html = [NSMutableString new];
        NSInteger totalNumber = tokens.count;
        for (NSInteger i = 0; i < totalNumber; i++) {
            if (_scriptFix.boolValue && [[tokens[i] valueForKey:@"name"] isEqualToString:@"script"]
                && i + 2 < totalNumber && [tokens[i+2] isKindOfClass:[HTMLPurifier_Token_End class]]) {
                // script special case
                // the contents of the script block must be ONE token
                // for this to work.
                [html appendString:[self generateFromToken:tokens[i++]]];
                [html appendString:[self generateScriptFromToken:tokens[i++]]];
            }
            [html appendString:[self generateFromToken:tokens[i]]];
        }

        /*
        // Tidy cleanup
        if (extension_loaded(@"tidy") && $this->config->get('Output.TidyFormat')) {
            $tidy = new Tidy;
            $tidy->parseString(
                               $html,
                               array(
                                     'indent'=> true,
                                     'output-xhtml' => $this->_xhtml,
                                     'show-body-only' => true,
                                     'indent-spaces' => 2,
                                     'wrap' => 68,
                                     ),
                               'utf8'
                               );
            $tidy->cleanRepair();
            $html = (string) $tidy; // explicit cast necessary
        }


        // Normalize newlines to system defined value
        if ($this->config->get('Core.NormalizeNewlines')) {
            $nl = $this->config->get('Output.Newline');
            if ($nl === null) {
                $nl = PHP_EOL;
            }
            if ($nl !== "\n") {
                $html = str_replace("\n", $nl, $html);
            }
        }*/
        return html;
    }

    /**
     * Generates HTML from a single token.
     * @param HTMLPurifier_Token $token HTMLPurifier_Token object.
     * @return string Generated HTML
     */
- (NSString*)generateFromToken:(HTMLPurifier_Token*)token
    {
        if (![token isKindOfClass:[HTMLPurifier_Token class]])
        {
            TRIGGER_ERROR(@"Cannot generate HTML from non-HTMLPurifier_Token object");
            return @"";

        }
        if ([token isKindOfClass:[HTMLPurifier_Token_Start class]])
        {
            NSString* attrString = [self generateAttributes:[(HTMLPurifier_Token_Start*)token attr] sortedKeys:token.sortedAttrKeys element:[token valueForKey:@"name"]];
            if (_flashCompat.boolValue) {
                if ([[token valueForKey:@"name"] isEqualToString:@"object"])
                {
                    HTMLPurifier_FlashStackObject* flashStackObject = [HTMLPurifier_FlashStackObject new];
                    [flashStackObject setAttr:[(HTMLPurifier_Token_Start*)token attr]];
                    [flashStackObject setParam:[NSMutableDictionary new]];
                    [_flashStack addObject:flashStackObject];
                }
            }
            return [NSString stringWithFormat:@"<%@%@>", [token valueForKey:@"name"], ([attrString length]>0?[@" " stringByAppendingString:attrString]:@"")];
        } else if ([token isKindOfClass:[HTMLPurifier_Token_End class]])
        {
            NSString* _extra = @"";
            if (_flashCompat.boolValue) {
                if ([[token valueForKey:@"name"] isEqualToString:@"object"] && _flashStack.count>0) {
                    // doesn't do anything for now
                }
            }
            return [NSString stringWithFormat:@"%@</%@>", _extra, [token valueForKey:@"name"]];

        } else if ([token isKindOfClass:[HTMLPurifier_Token_Empty class]])
        {
            if (_flashCompat.boolValue && [[token valueForKey:@"name"] isEqualToString:@"param"] && _flashStack.count>0)
            {
                HTMLPurifier_FlashStackObject* flashStackObject = _flashStack[_flashStack.count-1];
                NSMutableDictionary* params = flashStackObject.param;
                NSString* key = [(HTMLPurifier_Token_Empty*)token attr][@"name"];
                NSObject* value = [(HTMLPurifier_Token_Empty*)token attr][@"value"];
                if (value && key)
                    [params setObject:value forKey:key];
            }
            NSString* attrString = [self generateAttributes:[(HTMLPurifier_Token_Empty*)token attr] sortedKeys:token.sortedAttrKeys element:[(HTMLPurifier_Token_Empty*)token name]];
            return [NSString stringWithFormat:@"<%@%@%@%@>", [(HTMLPurifier_Token_Empty*)token name], ([attrString length]>0?[NSString stringWithFormat:@" "]:@""), attrString, _xhtml.boolValue?@" /":@""];
        } else if ([token isKindOfClass:[HTMLPurifier_Token_Text class]])
        {
            return [self escape:[token valueForKey:@"data"] quote:ENT_NOQUOTES];

        } else if ([token isKindOfClass:[HTMLPurifier_Token_Comment class]])
        {
            return [NSString stringWithFormat:@"<!--%@-->", [(HTMLPurifier_Token_Comment*)token data]];
        } else {
            return @"";

        }
    }

    /**
     * Special case processor for the contents of script tags
     * @param HTMLPurifier_Token $token HTMLPurifier_Token object.
     * @return string
     * @warning This runs into problems if there's already a literal
     *          --> somewhere inside the script contents.
     */
- (NSString*)generateScriptFromToken:(HTMLPurifier_Token*)token
    {
        if (![token isKindOfClass:[HTMLPurifier_Token_Text class]])
        {
            return [self generateFromToken:token];
        }
        // Thanks <http://lachy.id.au/log/2005/05/script-comments>
        NSString* data = preg_replace_3(@"#//\\s*$#", @"", [token valueForKey:@"data"]);
        return [NSString stringWithFormat:@"<!--//--><![CDATA[//><!--\n%@\n//--><!]]>", trim(data)];
    }

    /**
     * Generates attribute declarations from attribute array.
     * @note This does not include the leading or trailing space.
     * @param array $assoc_array_of_attributes Attribute array
     * @param string $element Name of element attributes are for, used to check
     *        attribute minimization.
     * @return string Generated HTML fragment for insertion.
     */
- (NSString*)generateAttributes:(NSMutableDictionary*)assoc_array_of_attributes sortedKeys:(NSMutableArray*)sortedKeys
{
    return [self generateAttributes:assoc_array_of_attributes sortedKeys:sortedKeys element:@""];
}

- (NSString*)generateAttributes:(NSMutableDictionary*)assoc_array_of_attributes sortedKeys:(NSMutableArray *)sortedKeys element:(NSString *)element
    {
        NSMutableString* html = [NSMutableString new];
        /*if (_sortAttr) {
            ksort(assoc_array_of_attributes);
        }*/
        for(NSString* key in sortedKeys)
        {
            NSString* value = assoc_array_of_attributes[key];
            if(!value)
                continue;

            if (!_xhtml.boolValue) {
                // Remove namespaced attributes
                if ([key rangeOfString:@":"].location != NSNotFound) {
                    continue;
                }
                // Check if we should minimize the attribute: val="val" -> val
                if (element && key && [[[_def.info[element] attr][key] valueForKey:@"minimized"] respondsToSelector:@selector(count)] && [[[_def.info[element] attr][key] valueForKey:@"minimized"] count]>0) {
                    [html appendFormat:@"%@ ", key];
                    continue;
                }
            }
            // Workaround for Internet Explorer innerHTML bug.
            // Essentially, Internet Explorer, when calculating
            // innerHTML, omits quotes if there are no instances of
            // angled brackets, quotes or spaces.  However, when parsing
            // HTML (for example, when you assign to innerHTML), it
            // treats backticks as quotes.  Thus,
            //      <img alt="``" />
            // becomes
            //      <img alt=`` />
            // becomes
            //      <img alt='' />
            // Fortunately, all we need to do is trigger an appropriate
            // quoting style, which we do by adding an extra space.
            // This also is consistent with the W3C spec, which states
            // that user agents may ignore leading or trailing
            // whitespace (in fact, most don't, at least for attributes
            // like alt, but an extra space at the end is barely
            // noticeable).  Still, we have a configuration knob for
            // this, since this transformation is not necesary if you
            // don't process user input with innerHTML or you don't plan
            // on supporting Internet Explorer.
            /*if (this->_innerHTMLFix) {
                if (strpos($value, '`') !== false) {
                    // check if correct quoting style would not already be
                    // triggered
                    if (strcspn($value, '"\' <>') === strlen($value)) {
                        // protect!
                        $value .= ' ';
                    }
                }
            }*/
            [html appendFormat:@"%@=\"%@\" ", key, [self escape:value]];
        }
        return rtrim(html);
    }

    /**
     * Escapes raw text data.
     * @todo This really ought to be protected, but until we have a facility
     *       for properly generating HTML here w/o using tokens, it stays
     *       public.
     * @param string $string String data to escape for HTML.
     * @param int $quote Quoting style, like htmlspecialchars. ENT_NOQUOTES is
     *               permissible for non-attribute output.
     * @return string escaped data.
     */
- (NSString*)escape:(NSString*)string
{
    return [self escape:string quote:nil];
}


- (NSString*)escape:(NSString*)string quote:(NSString *)quote
    {
        // Workaround for APC bug on Mac Leopard reported by sidepodcast
        // http://htmlpurifier.org/phorum/read.php?3,4823,4846
        if (!quote) {
            //quote = @"ENT_COMPAT";

            return htmlspecialchars_ENT_COMPAT(string);
        }

        return htmlspecialchars_ENT_NOQUOTES(string);
}


@end
