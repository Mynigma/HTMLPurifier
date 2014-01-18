//
//  HTMLPurifier_Strategy_RemoveForeignElements.m
//  HTMLPurifier
//
//  Created by Roman Priebe on 13.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_Strategy_RemoveForeignElements.h"
#import "HTMLPurifier_Config.h"
#import "HTMLPurifier_Generator.h"
#import "HTMLPurifier_HTMLDefinition.h"
#import "HTMLPurifier_AttrValidator.h"
#import "HTMLPurifier_Context.h"
#import "HTMLPurifier_Token.h"
#import "HTMLPurifier_Token_Start.h"
#import "HTMLPurifier_Token_End.h"
#import "HTMLPurifier_Token_Empty.h"
#import "HTMLPurifier_Token_Text.h"
#import "HTMLPurifier_Token_Tag.h"
#import "HTMLPurifier_Token_Comment.h"
#import "HTMLPurifier_ElementDef.h"
#import "HTMLPurifier_TagTransform.h"
#import "BasicPHP.h"


@implementation HTMLPurifier_Strategy_RemoveForeignElements




- (NSMutableArray*)execute:(NSMutableArray*)tokens config:(HTMLPurifier_Config*)config context:(HTMLPurifier_Context*)context
{
    HTMLPurifier_HTMLDefinition* definition = [config getHTMLDefinition];
    HTMLPurifier_Generator* generator = [[HTMLPurifier_Generator alloc] initWithConfig:config context:context];
    NSMutableArray* result = [NSMutableArray new];

    BOOL escape_invalid_tags = NO; // [[config get:@"Core.EscapeInvalidTags"] boolValue];
    BOOL remove_invalid_img = YES; // [[config get:@"Core.RemoveInvalidImg"] boolValue];

    // currently only used to determine if comments should be kept
    BOOL trusted = NO; // $config->get('HTML.Trusted');
    NSDictionary* comment_lookup = nil; // $config->get('HTML.AllowedComments');
    NSString* comment_regexp = nil; // $config->get('HTML.AllowedCommentsRegexp');
    BOOL check_comments = NO; //comment_lookup !== array() || $comment_regexp !== null;

    BOOL remove_script_contents = NO; // $config->get('Core.RemoveScriptContents');
    NSMutableDictionary* hidden_elements = [[config get:@"Core.HiddenElements"] mutableCopy];

    /*
     // remove script contents compatibility
     if ($remove_script_contents === true) {
     $hidden_elements['script'] = true;
     } elseif ($remove_script_contents === false && isset($hidden_elements['script'])) {
     unset($hidden_elements['script']);
     }*/

    HTMLPurifier_AttrValidator* attr_validator = [HTMLPurifier_AttrValidator new];

    // removes tokens until it reaches a closing tag with its value
    NSString* remove_until = nil;

    // converts comments into text tokens when this is equal to a tag name
    NSString* textify_comments = nil;

    [context registerWithName:@"CurrentToken" ref:@NO];

    /*
     $e = false;
     if ($config->get('Core.CollectErrors')) {
     $e =& $context->get('ErrorCollector');
     }*/

    for(HTMLPurifier_Token* enumToken in tokens)
    {
        //may want to change the token, but that's not possible with fast enumeration, so create a copy...
        HTMLPurifier_Token* token = enumToken;
        if (remove_until)
        {
            if (![token isTag] || ![token.name isEqual:remove_until])
            {
                continue;
            }
        }
        if ([token isTag])
        {
            // DEFINITION CALL

            NSString* tokenName = token.name;

            // before any processing, try to transform the element
            NSMutableDictionary* deprecatedTagNameTransforms = definition.info_tag_transform;

            HTMLPurifier_TagTransform* transform = deprecatedTagNameTransforms[tokenName];

            if (transform)
            {
                // there is a transformation for this tag

                // DEFINITION CALL
                token = [transform transform:(HTMLPurifier_Token_Tag*)token config:config context:context];
            }

            NSMutableDictionary* elementDefs = definition.info;

            HTMLPurifier_ElementDef* elementDef = elementDefs[tokenName];

            if(elementDef)
            {
                // mostly everything's good, but
                // we need to make sure required attributes are in order
                if (([token isKindOfClass:[HTMLPurifier_Token_Start class]] || [token isKindOfClass:[HTMLPurifier_Token_Empty class]]) &&
                    [elementDef required_attr]!=nil &&
                    (![token.name isEqual:@"img"] || remove_invalid_img) // ensure config option still works
                    )
                {
                    [attr_validator validateToken:token config:config context:context];
                    BOOL ok = YES;
                    for(NSString* name in [elementDef required_attr])
                    {
                        if (!token.attr[name])
                        {
                            ok = NO;
                            break;
                        }
                        continue;
                    }
                    if(!ok)
                        TRIGGER_ERROR(@"Strategy_RemoveForeignElements: Missing required attribute");

                    [token.armor setObject:@YES forKey:@"ValidateAttributes"];
                }

                if (hidden_elements[tokenName] && [token isKindOfClass:[HTMLPurifier_Token_Start class]])
                {
                    textify_comments = tokenName;
                }
                else if ([tokenName isEqual:textify_comments] && [token isKindOfClass:[HTMLPurifier_Token_End class]])
                {
                    textify_comments = nil;
                }

            }
            else if (escape_invalid_tags)
            {
                // invalid tag, generate HTML representation and insert in
                token = [[HTMLPurifier_Token_Text alloc] initWithData:[generator generateFromToken:token]];
            }
            else
            {
                // check if we need to destroy all of the tag's children
                // CAN BE GENERICIZED
                if (hidden_elements[tokenName])
                {
                    if ([token isKindOfClass:[HTMLPurifier_Token_Start class]])
                    {
                        remove_until = tokenName;
                    }
                    else if ([token isKindOfClass:[HTMLPurifier_Token_Empty class]])
                    {
                        // do nothing: we're still looking
                    }
                    else
                    {
                        remove_until = NO;
                    }
                    NSLog(@"Strategy_RemoveForeignElements: Foreign meta element removed");
                }
                else
                {
                    NSLog(@"Strategy_RemoveForeignElements: Foreign element removed");
                }
                continue;
            }
        }
        else if ([token isKindOfClass:[HTMLPurifier_Token_Comment class]])
        {
            NSString* dataString = [(HTMLPurifier_Token_Comment*)token data];
            // textify comments in script tags when they are allowed
            if (textify_comments)
            {
                token = [[HTMLPurifier_Token_Text alloc] initWithData:dataString];
            }
            else if (trusted || check_comments)
            {
                // always cleanup comments
                BOOL trailing_hyphen = NO;
                dataString = rtrim_2(dataString, @"-");
                while ([dataString rangeOfString:@"--"].location != NSNotFound)
                {
                    dataString = (NSString*)str_replace(@"--", @"-", dataString);
                }
                [(HTMLPurifier_Token_Comment*)token setData:dataString];

                if (trusted || [comment_lookup[trim(dataString)] count]!=0 ||
                    (comment_regexp && preg_match_2(comment_regexp, trim(dataString))))
                {
                    // OK good
                    if (trailing_hyphen) {
                        TRIGGER_ERROR(@"Strategy_RemoveForeignElements: Trailing hyphen in comment removed");
                    }
                    //if (found_double_hyphen) {
                    //    TRIGGER_ERROR(@"Strategy_RemoveForeignElements: Hyphens in comment collapsed");
                    //}

                }
            }
            else
            {
                continue;
            }
        }
        else if ([token isKindOfClass:[HTMLPurifier_Token_Text class]])
        {
        }
        else
        {
            continue;
        }
        [result addObject:token];
    }
    [context destroy:@"CurrentToken"];
    return result;
}


@end
