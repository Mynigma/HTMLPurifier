# HTMLPurifier

**tl&dr**: Objective-C Framework for HTML filtering. Based on Edward Z. Yangs [HTMLPurifier for PHP](http://htmlpurifier.org) and more or less directly ported. 

## Description

HTMLPurifier for Objective-C is a framework for standards-compliant HTML filtering. Its main purpose is sanitisation of untrusted HTML such as incoming emails or user-supplied markup.

Some built in features are:

- removes foreign tags
- makes well-formed html
- **XSS safe**
- standards compliant
- UTF-8 aware
- validates CSS
- tables (good for emails)
- unit tested

Future features:

- fix nesting
- whitelist
... and so much more


[![Build Status](https://travis-ci.org/Mynigma/HTMLPurifier.png?branch=master)](https://travis-ci.org/Mynigma/HTMLPurifier)

## Usage

It's pretty simple. 

1. Import HTMLPurifier.h
2. Include the config.plist file in your bundle
3. Purify HTML input either synchronously: 

```objc
NSString *purifiedHTML = [HTMLPurifier cleanHTML:dirtyHTML];
```
or asynchronously:

```objc
[HTMLPurifier cleanHTML:dirtyHTML withCallBack:^(NSString* cleanedHTML, NSError* error){

NSLog(@"Purified HTML: %@", cleanedHTML);

}];
```

## Requirements

Runs on Mac OS 10.6+ as well as iOS

## Installation

Link your project with either the compiled HTMLPurifier framework or the static library. You may also need to include the config.plist file in your app bundle.

Alternatively, you can add HTMLPurifier as a sub-project:

1. Checkout HTMLPurifier into a directory relative to your project.
2. In the main directory, locate the `HTMLPurifier.xcodeproj` file, and drag this into your Xcode project.
3. **For Mac**:
  - If you're building for Mac, you can link against HTMLPurifier as a framework
  - Go to Build Phases from your build target, and under 'Link Binary With Libraries', add  
  - Make sure to use LLVM C++ standard library.  Open Build Settings, scroll down to 'C++ Standard Library', and select `libc++`.
  - In Build Phases, add a Target Dependency of `HTMLPurifier` (it's the one with a little toolbox icon).
  - Goto `Editor > Add Build Phase > Copy Files`.
  - Expand the newly created Build Phase and change it's destination to "Frameworks".
  - Click the `+` icon and select `HTMLPurifier.framework`.
  - You may need to add an recursive header-search-path to your build settings.
4. **For iOS** 
  - Will follow soon.
5. Purify.


## Authors

Roman Priebe (roman@mynigma.org) and Lukas Neumann (lukas@mynigma.org)

## License

HTMLPurifier is available under an LGPL license with a libgit2-style exception for App Store compatibility. See the LICENSE file for more info.

## Config ##

The original project, Edward Z. Yangs HTMLPurifier for PHP, includes a lot of possible config settings. Not all options will work with this version, but the default should be good enough for most purposes. If your requirements are different, feel free to add support for the necessary config options and submit a pull request.


## Warnings ##

This project is directly ported from HTMLPurifier for PHP (4.6). Some shortcuts were taken, so use common sense.

Since we use libxml2 for tokenizing, the output will vary slightly from the PHP version.


## TO DO ##

1. Implementation:
  - pre and post filtering
  - preserve style of removed <body> tags
  - fix nesting strategy
  - dynamic configurations
  - ...

2. Updating and optimizing existing code
  - Add more unit tests (some difficulties due to libxml2 parser producing different output from the PHP version)
  - ...

If you introduce new stuff, please provide viable unit tests. Here is great guide: [Coding standards](http://htmlpurifier.org/contribute#toclink1).


## Info & Licence ##

Our main project is [Mynigma](https://mynigma.org), a user-friendly, secure email client. We needed a good solution for filtering untrusted HTML and the best one by far only existed in PHP. So we ported the project to Objective-C, which turned out to be a mammoth task. You too can benefit from our work, which is licensed under both an LGPL licence and a GPL licence with a libgit2-style exception. This basically means you can use the framework on Mac OS and the static library on iOS in justabout any kind of project. However, if you amend the HTMLPurifier source, your changes must be published so they can benefit others too.

