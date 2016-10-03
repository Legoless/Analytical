# Analytical

[![Issues on Waffle](https://img.shields.io/badge/issues on-Waffle-blue.svg)](http://waffle.io/legoless/Analytical)
[![Built by Dominus](https://img.shields.io/badge/built by-Dominus-brightgreen.svg)](http://github.com/legoless/Dominus)
[![Build Status](https://travis-ci.org/Legoless/Analytical.svg)](https://travis-ci.org/legoless/Analytical)
[![Swift Code](https://img.shields.io/badge/code in-Swift-orange.svg)](http://github.com/legoless/Analytical)
[![Pod Version](http://img.shields.io/cocoapods/v/Analytical.svg?style=flat)](http://cocoadocs.org/docsets/Analytical/)
[![Pod Platform](http://img.shields.io/cocoapods/p/Analytical.svg?style=flat)](http://cocoadocs.org/docsets/Analytical/)
[![Pod License](http://img.shields.io/cocoapods/l/Analytical.svg?style=flat)](http://opensource.org/licenses/MIT)

Analytical is a simple lightweight analytics wrapper for iOS Swift projects. Inspired by [ARAnalytics](https://github.com/orta/ARAnalytics) - a powerful Objective-C analytics library. Analytical does not support all advanced functionalities of it's providers, but it allows to directly access each instance for specific configuration.


Currently available providers:

- [Facebook Analytics](https://developers.facebook.com/products/analytics)
- [Flurry](https://github.com/flurry/flurry-ios-sdk)
- [Google Analytics](https://developers.google.com/analytics/devguides/collection/ios/v3/)
- [Mixpanel](https://mixpanel.com/help/reference/ios)
- [Segment.io](https://segment.com/docs/sources/mobile/ios/)

## Installation

Analytical is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
# Required for Swift libraries
!use_frameworks

pod "Analytical"

# To use Swift3 version point your CocoaPods installation directly to this repository. 0.2.x are Swift 2.x versions.
pod "Analytical", :git => 'https://github.com/Legoless/Analytical.git'
```

The complete Podspec will install all available providers, but you may specify the providers you wish to use.

```ruby
# Required for Swift libraries
!use_frameworks

pod "Analytical/Facebook"
pod "Analytical/Flurry"
pod "Analytical/Log"
pod "Analytical/Mixpanel"
pod "Analytical/Segment"
```
The `Log` podspec will install a simple logger to output tracking calls to Xcode.

## Google Analytics

Analytical provides Google Analytics provider, but due to it's incompatibility between static libraries and CocoaPods Swift frameworks, it must be installed manually. To do this there are 5 steps required:

1. Add `pod "Google/Analytics"` and `pod "Analytical/Core"` to your targets's podfile.
2. Run `pod install`
3. Add `#import <Google/Analytics.h>` to your Application Bridging Header.
4. Drag & drop `GoogleProvider.swift` to your project.
5. Normally instantiate `GoogleProvider` from Analytical with Google Tracking ID.

*Google Analytics takes 4 parameters for each event: Category, Action, Label and Value. Category will be set to "default", when called from Analytical and Action will be the event name passed to the call. Label and Value are optional.*

*When Google will update their library to support dynamic frameworks, these steps will no longer be required.*

## Configuration

To separate analytics code, a new separate Swift file is recommended:

```swift
// Define Providers and create a global variable
let analytics = Analytics() <<~ GoogleProvider(trackingId: "<GA_TRACKING_ID>") <<~ MixpanelProvider(token: "<MIXPANEL_TOKEN>") <<~ FacebookProvider()

// Simple Enum for Events
public enum Track {
    public enum Event : String {
        case FirstButtonTap         = "FirstButtonTap"
        case TopMenuSelect          = "TopMenuSelect"
    }
    // Define screens
    public enum Screen : String {
        case FirstScreen            = "FirstScreen"
        case SecondScreen           = "SecondScreen"
    }
}

//
// Add simple wrapper to use defined Enums with Analytical
//
extension Analytical {
    func track(track: Track.Event, properties: Properties? = nil) {
        event(track.rawValue, properties: properties)
    }
    
    func track(track: Track.Screen, properties: Properties? = nil) {
        screen(track.rawValue, properties: properties)
    }
    
    func time(track: Track.Event, properties: Properties? = nil) {
        time(track.rawValue, properties: properties)
    }
    
    func finish(track: Track.Event, properties: Properties? = nil) {
        finish(track.rawValue, properties: properties)
    }
}
```

## Usage

Some analytics providers require to be setup when application finishes launching. Add this code to your `application:didFinishLaunchingWithOptions` method:

```swift
analytics.setup(application, launchOptions: launchOptions)
```

Some analytics providers require to log application activation (Facebook for example), so you must add the code below to your `applicationDidBecomeActive:` method.

```swift
analytics.activate()
```

*In both cases ensure that analytics providers are initialized before calling this method.*

### Tracking events and screens:

```swift
// Calls using above wrapper
analytics.track(.FirstButtonTap)
analytics.track(.FirstScreen)

// Original call with String
analytics.screen(Track.Screen.rawValue)
```

### Tracking properties

```swift
analytics.track(.FirstButtonTap, ["property" : 12.00])
analytics.track(.FirstScreen, ["property" : 12.00])
```

### Identification

If your application has identified user, you should call `identify` method. If your user is anonymous, you may use `analytics.deviceId` property to retrieve UUID. After first retrieval, it is stored to `NSUserDefaults` and used in all next calls.

```swift
analytics.identify(analytics.deviceId)
```

Contact
======

Dal Rupnik

- [legoless](https://github.com/legoless) on **GitHub**
- [@thelegoless](https://twitter.com/thelegoless) on **Twitter**
- [dal@unifiedsense.com](mailto:dal@unifiedsense.com)

License
======

**Analytical** is available under the **MIT** license. See [LICENSE](https://github.com/Legoless/Analytical/blob/master/LICENSE) file for more information.
