//
//   HTMLPurifier_URISchemeRegistryTest.m
//   HTMLPurifier
//
//  Created by Lukas Neumann on 21.01.14.


#import <XCTest/XCTest.h>
#import "HTMLPurifier_URIScheme.h"
#import "HTMLPurifier_URIHarness.h"
#import "HTMLPurifier_Config.h"
#import "HTMLPurifier_Context.h"
#import "HTMLPurifier_URI.h"
#import "BasicPHP.h"
#import "HTMLPurifier_URISchemeRegistry.h"

@interface HTMLPurifier_URISchemeRegistryTest : HTMLPurifier_URIHarness

@end

@implementation HTMLPurifier_URISchemeRegistryTest

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void) disabled_test
{
    
    /****** We dont really need this right now. *****
    
    self.config = [HTMLPurifier_Config createWithConfig:@{@"URI.AllowedSchemes",@"http, telnet", @"URI.OverrideAllowedSchemes",@YES}];
    
    $context = new HTMLPurifier_Context();
    
    $registry = new HTMLPurifier_URISchemeRegistry();
    $this->assertIsA($registry->getScheme('http', $config, $context), 'HTMLPurifier_URIScheme_http');
    
    $scheme_http = new HTMLPurifier_URISchemeMock();
    $scheme_telnet = new HTMLPurifier_URISchemeMock();
    $scheme_foobar = new HTMLPurifier_URISchemeMock();
    
    // register a new scheme
    $registry->register('telnet', $scheme_telnet);
    $this->assertIdentical($registry->getScheme('telnet', $config, $context), $scheme_telnet);
    
    // overload a scheme, this is FINAL (forget about defaults)
    $registry->register('http', $scheme_http);
    $this->assertIdentical($registry->getScheme('http', $config, $context), $scheme_http);
    
    // when we register a scheme, it's automatically allowed
    $registry->register('foobar', $scheme_foobar);
    $this->assertIdentical($registry->getScheme('foobar', $config, $context), $scheme_foobar);
    
    // now, test when overriding is not allowed
    $config = HTMLPurifier_Config::create(array(
                                                'URI.AllowedSchemes' => 'http, telnet',
                                                'URI.OverrideAllowedSchemes' => false
                                                ));
    $this->assertNull($registry->getScheme('foobar', $config, $context));
    
    // scheme not allowed and never registered
    $this->assertNull($registry->getScheme('ftp', $config, $context)); */

}

@end
