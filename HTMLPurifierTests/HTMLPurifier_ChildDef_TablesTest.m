//
//  HTMLPurifier_ChildDef_Table.m
//  HTMLPurifier
//
//  Created by Lukas Neumann on 24.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "HTMLPurifier_Harness.h"
#import "HTMLPurifier_ChildDef_Tables.h"
#import "HTMLPurifier_Context.h"
#import "HTMLPurifier_Config.h"
#import "HTMLPurifier_Arborize.h"
#import "HTMLPurifier_Node.h"
#import "HTMLPurifier_Lexer_libxmlLex.h"
#import "HTMLPurifier_Generator.h"
#import "HTMLPurifier_Node_Element.h"


// we're using empty tags to compact the tests: under real circumstances
// there would be contents in them
@interface HTMLPurifier_ChildDef_TablesTest : HTMLPurifier_Harness
{
    HTMLPurifier_ChildDef_Tables* obj;
}
@end

@implementation HTMLPurifier_ChildDef_TablesTest

- (void)setUp
{
    [super setUp];
    obj = [HTMLPurifier_ChildDef_Tables new];
}

- (void)tearDown
{
    [super tearDown];
}

-(void) assertResult:(NSString*)input expect:(NSObject*)expect
{
    
    NSArray* input_children = [[HTMLPurifier_Arborize arborizeTokens:[self tokenize:input] config:[super config] context:[super context]] children];
    
    // call the function
    NSObject* result = [obj validateChildren:input_children config:[super config] context:[super context]];
    
    // test a bool result
    if ([result isKindOfClass:[NSNumber class]])
    {
        XCTAssertEqualObjects(expect, result);
        return;
    }
    
}

-(NSArray*) tokenize:(NSString*)html
{
    HTMLPurifier_Lexer_libxmlLex* lexer;
    lexer = [HTMLPurifier_Lexer_libxmlLex new];
    return [lexer tokenizeHTMLWithString:html config:[super config] context:[super context]];
}

-(NSString*) generate:(NSArray*)tokens
{
    HTMLPurifier_Generator* generator = [[HTMLPurifier_Generator alloc] initWithConfig:[super config] context:[super context]];
    return [generator generateFromTokens:tokens];
}

- (NSArray*)generateTokens:(NSArray*)children
{
    HTMLPurifier_Node_Element* dummy = [[HTMLPurifier_Node_Element alloc] initWithName:@"dummy"];
    dummy.children = [children mutableCopy];
    return [HTMLPurifier_Arborize flattenNode:dummy config:self.config context:self.context];
}


/*** Tests ***/

public function testEmptyInput()
{
    $this->assertResult('', false);
}

public function testSingleRow()
{
    $this->assertResult('<tr />');
}

public function testComplexContents()
{
    $this->assertResult('<caption /><col /><thead /><tfoot /><tbody>'.
                        '<tr><td>asdf</td></tr></tbody>');
    $this->assertResult('<col /><col /><col /><tr />');
}

public function testReorderContents()
{
    $this->assertResult(
                        '<col /><colgroup /><tbody /><tfoot /><thead /><tr>1</tr><caption /><tr />',
                        '<caption /><col /><colgroup /><thead /><tfoot /><tbody /><tbody><tr>1</tr><tr /></tbody>');
}

public function testXhtml11Illegal()
{
    $this->assertResult(
                        '<thead><tr><th>a</th></tr></thead><tr><td>a</td></tr>',
                        '<thead><tr><th>a</th></tr></thead><tbody><tr><td>a</td></tr></tbody>'
                        );
}

public function testTrOverflowAndClose()
{
    $this->assertResult(
                        '<tr><td>a</td></tr><tr><td>b</td></tr><tbody><tr><td>c</td></tr></tbody><tr><td>d</td></tr>',
                        '<tbody><tr><td>a</td></tr><tr><td>b</td></tr></tbody><tbody><tr><td>c</td></tr></tbody><tbody><tr><td>d</td></tr></tbody>'
                        );
}

public function testDuplicateProcessing()
{
    $this->assertResult(
                        '<caption>1</caption><caption /><tbody /><tbody /><tfoot>1</tfoot><tfoot />',
                        '<caption>1</caption><tfoot>1</tfoot><tbody /><tbody /><tbody />'
                        );
}

public function testRemoveText()
{
    $this->assertResult('foo', false);
}

public function testStickyWhitespaceOnTr()
{
    $this->config->set('Output.Newline', "\n");
    $this->assertResult("\n   <tr />\n  <tr />\n ");
}

public function testStickyWhitespaceOnTSection()
{
    $this->config->set('Output.Newline', "\n");
    $this->assertResult(
                        "\n\t<tbody />\n\t\t<tfoot />\n\t\t\t",
                        "\n\t<tfoot />\n\t\t\t<tbody />\n\t\t"
                        );
    
}


@end
