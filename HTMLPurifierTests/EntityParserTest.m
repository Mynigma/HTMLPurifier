//
//  EntityParserTest.m
//   HTMLPurifier
//
//  Created by Roman Priebe on 16.01.14.


#import <XCTest/XCTest.h>
#import "HTMLPurifier_Harness.h"
#import "HTMLPurifier_EntityParser.h"
#import "HTMLPurifier_EntityLookup.h"
#import "BasicPHP.h"

@interface EntityParserTest : HTMLPurifier_Harness
{
    HTMLPurifier_EntityParser* parser;

    HTMLPurifier_EntityLookup* lookup;
}


@end

@implementation EntityParserTest


- (void)setUp
{
    [super setUp];
    parser = [HTMLPurifier_EntityParser new];
    lookup = [HTMLPurifier_EntityLookup new];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testSubstituteNonSpecialEntities
{
    NSString* char_theta = lookup.table[@"theta"];
    XCTAssertEqualObjects(char_theta, [parser substituteNonSpecialEntities:@"&theta;"]);


    XCTAssertEqualObjects(@"\"", [parser substituteNonSpecialEntities:@"\""]);

        // numeric tests, adapted from Feyd
        NSMutableArray* args =  [NSMutableArray new];
        [args addObject:@[@1114112, @NO]];
        [args addObject:@[@1114111, @"F48FBFBF"]]; // 0x0010FFFF
        [args addObject:@[@1048576, @"F4808080"]]; // 0x00100000
        [args addObject:@[@1048575, @"F3BFBFBF"]]; // 0x000FFFFF
        [args addObject:@[@262144,  @"F1808080"]]; // 0x00040000
        [args addObject:@[@262143,  @"F0BFBFBF"]]; // 0x0003FFFF
        [args addObject:@[@65536,   @"F0908080"]]; // 0x00010000
        [args addObject:@[@65535,   @"EFBFBF"  ]]; // 0x0000FFFF
        [args addObject:@[@57344,   @"EE8080"  ]]; // 0x0000E000
        [args addObject:@[@57343,   @NO]]; // 0x0000DFFF  these are ill-formed
        [args addObject:@[@56040,   @NO]]; // 0x0000DAE8  these are ill-formed
        [args addObject:@[@55296,   @NO]]; // 0x0000D800  these are ill-formed
        [args addObject:@[@55295,   @"ED9FBF"]]; // 0x0000D7FF
        [args addObject:@[@53248,   @"ED8080"  ]]; // 0x0000D000
        [args addObject:@[@53247,   @"ECBFBF"  ]]; // 0x0000CFFF
        [args addObject:@[@4096,    @"E18080"  ]]; // 0x00001000
        [args addObject:@[@4095,    @"E0BFBF"  ]]; // 0x00000FFF
        [args addObject:@[@2048,    @"E0A080"  ]]; // 0x00000800
        [args addObject:@[@2047,    @"DFBF"    ]]; // 0x000007FF
        [args addObject:@[@128,     @"C280"    ]]; // 0x00000080  invalid SGML char
        [args addObject:@[@127,     @"7F"      ]]; // 0x0000007F  invalid SGML char
        [args addObject:@[@0,       @"00"      ]]; // 0x00000000  invalid SGML char

        [args addObject:@[@20108,   @"E4BA8C"  ]]; // 0x00004E8C
        [args addObject:@[@77,      @"4D"      ]]; // 0x0000004D
        [args addObject:@[@66306,   @"F0908C82"]]; // 0x00010302
        [args addObject:@[@1072,    @"D0B0"    ]]; // 0x00000430

        for(NSArray* arg in args)
        {
            NSString* string = [NSString stringWithFormat:@"&#%@;&#x%@;",arg[0] /*decimal*/, dechex(arg[0]) /*hex*/];
            NSMutableString* expect = [NSMutableString new];
            if (![arg[1] isEqual:@NO]) {
                NSMutableArray* chars = [NSMutableArray new];
                // strlen must be called in loop because strings size changes
                for (NSInteger i = 0; [(NSString*)arg[1] length] > i; i += 2) {
                    [chars addObject:[NSString stringWithFormat:@"%c%c", [arg[1] characterAtIndex:i], [arg[1] characterAtIndex:i+1]]];
                }
                for(NSString* charString in chars)
                {
                    unsigned char hexChar = hexdec(charString);
                    if(hexChar==0)
                        [expect appendString:@"\0"];
                    else
                        [expect appendFormat:@"%c", (unsigned char)(hexChar)];
                }
                expect = [NSMutableString stringWithFormat:@"%@%@", [expect copy], [expect copy]]; // double it
            }
            else
                expect = [string mutableCopy];
            NSString* result = [parser substituteNonSpecialEntities:string];
            XCTAssertEqualObjects(result, expect);
         }

    }

- (void)testSubstituteSpecialEntities {
        XCTAssertEqualObjects(@"'", [parser substituteSpecialEntities:@"&#39;"]);
    }

@end
