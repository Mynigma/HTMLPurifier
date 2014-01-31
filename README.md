HTMLPurifier
============

**tl&dr**: Objective-C Framework for HTML filtering originated in Edward Z. Yangs [HTMLPurifier for PHP](http://htmlpurifier.org). 

HTMLPurifier for Objective-C is an Standards-Compliant HTML Filtering Framework (getting there...). You can use it to prevent running bad code from **html emails** or other user submitted html code. 

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
3. **For Mac** - If you're building for Mac, you can link against HTMLPurifier as a framework:
    * Mac framework
        - Go to Build Phases from your build target, and under 'Link Binary With Libraries', add `HTMLPurifier.framework`.
        - Make sure to use LLVM C++ standard library.  Open Build Settings, scroll down to 'C++ Standard Library', and select `libc++`.
        - In Build Phases, add a Target Dependency of `HTMLPurifier` (it's the one with a little toolbox icon).
        - Goto `Editor > Add Build Phase > Copy Files`.
        - Expand the newly created Build Phase and change it's destination to "Frameworks".
        - Click the `+` icon and select `HTMLPurifier.framework`.
4. **For iOS** - Will follow soon.
5. Use it.


## Usage ##


