//
//   HTMLPurifier_AttrDef_CSS_Font.m
//   HTMLPurifier
//
//  Created by Roman Priebe on 14.01.14.


#import "HTMLPurifier_AttrDef_CSS_Font.h"
#import "HTMLPurifier_CSSDefinition.h"
#import "HTMLPurifier_Config.h"
#import "BasicPHP.h"

@implementation HTMLPurifier_AttrDef_CSS_Font


- (id)initWithConfig:(HTMLPurifier_Config*)config
{
    self = [super init];
    if (self) {
        info = [NSMutableDictionary new];
        HTMLPurifier_CSSDefinition* def = [config getCSSDefinition];
        info[@"font-style"] = def.info[@"font-style"];
        info[@"font-variant"] = def.info[@"font-variant"];
        info[@"font-weight"] = def.info[@"font-weight"];
        info[@"font-size"] = def.info[@"font-size"];
        info[@"line-height"] = def.info[@"line-height"];
        info[@"font-family"] = def.info[@"font-family"];
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        info = [NSMutableDictionary new];
    }
    return self;
}


    /**
     * @param string string
     * @param HTMLPurifier_Config config
     * @param HTMLPurifier_Context context
     * @return bool|string
     */
- (NSString*)validateWithString:(NSString *)theString config:(HTMLPurifier_Config *)config context:(HTMLPurifier_Context *)context
{
    NSDictionary* system_fonts = @{@"caption" : @YES,
                                     @"icon" : @YES,
                                     @"menu" : @YES,
                                     @"message-box" : @YES,
                                     @"small-caption" : @YES,
                                     @"status-bar" : @YES
                                   };

        // regular pre-processing
        NSString* string = [[self parseCDATAWithString:theString] lowercaseString];
        if ([string isEqualToString:@""]) {
            return nil;
        }

        // check if it's one of the keywords
        if (system_fonts[string]) {
            return string;
        }

        NSArray* bits = explode(@" ", string); // bits to process
        NSInteger stage = 0; // this indicates what we're looking for
        NSMutableDictionary* caught = [NSMutableDictionary new]; // which stage 0 properties have we caught?
        NSArray* stage_1 = @[@"font-style", @"font-variant", @"font-weight"];
        NSMutableString* final = [NSMutableString new]; // output
        NSInteger size = bits.count;
        NSString* r = nil;
        for (NSInteger i = 0; i < size; i++)
        {
            if ([bits[i] isEqualToString:@""]) {
                continue;
            }
            switch (stage) {
                case 0:
                {
                    // attempting to catch font-style, font-variant or font-weight
                    for(NSString* validator_name in stage_1)
                    {
                        if (caught[validator_name]) {
                            continue;
                        }
                        r = [info[validator_name] validateWithString:bits[i] config:config context:context];
                        if (r) {
                            [final appendFormat:@"%@ ", r];
                            caught[validator_name] = @YES;
                            break;
                        }
                    }
                    // all three caught, continue on
                    if (caught.count >= 3) {
                        stage = 1;
                    }
                    if (r) {
                        break;
                    }
                }
                case 1:
                {
                    NSString* font_size = nil;
                    NSString* line_height = nil;
                    // attempting to catch font-size and perhaps line-height
                    BOOL found_slash = NO;
                    if (strpos(bits[i], @"/") != NSNotFound)
                    {
                        NSArray* array = explode(@"/", bits[i]);
                        if(array.count>0)
                            font_size = array[0];
                        if(array.count>1)
                            line_height = array[1];

                        if ([line_height isEqual:@""]) {
                            // ooh, there's a space after the slash!
                            line_height = nil;
                            found_slash = YES;
                        }
                    } else {
                        font_size = bits[i];
                        line_height = nil;
                    }
                    NSInteger j;
                    r = [info[@"font-size"] validateWithString:font_size config:config context:context];
                    if (r) {
                        [final appendString:r];
                        // attempt to catch line-height
                        if (!line_height) {
                            // we need to scroll forward
                            for (j = i + 1; j < size; j++)
                            {
                                if ([bits[j] isEqualToString:@""])
                                {
                                    continue;
                                }
                                if ([bits[j] isEqualToString:@"/"]) {
                                    if (found_slash) {
                                        return nil;
                                    } else {
                                        found_slash = YES;
                                        continue;
                                    }
                                }
                                line_height = bits[j];
                                break;
                            }
                        } else {
                            // slash already found
                            found_slash = YES;
                            j = i;
                        }
                        if (found_slash) {
                            i = j;
                            r = [info[@"line-height"] validateWithString:line_height config:config context:context];
                            if (r) {
                                [final appendFormat:@"/%@", r];
                            }
                        }
                        [final appendString:@" "];
                        stage = 2;
                        break;
                    }
                    return false;
                }
                case 2:
                {
                    // attempting to catch font-family
                    NSString* font_family = implode(@" ", array_slice_3(bits, i, size - i));
                    r = [info[@"font-family"] validateWithString:font_family config:config context:context];
                    if (r) {
                        [final appendFormat:@"%@ ", r];
                        // processing completed successfully
                        return rtrim(final);
                    }
                    return false;
                }
            }
        }
        return nil;
    }




@end
