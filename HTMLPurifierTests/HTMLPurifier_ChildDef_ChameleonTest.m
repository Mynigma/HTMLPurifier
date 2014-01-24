//
//  HTMLPurifier_ChildDef_ChameleonTest.m
//  HTMLPurifier
//
//  Created by Lukas Neumann on 24.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "HTMLPurifier_Harness.h"
#import "HTMLPurifier_ChildDef_Chameleon.h"
#import "HTMLPurifier_Context.h"
#import "HTMLPurifier_Arborize.h"
#import "HTMLPurifier_Node.h"
#import "HTMLPurifier_Lexer_libxmlLex.h"

@interface HTMLPurifier_ChildDef_ChameleonTest : HTMLPurifier_Harness
{
    HTMLPurifier_ChildDef_Chameleon* obj;
    NSNumber* isInline;
    HTMLPurifier_Lexer_libxmlLex* lexer;
}
@end

@implementation HTMLPurifier_ChildDef_ChameleonTest

- (void)setUp
{
    [super setUp];
    obj = [[HTMLPurifier_ChildDef_Chameleon alloc] initWithInline:@[@"b",@"i"] block:@[@"b",@"i",@"div"]];
    [[super context] registerWithName:@"IsInline" ref:isInline];
    lexer = [HTMLPurifier_Lexer_libxmlLex new];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

-(void) assertResult:(NSString*)input expect:(NSObject*)expect
{
  
    NSArray* input_children = [[HTMLPurifier_Arborize arborizeTokens:[self tokenize:input] config:[super config] context:[super context]] children];
    NSMutableArray* input_children_m = [input_children mutableCopy];
    
    // call the function
    NSObject* result = [obj validateChildren:input_children config:[super config] context:[super context]];
    
    // test a bool result
    if ([result isKindOfClass:[NSNumber class]])
    {
        XCTAssertEqualObjects(expect, result);
        return;
    }

    $result = $this->generateTokens($result);
    if (is_array($expect) && !empty($expect) && $expect[0] instanceof HTMLPurifier_Node) {
                $expect = $this->generateTokens($expect);
    }
    }
    $result = $this->generate($result);
        if (is_array($expect)) {
            $expect = $this->generate($expect);
        }
    }
    $this->assertIdentical($expect, $result);
    
    if ($expect !== $result) {
        echo '<pre>' . var_dump($result) . '</pre>';
    }
    
}

-(NSArray*) tokenize:(NSString*)html
{
    return [lexer tokenizeHTMLWithString:html config:[super config] context:[super context]];
}


/** The tests...**/

-(void) testInlineAlwaysAllowed
{
    isInline = @YES;
    [self assertResult:@"<b>Allowed.</b>" expect:@"<b>Allowed.</b>"];
}

-(void) testBlockNotAllowedInInline
{
    isInline = @YES;
    [self assertResult:@"<div>Not allowed.</div>" expect:@""];
}

-(void) testBlockAllowedInNonInline
{
    isInline = @NO;
    [self assertResult:@"<div>Allowed.</div>" expect:@"<div>Allowed.</div>"];
}

@end
