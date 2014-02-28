HTMLPurifier
============

**tl&dr**: Objective-C Framework for HTML filtering. Originated in Edward Z. Yangs [HTMLPurifier for PHP](http://htmlpurifier.org) and more or less directly ported. 

HTMLPurifier for Objective-C is an Standards-Compliant HTML Filtering Framework (getting there...). You can use it to prevent running evil code from **html emails** or filter user submitted html code. 

Some built in features are:

- removes foreign tags
- makes well-formed html
- **XSS safe**
- standards compliant
- UTF-8 aware
- validates CSS
- tables (good for emails)
- unit tested (not yet evergreen)

Future features:

- fixes nesting (not yet implemented)
- whitelist (not yet implemented)
- ... so much more (not yet implemented)


## Installation ##

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
5. Use it.


## Usage ##

It's pretty simple. 

1. Add import HTMLPurifier.h
2. Start purifying HTML: 

```objc
HTMLPurifier *purifier = [HTMLPurifier new];
NSString *cleanHTML = [purifier purify:dirtyHTML];
```

Purification is an asynchronous operation with its own autorelease pool.


## Config ##

In Edward Z. Yangs HTMLPurifier one has a lot of possible config settings. We currently just using the `default config` which you can find and edit in the `Supporting Files/config.plist`. CAUTION: Some settings may not work or will crash the program.


## Warnings ##

This is (as you can see in some leftover comments) directly ported from HTMLPurifier for PHP (4.6). We took many shortcuts to get it to run, so be careful.

We left some important stuff out, like any pre or post filtering. And since we're using libxml2 for tokenizing, the output is definitly different from the PHP version.


## TO DO ##

Wow. We spent 2,5 sleepless weeks for this framework. The PHP standalone file has over 20.000 lines of code and we additionaly implemented around 400 unit tests. **But** there is still work to do. You're welcome to contribute in any form to this project.

1. Implementing leftout stuff:
  - pre and post filtering
  - fix nesting strategy
  - dynamic configurations
  - Add broader CSS definition (esp. for emails)
  - ...

2. Updating and optimizing existing code
  - Fix the failing unit tests
  - ...

If you introduce new stuff, please provide viable unit tests. Here is great guideline: [Coding standards](http://htmlpurifier.org/contribute#toclink1).


## Info & Licence ##

Our main project [Mynigma](https://mynigma.org) is a secure and easy to use email client and we couldn't find any good solution for disabling bad and unsecure code in incoming html emails. Thats why we took the best and really well documented thing out there and ported it from PHP to Objective-C.

Right now we are using LGPL 2.1 for licencing, as the original project uses this licence. We are aware of the "static linking" problem and since we want to use HTMLPurifier in our iOS app, we will try to add an exception to the licence. For this we need the consent of the original authors (TODO).   


