//
//   HTMLPurifier_ChildDef_ListTest.m
//   HTMLPurifier
//
//  Created by Lukas Neumann on 24.01.14.


#import <XCTest/XCTest.h>
#import "HTMLPurifier_Harness.h"
#import "HTMLPurifier_ChildDef_List.h"
#import "HTMLPurifier_Context.h"
#import "HTMLPurifier_Arborize.h"
#import "HTMLPurifier_Node.h"
#import "HTMLPurifier_Lexer_libxmlLex.h"
#import "HTMLPurifier_Generator.h"
#import "HTMLPurifier_Node_Element.h"

@interface HTMLPurifier_ChildDef_ListTest : HTMLPurifier_Harness
{
    HTMLPurifier_ChildDef_List* obj;
}
@end

@implementation HTMLPurifier_ChildDef_ListTest

- (void)setUp
{
    [super setUp];
    obj = [HTMLPurifier_ChildDef_List new];
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
    
-(void) testEmptyInput
{
    [self assertResult:@"" expect:false];
}

-(void) testSingleLi
{
    [self assertResult:@"<li />" expect:@"<li />"];
}

-(void) testSomeLi
{
    [self assertResult:@"<li>asdf</li><li />" expect:@"<li>asdf</li><li />"];
}

-(void) testOlAtBeginning
{
    [self assertResult:@"<ol />" expect:@"<li><ol /></li>"];
}

-(void) testOlAtBeginningWithOtherJunk
{
    [self assertResult:@"<ol /><li />" expect:@"<li><ol /></li><li />"];
}

-(void) testOlInMiddle
{
    [self assertResult:@"<li>Foo</li><ol><li>Bar</li></ol>" expect:@"<li>Foo<ol><li>Bar</li></ol></li>"];
}

-(void) testMultipleOl
{
    [self assertResult:@"<li /><ol /><ol />" expect:@"<li><ol /><ol /></li>"];
}

-(void) testUlAtBeginning
{
    [self assertResult:@"<ul />" expect:@"<li><ul /></li>"];
}

-(void) testOlAtBeginningWithJunk
{
    [self assertResult:@"<ol><li>1<li>2<li>3</li></ol>" expect:@"<ol><li>1<li>2<li>3</li></ol>"];
}

@end
