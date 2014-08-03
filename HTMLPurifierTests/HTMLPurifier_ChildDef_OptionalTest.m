//
//   HTMLPurifier_ChildDef_OptionalTest.m
//   HTMLPurifier
//
//  Created by Lukas Neumann on 24.01.14.


#import <XCTest/XCTest.h>
#import "HTMLPurifier_Harness.h"
#import "HTMLPurifier_ChildDef_Optional.h"
#import "HTMLPurifier_Context.h"
#import "HTMLPurifier_Arborize.h"
#import "HTMLPurifier_Node.h"
#import "HTMLPurifier_Lexer_libxmlLex.h"
#import "HTMLPurifier_Generator.h"
#import "HTMLPurifier_Node_Element.h"

@interface HTMLPurifier_ChildDef_OptionalTest : HTMLPurifier_Harness
{
    HTMLPurifier_ChildDef_Optional* obj;
}
@end

@implementation HTMLPurifier_ChildDef_OptionalTest

- (void)setUp
{
    [super setUp];
    obj = [[HTMLPurifier_ChildDef_Optional alloc] initWithElements:@"b | i"];
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


-(void) testBasicUsage
{
    [self assertResult:@"<b>Bold text</b><img />" expect:@"<b>Bold text</b>"];
}

-(void) testRemoveForbiddenText
{
    [self assertResult:@"Not allowed text" expect:@""];
}

-(void) testEmpty
{
    [self assertResult:@"" expect:@YES];
}

-(void) testWhitespace
{
    [self assertResult:@" " expect:@" "];
}

-(void) testMultipleWhitespace
{
    [self assertResult:@"    " expect:@"    "];
}


@end
