//
//  HTMLPurifier_AttrDef_CSS_FontFamily.m
//  HTMLPurifier
//
//  Created by Roman Priebe on 14.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_AttrDef_CSS_FontFamily.h"
#import "BasicPHP.h"
#import "HTMLPurifier_Config.h"
#import "HTMLPurifier_Context.h"

@implementation HTMLPurifier_AttrDef_CSS_FontFamily


- (id)init
{
    self = [super init];
    if (self) {
        mask = [@"_- " mutableCopy];
        for(unichar c='a'; c<'z'; c++)
            [mask appendFormat:@"%c", c];
        for(unichar c='A'; c<'Z'; c++)
            [mask appendFormat:@"%c", c];
        for(unichar c='0'; c<'9'; c++)
            [mask appendFormat:@"%c", c];
        for (NSInteger i = 0x80; i <= 0xFF; i++) {
            // We don't bother excluding invalid bytes in this range,
            // because the our restriction of well-formed UTF-8 will
            // prevent these from ever occurring.
            [mask appendFormat:@"%c", (unichar)i];
        }

    }
    return self;
}

     /**
     * @param string $string
     * @param HTMLPurifier_Config $config
     * @param HTMLPurifier_Context $context
     * @return bool|string
     */
- (NSString*)validateWithString:(NSString*)string config:(HTMLPurifier_Config*)config context:(HTMLPurifier_Context*)context
    {
        NSDictionary* generic_names = @{@"serif" : @YES,
                                      @"sans-serif" : @YES,
                                      @"monospace" : @YES,
                                      @"fantasy" : @YES,
                                      @"cursive" : @YES
                                        };
        NSDictionary* allowed_fonts = (NSDictionary*)[config get:@"CSS.AllowedFonts"];

        // assume that no font names contain commas in them
        NSArray* fonts = explode(@",", string);
        NSMutableString* final = [NSMutableString new];
        for(NSString* someFont in fonts)
        {
            NSString* font = trim(someFont);
            if ([font isEqual:@""]) {
                continue;
            }
            // match a generic name
            if (generic_names[font]) {
                if (!allowed_fonts || allowed_fonts[font]) {
                    [final appendFormat:@"%@, ", font];
                }
                continue;
            }
            // match a quoted name
            if ([font characterAtIndex:0] == '"' || [font characterAtIndex:0] == '\'') {
                NSInteger length = font.length;
                if (length <= 2) {
                    continue;
                }
                unichar quote = [font characterAtIndex:0];
                if ([font characterAtIndex:length - 1] != quote) {
                    continue;
                }
                font = [font substringWithRange:NSMakeRange(1, length - 2)];
            }

            font = [self expandCSSEscapeWithString:font];

            // font is a pure representation of the font name

            if (allowed_fonts && !allowed_fonts[font]) {
                continue;
            }

            if (ctype_alnum(font) && ![font isEqual:@""]) {
                // very simple font, allow it in unharmed
                [final appendFormat:@"%@, ", font];
                continue;
            }

            // bugger out on whitespace.  form feed (0C) really
            // shouldn't show up regardless
            font = (NSString*)str_replace(@[@"\n", @"\t", @"\r", @"\x0C"], @" ", font);

            // Here, there are various classes of characters which need
            // to be treated differently:
            //  - Alphanumeric characters are essentially safe.  We
            //    handled these above.
            //  - Spaces require quoting, though most parsers will do
            //    the right thing if there aren't any characters that
            //    can be misinterpreted
            //  - Dashes rarely occur, but they fairly unproblematic
            //    for parsing/rendering purposes.
            //  The above characters cover the majority of Western font
            //  names.
            //  - Arbitrary Unicode characters not in ASCII.  Because
            //    most parsers give little thought to Unicode, treatment
            //    of these codepoints is basically uniform, even for
            //    punctuation-like codepoints.  These characters can
            //    show up in non-Western pages and are supported by most
            //    major browsers, for example: "Ôº≠Ôº≥ ÊòéÊúù" is a
            //    legitimate font-name
            //    <http://ja.wikipedia.org/wiki/MS_ÊòéÊúù>.  See
            //    the CSS3 spec for more examples:
            //    <http://www.w3.org/TR/2011/WD-css3-fonts-20110324/localizedfamilynames.png>
            //    You can see live samples of these on the Internet:
            //    <http://www.google.co.jp/search?q=font-family+Ôº≠Ôº≥+ÊòéÊúù|„Ç¥„Ç∑„ÉÉ„ÇØ>
            //    However, most of these fonts have ASCII equivalents:
            //    for example, 'MS Mincho', and it's considered
            //    professional to use ASCII font names instead of
            //    Unicode font names.  Thanks Takeshi Terada for
            //    providing this information.
            //  The following characters, to my knowledge, have not been
            //  used to name font names.
            //  - Single quote.  While theoretically you might find a
            //    font name that has a single quote in its name (serving
            //    as an apostrophe, e.g. Dave's Scribble), I haven't
            //    been able to find any actual examples of this.
            //    Internet Explorer's cssText translation (which I
            //    believe is invoked by innerHTML) normalizes any
            //    quoting to single quotes, and fails to escape single
            //    quotes.  (Note that this is not IE's behavior for all
            //    CSS properties, just some sort of special casing for
            //    font-family).  So a single quote *cannot* be used
            //    safely in the font-family context if there will be an
            //    innerHTML/cssText translation.  Note that Firefox 3.x
            //    does this too.
            //  - Double quote.  In IE, these get normalized to
            //    single-quotes, no matter what the encoding.  (Fun
            //    fact, in IE8, the 'content' CSS property gained
            //    support, where they special cased to preserve encoded
            //    double quotes, but still translate unadorned double
            //    quotes into single quotes.)  So, because their
            //    fixpoint behavior is identical to single quotes, they
            //    cannot be allowed either.  Firefox 3.x displays
            //    single-quote style behavior.
            //  - Backslashes are reduced by one (so \\ -> \) every
            //    iteration, so they cannot be used safely.  This shows
            //    up in IE7, IE8 and FF3
            //  - Semicolons, commas and backticks are handled properly.
            //  - The rest of the ASCII punctuation is handled properly.
            // We haven't checked what browsers do to unadorned
            // versions, but this is not important as long as the
            // browser doesn't /remove/ surrounding quotes (as IE does
            // for HTML).
            //
            // With these results in hand, we conclude that there are
            // various levels of safety:
            //  - Paranoid: alphanumeric, spaces and dashes(?)
            //  - International: Paranoid + non-ASCII Unicode
            //  - Edgy: Everything except quotes, backslashes
            //  - NoJS: Standards compliance, e.g. sod IE. Note that
            //    with some judicious character escaping (since certain
            //    types of escaping doesn't work) this is theoretically
            //    OK as long as innerHTML/cssText is not called.
            // We believe that international is a reasonable default
            // (that we will implement now), and once we do more
            // extensive research, we may feel comfortable with dropping
            // it down to edgy.

            // Edgy: alphanumeric, spaces, dashes, underscores and Unicode.  Use of
            // str(c)spn assumes that the string was already well formed
            // Unicode (which of course it is).
            if (strspn_2(font, mask) != font.length)
            {
                continue;
            }

            // Historical:
            // In the absence of innerHTML/cssText, these ugly
            // transforms don't pose a security risk (as \\ and \"
            // might--these escapes are not supported by most browsers).
            // We could try to be clever and use single-quote wrapping
            // when there is a double quote present, but I have choosen
            // not to implement that.  (NOTE: you can reduce the amount
            // of escapes by one depending on what quoting style you use)
            // font = str_replace('\\', '\\5C ', font);
            // font = str_replace('"',  '\\22 ', font);
            // font = str_replace("'",  '\\27 ', font);
            
            // font possibly with spaces, requires quoting
            [final appendFormat:@"'%@', ", font];
        }
        final = [rtrim_2(final, @", ") mutableCopy];
        if ([final isEqual:@""]) {
            return nil;
        }
        return final;
    }

@end
