//
//   HTMLPurifier_ChildDef_StrictBlockquoteTest.m
//   HTMLPurifier
//
//  Created by Lukas Neumann on 24.01.14.


#import <XCTest/XCTest.h>
#import "HTMLPurifier_Harness.h"
#import "HTMLPurifier_ChildDef_StrictBlockquote.h"
#import "HTMLPurifier_Context.h"
#import "HTMLPurifier_Config.h"
#import "HTMLPurifier_Arborize.h"
#import "HTMLPurifier_Node.h"
#import "HTMLPurifier_Lexer_libxmlLex.h"
#import "HTMLPurifier_Generator.h"
#import "HTMLPurifier_Node_Element.h"

@interface HTMLPurifier_ChildDef_StrictBlockquoteTest : HTMLPurifier_Harness
{
    HTMLPurifier_ChildDef_StrictBlockquote* obj;
}
@end

@implementation HTMLPurifier_ChildDef_StrictBlockquoteTest

- (void)setUp
{
    [super setUp];
    obj = [[HTMLPurifier_ChildDef_StrictBlockquote alloc] initWithElements:@"div | p"];
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
    [self assertResult:@"" expect:@""];
}

-(void) testPreserveValidP
{
    [self assertResult:@"<p>Valid</p>" expect:@"<p>Valid</p>"];
}

-(void) testPreserveValidDiv
{
    [self assertResult:@"<div>Still valid</div>" expect:@"<div>Still valid</div>"];
}

-(void) testWrapTextWithP
{
    [self assertResult:@"Needs wrap" expect:@"<p>Needs wrap</p>"];
}

-(void) testNoWrapForWhitespaceOrValidElements
{
    [self assertResult:@"<p>Do not wrap</p>    <p>Whitespace</p>" expect:@"<p>Do not wrap</p>    <p>Whitespace</p>"];
}

-(void) testWrapTextNextToValidElements
{
    [self assertResult:@"Wrap'. '<p>Do not wrap</p>" expect:@"<p>Wrap</p><p>Do not wrap</p>"];
}

-(void) testWrapInlineElements
{
    [self assertResult:@"<p>Do not</p>'.'<b>Wrap</b>" expect:@"<p>Do not</p><p><b>Wrap</b></p>"];
}

-(void) testWrapAndRemoveInvalidTags
{
    [self assertResult:@"<li>Not allowed</li>Paragraph.<p>Hmm.</p>" expect:@"<p>Not allowedParagraph.</p><p>Hmm.</p>"];
}

-(void) testWrapComplicatedSring
{
    [self assertResult:@"He said<br />perhaps<br />we should <b>nuke</b> them."
                expect:@"<p>He said<br />perhaps<br />we should <b>nuke</b> them.</p>"];
}

-(void) testWrapAndRemoveInvalidTagsComplex
{
    [self assertResult:@"<foo>Bar</foo><bas /><b>People</b>Conniving.<p>Fools!</p>"
                expect:@"<p>Bar<b>People</b>Conniving.</p><p>Fools!</p>"];
}

-(void) disable_testAlternateWrapper
{
    [[super config] setString:@"HTML.BlockWrapper" object:@"div"];
    [self assertResult:@"Needs wrap" expect:@"<div>Needs wrap</div>"];
    
}

-(void) disable_testError
{
    obj = [[HTMLPurifier_ChildDef_StrictBlockquote alloc] initWithElements:@"div | p"];
    [[super config] setString:@"HTML.BlockWrapper" object:@"dav"];
    [[super config] setString:@"Cache.DefinitionImpl" object:nil];
    [self assertResult:@"Needs wrap" expect:@"<p>Needs wrap</p>"];
}

@end
