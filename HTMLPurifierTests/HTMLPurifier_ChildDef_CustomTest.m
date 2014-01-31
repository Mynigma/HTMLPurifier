//
//   HTMLPurifier_ChildDef_CustomTest.m
//   HTMLPurifier
//
//  Created by Lukas Neumann on 24.01.14.


#import <XCTest/XCTest.h>
#import "HTMLPurifier_Harness.h"
#import "HTMLPurifier_ChildDef_Custom.h"
#import "HTMLPurifier_Context.h"
#import "HTMLPurifier_Arborize.h"
#import "HTMLPurifier_Node.h"
#import "HTMLPurifier_Lexer_libxmlLex.h"
#import "HTMLPurifier_Generator.h"
#import "HTMLPurifier_Node_Element.h"

@interface HTMLPurifier_ChildDef_CustomTest : HTMLPurifier_Harness
{
    HTMLPurifier_ChildDef_Custom* obj;
}
@end

@implementation HTMLPurifier_ChildDef_CustomTest

- (void)setUp
{
    [super setUp];
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
    
    //Result should be an Array...
    result = [self generateTokens:(NSArray*)result];
    
    result = [self generate:(NSArray*)result];
    
    XCTAssertEqualObjects(expect, result);
    
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



- (void)test
{
    obj = [[HTMLPurifier_ChildDef_Custom alloc] initWithDtdRegex:@"(a,b?,c*,d+,(a,b)*)"];
    
    
    NSDictionary* x = @{@"a" : @YES, @"b" : @YES, @"c" : @YES, @"d" : @YES};
    XCTAssertEqualObjects([obj elements], x);
    
    [self assertResult:@"" expect: nil];
    [self assertResult:@"<a /><a />" expect: nil]; // or nil?
    
    [self assertResult:@"<a /><b /><c /><d /><a /><b />" expect:@YES]; //or do we expect a string?
    [self assertResult:@"<a /><d>Dob</d><a /><b>foo</b>" expect:@"<a href=\"moo\" /><b>foo</b>"];
    
}

/*

-(void) testNesting
{
    obj = new HTMLPurifier_ChildDef_Custom('(a,b,(c|d))+');
    XCTAssertEqualObjects(obj->elements, array('a' => true,
                                                   'b' => true, 'c' => true, 'd' => true));
    [self assertResult:'', false);
    [self assertResult:'<a /><b /><c /><a /><b /><d />');
    [self assertResult:'<a /><b /><c /><d />', false);
}

-(void) testNestedEitherOr
{
    obj = new HTMLPurifier_ChildDef_Custom('b,(a|(c|d))+');
    XCTAssertEqualObjects(obj->elements, array('a' => true,
                                                   'b' => true, 'c' => true, 'd' => true));
    [self assertResult:'', false);
    [self assertResult:'<b /><a /><c /><d />');
    [self assertResult:'<b /><d /><a /><a />');
    [self assertResult:'<b /><a />');
    [self assertResult:'<acd />', false);
}

-(void) testNestedQuantifier
{
    obj = new HTMLPurifier_ChildDef_Custom('(b,c+)*');
    XCTAssertEqualObjects(obj->elements, array('b' => true, 'c' => true));
    [self assertResult:'');
    [self assertResult:'<b /><c />');
    [self assertResult:'<b /><c /><c /><c />');
    [self assertResult:'<b /><c /><b /><c />');
    [self assertResult:'<b /><c /><b />', false);
}

-(void) testEitherOr
{
    obj = new HTMLPurifier_ChildDef_Custom('a|b');
    XCTAssertEqualObjects(obj->elements, array('a' => true, 'b' => true));
    [self assertResult:'', false);
    [self assertResult:'<a />');
    [self assertResult:'<b />');
    [self assertResult:'<a /><b />', false);
    
}

-(void) testCommafication
{
    obj = new HTMLPurifier_ChildDef_Custom('a,b');
    XCTAssertEqualObjects(obj->elements, array('a' => true, 'b' => true));
    [self assertResult:'<a /><b />');
    [self assertResult:'<ab />', false);
    
}

-(void) testPcdata
{
    obj = new HTMLPurifier_ChildDef_Custom('#PCDATA,a');
    XCTAssertEqualObjects(obj->elements, array('#PCDATA' => true, 'a' => true));
    [self assertResult:'foo<a />');
    [self assertResult:'<a />', false);
}

-(void) testWhitespace
{
    obj = new HTMLPurifier_ChildDef_Custom('a');
    XCTAssertEqualObjects(obj->elements, array('a' => true));
    [self assertResult:'foo<a />', false);
    [self assertResult:'<a />');
    [self assertResult:'   <a />');
}
*/

@end
