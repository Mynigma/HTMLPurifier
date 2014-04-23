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
        [args addObject:@[@1114112, @(-1)]];
        [args addObject:@[@1114111, @0x0010FFFF]]; // @"F48FBFBF"]]; // 0x0010FFFF
        [args addObject:@[@1048576, @0x00100000]]; //@"F4808080"]]; // 0x00100000
        [args addObject:@[@1048575, @0x000FFFFF]]; //@"F3BFBFBF"]]; // 0x000FFFFF
        [args addObject:@[@262144, @0x00040000]]; //@"F1808080"]]; // 0x00040000
        [args addObject:@[@262143, @0x0003FFFF]]; //@"F0BFBFBF"]]; // 0x0003FFFF
        [args addObject:@[@65536, @0x00010000]]; // @"F0908080"]]; // 0x00010000
        [args addObject:@[@65535, @0x0000FFFF]]; //   @"EFBFBF"  ]]; // 0x0000FFFF
        [args addObject:@[@57344, @0x0000E000]]; //  @"EE8080"  ]]; // 0x0000E000
        [args addObject:@[@57343,   @(-1)]]; // 0x0000DFFF  these are ill-formed
        [args addObject:@[@56040,   @(-1)]]; // 0x0000DAE8  these are ill-formed
        [args addObject:@[@55296,   @(-1)]]; // 0x0000D800  these are ill-formed
        [args addObject:@[@55295, @0x0000D7FF]]; //  @"ED9FBF"]]; // 0x0000D7FF
    [args addObject:@[@53248, @0x0000D000]]; //  @"ED8080"  ]]; // 0x0000D000
    [args addObject:@[@53247, @0x0000CFFF]]; //  @"ECBFBF"  ]]; // 0x0000CFFF
    [args addObject:@[@4096, @0x00001000]]; //  @"E18080"  ]]; // 0x00001000
    [args addObject:@[@4095, @0x00000FFF]]; //   @"E0BFBF"  ]]; // 0x00000FFF
    [args addObject:@[@2048, @0x00000800]]; //   @"E0A080"  ]]; // 0x00000800
    [args addObject:@[@2047, @0x000007FF]];  // @"DFBF"    ]]; // 0x000007FF
    [args addObject:@[@128, @0x00000080]];   // @"C280"    ]]; // 0x00000080  invalid SGML char
    [args addObject:@[@127, @0x0000007F]];   // @"7F"      ]]; // 0x0000007F  invalid SGML char
    [args addObject:@[@0, @0x00000000]];     // @"00"      ]]; // 0x00000000  invalid SGML char

    [args addObject:@[@20108, @0x00004E8C]]; // @"E4BA8C"  ]]; // 0x00004E8C
    [args addObject:@[@77, @0x0000004D]];    // @"4D"      ]]; // 0x0000004D
    [args addObject:@[@66306, @0x00010302]]; // @"F0908C82"]]; // 0x00010302
    [args addObject:@[@1072, @0x00000430]];  // @"D0B0"    ]]; // 0x00000430

        for(NSArray* arg in args)
        {
            NSString* string = [NSString stringWithFormat:@"&#%@;&#x%@;",arg[0] /*decimal*/, dechex(arg[0]) /*hex*/];

            NSMutableString* expect = [NSMutableString new];

            if (![arg[1] isEqual:@(-1)]) {

                [expect appendFormat:@"%C%C", (unichar)[arg[1] integerValue], (unichar)[arg[1] integerValue]];
            }
            else
                expect = [NSMutableString new];
            NSString* result = [parser substituteNonSpecialEntities:string];
            XCTAssertEqualObjects(result, expect);
         }

    }

- (void)testSubstituteSpecialEntities {
        XCTAssertEqualObjects(@"'", [parser substituteSpecialEntities:@"&#39;"]);
    }

@end
