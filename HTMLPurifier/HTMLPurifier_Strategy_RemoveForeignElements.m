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
//#import "HTMLPurifier_AttrValidator.h"
#import "HTMLPurifier_Context.h"
#import "HTMLPurifier_Token.h"



@implementation HTMLPurifier_Strategy_RemoveForeignElements




- (NSMutableArray*)execute:(NSMutableArray*)tokens config:(HTMLPurifier_Config*)config context:(HTMLPurifier_Context*)context
{
    return nil;
//    HTMLPurifier_Definition* definition = [config getHTMLDefinition];
//    HTMLPurifier_Generator* generator = [[HTMLPurifier_Generator alloc] initWithConfig:config context:context];
//    NSMutableArray* result = [NSMutableArray new];
//
//    BOOL escape_invalid_tags = NO; // [[config get:@"Core.EscapeInvalidTags"] boolValue];
//    BOOL remove_invalid_img = YES; // [[config get:@"Core.RemoveInvalidImg"] boolValue];
//
//    // currently only used to determine if comments should be kept
//    BOOL trusted = NO; // $config->get('HTML.Trusted');
//    NSArray* comment_lookup = nil; // $config->get('HTML.AllowedComments');
//    NSArray* comment_regexp = nil; // $config->get('HTML.AllowedCommentsRegexp');
//    BOOL check_comments = NO; //comment_lookup !== array() || $comment_regexp !== null;
//
//    BOOL remove_script_contents = NO; // $config->get('Core.RemoveScriptContents');
//    BOOL hidden_elements = [(NSNumber*)[config get:@"Core.HiddenElements"] boolValue];
//
//    /*
//     // remove script contents compatibility
//     if ($remove_script_contents === true) {
//     $hidden_elements['script'] = true;
//     } elseif ($remove_script_contents === false && isset($hidden_elements['script'])) {
//     unset($hidden_elements['script']);
//     }*/
//
//    HTMLPurifier_AttrValidator attr_validator = [HTMLPurifier_AttrValidator new];
//
//    // removes tokens until it reaches a closing tag with its value
//    BOOL remove_until = NO;
//
//    // converts comments into text tokens when this is equal to a tag name
//    BOOL textify_comments = NO;
//
//    [context registerWithString:@"CurrentToken" object:@NO];
//
//    /*
//     $e = false;
//     if ($config->get('Core.CollectErrors')) {
//     $e =& $context->get('ErrorCollector');
//     }*/
//
//    for(HTMLPurifier_Token* token in tokens)
//    {
//        if (remove_until)
//        {
//            if ([[token is_tag] count]==0 || ![token.name isEqual:remove_until])
//            {
//                continue;
//            }
//        }
//        if ([[token is_tag] count]>0)
//        {
//            // DEFINITION CALL
//
//            // before any processing, try to transform the element
//            if (definition.info_tag_transform[token.name])
//            {
//                original_name = token.name;
//                // there is a transformation for this tag
//                // DEFINITION CALL
//                token = [definition
//                         info_tag_transform[token.name] transform:token config:config context:context];
//            }
//
//            if(definition.info[token.name])
//            {
//                // mostly everything's good, but
//                // we need to make sure required attributes are in order
//                if ([token isKindOfClass:[HTMLPurifier_Token_Start class]] || [token isKindOfClass:[HTMLPurifier_Token_Empty class]]) &&
//                    [definition.info[token.name] required_attr] &&
//                    (![token.name isEqual:@"img"] || remove_invalid_img) // ensure config option still works
//                    )
//                {
//                    [attr_validator validateToken:token config:config context:context];
//                    ok = YES;
//                    for(NSString* name in [definition.info[token.name] required_attr])
//                    {
//                        if (!token.attr[name])
//                        {
//                            ok = NO;
//                            break;
//                        }
//                        continue;
//                    }
//                    [token->armor setObject:@YES forKey:@"ValidateAttributes"];
//                }
//
//                if (hidden_elements[token.name]) && [token isKindOfClass:[HTMLPurifier_Token_Start class]])
//                {
//                    textify_comments = token.name;
//                } else if ([token.name isEqual:textify_comments] && [token isKindOfClass:[HTMLPurifier_Token_End class]])
//                {
//                    textify_comments = NO;
//                }
//
//            }
//            else if (escape_invalid_tags)
//            {
//                // invalid tag, generate HTML representation and insert in
//                token = [[HTMLPurifier_Token_Text alloc] initWith:[generator generateFromToken:token]];
//            }
//            else
//            {
//                // check if we need to destroy all of the tag's children
//                // CAN BE GENERICIZED
//                if (hidden_elements[token.name]))
//                {
//                    if ([token isKindOfClass:[HTMLPurifier_Token_Start class]])
//                    {
//                        remove_until = token.name;
//                    } else if ([token isKindOfClass:[HTMLPurifier_Token_Empty class]])
//                    {
//                        // do nothing: we're still looking
//                    } else
//                    {
//                        remove_until = NO;
//                    }
//                    NSLog(@"Strategy_RemoveForeignElements: Foreign meta element removed");
//                }
//            }
//            else
//            {
//                NSLog(@"Strategy_RemoveForeignElements: Foreign element removed");
//            }
//            continue;
//        }
//        else if ([token isKindOfClass:[HTMLPurifier_Token_Comment class]])
//        {
//            // textify comments in script tags when they are allowed
//            if (textify_comments != NO)
//            {
//                data = token.data;
//                token = [[HTMLPurifier_Token_Text alloc] initWithData:data];
//            }
//            else if (trusted || check_comments)
//            {
//                // always cleanup comments
//                BOOL trailing_hyphen = NO;
//                [token setData:rtrim(token.data, @"-")];
//                while (strpos($token->data, '--') !== false)
//                {
//                    $token->data = str_replace('--', '-', $token->data);
//                }
//                if ($trusted || [comment_lookup[trim($token->data)] count]!=0 ||
//                    (comment_regexp && preg_match(comment_regexp, trim(token.data))))
//                {
//                    // OK good
//                    //if ($e) {
//                }
//            }
//            else
//            {
//                continue;
//            }
//        }
//        else if ([token isKindOfClass:[HTMLPurifier_Token_Text class]])
//        {
//        }
//        else
//        {
//            continue;
//        }
//        [result addObject:token];
//    }
//    [context destroy:@"CurrentToken"];
//    return result;
}


@end
