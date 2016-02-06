Pod::Spec.new do |s|
  s.name             = "HTMLPurifier"
  s.version          = "1.1.3"
  s.summary          = "HTMLPurifier for Objective-C is a framework for standards-compliant HTML filtering."
  s.description      = "HTMLPurifier for Objective-C is a framework for standards-compliant HTML filtering. Its main purpose is sanitisation of untrusted HTML such as incoming emails or user-supplied markup."
  s.homepage         = "https://mynigma.org"
  s.license          = { :type => 'GPL with libgit2-style exception' }
  s.author           = { 'Edward Z. Yang' => 'ezyang@cs.stanford.edu',
			'Roman Priebe' => 'roman@mynigma.org',
			'Lukas Neumann' => 'lukas@mynigma.org' }
  s.source           = { :git => 'https://github.com/Mynigma/HTMLPurifier.git', :tag => '1.1.3' }
  s.social_media_url = 'https://www.facebook.com/mynigma'

  s.ios.deployment_target = '7.0'
  s.osx.deployment_target = '10.8'
  s.requires_arc = true

  s.source_files = 'HTMLPurifier/**/*.{h,m}'
  s.public_header_files = 'HTMLPurifier/**/*.h'
  s.resource = 'HTMLPurifier/Supporting Files/HTMLPurifierConfig.plist'
  
  s.library = 'xml2'
  s.xcconfig = { 'HEADER_SEARCH_PATHS' => '$(SDKROOT)/usr/include/libxml2' }
end
