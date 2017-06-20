# Analytical

[![Issues on Waffle](https://img.shields.io/badge/issues%20on-Waffle-blue.svg)](http://waffle.io/legoless/Analytical)
[![Swift Code](https://img.shields.io/badge/code%20in-Swift-orange.svg)](http://github.com/legoless/Analytical)
[![Build Status](https://travis-ci.org/Legoless/Analytical.svg)](https://travis-ci.org/legoless/Analytical)
[![Pod Version](http://img.shields.io/cocoapods/v/Analytical.svg?style=flat)](http://cocoadocs.org/docsets/Analytical/)
[![Pod Platform](http://img.shields.io/cocoapods/p/Analytical.svg?style=flat)](http://cocoadocs.org/docsets/Analytical/)
[![Pod License](http://img.shields.io/cocoapods/l/Analytical.svg?style=flat)](http://opensource.org/licenses/MIT)

Analytical is a simple lightweight analytics wrapper for iOS Swift projects. Inspired by [ARAnalytics](https://github.com/orta/ARAnalytics) - a powerful Objective-C analytics library by Orta Therox. Analytical does not support all advanced functionalities of specific providers, but it allows direct access each analytics instance for additional features, after it is set up.

Currently available analytics providers:

- [Facebook](https://developers.facebook.com/products/analytics)
- [Firebase](https://developers.google.com/analytics/devguides/collection/ios/v3/)
- [Flurry](https://github.com/flurry/flurry-ios-sdk)
- [Google Analytics](https://developers.google.com/analytics/devguides/collection/ios/v3/)
- [Mixpanel](https://mixpanel.com/help/reference/ios)
- [Segment.io](https://segment.com/docs/sources/mobile/ios/)

A special set of providers for specific purposes:
- [Logging provider](https://github.com/Legoless/Analytical/blob/master/Analytical/Classes/Provider/LogProvider.swift)

Analytical is used in production in all applications by [Blub Blub](http://blubblub.org).

## CocoaPods

Analytical is available only through [CocoaPods](http://cocoapods.org). To install it, simply add the following line to your Podfile:

```ruby
!use_frameworks

pod 'Analytical'
```

For performance reasons, it is not recommended to have more than two providers installed, you should specify which you wish to use.

```ruby
!use_frameworks

pod 'Analytical/Facebook'
pod 'Analytical/Flurry'
pod 'Analytical/Log'
pod 'Analytical/Mixpanel'
pod 'Analytical/Segment'
```
The `Log` subspec will install a simple logger to output tracking calls to Xcode Console.

## Google Analytics

Analytical includes Google Analytics provider, but due to it's incompatibility between static libraries and CocoaPods Swift frameworks, it must be installed manually. To do this there are 5 steps required:

1. Add `pod "Google/Analytics"` and `pod "Analytical/Core"` to your targets's podfile.
2. Run `pod install`
3. Add `#import <Google/Analytics.h>` to your Application Bridging Header.
4. Drag & drop `GoogleProvider.swift` to your project.
5. Instantiate `GoogleProvider` class with Google Tracking ID.

*Google Analytics takes 4 parameters for each event: Category, Action, Label and Value. Category will be set to "default", when called from Analytical and Action will be the event name passed to the call. Label and Value are optional.*

*When Google will update their library to support dynamic frameworks, these steps will no longer be required.*

## Manual Installation

If you do not use CocoaPods, you can manually install Analytical. The required files are in `Analytical/Classes/Core` directory, so you may directly drag & drop them into your project: `Analytical.swift`, `Analytics.swift` and `Provider.swift`.

In addition to the core files, you will also require at least one concrete provider, from `Analytical/Classes/Provider` directory.

*Please ensure that all additional dependencies for specific providers are linked correctly to your target.*

## Configuration

To separate analytics code, a new separate Swift file is recommended:

```swift
// Define Providers and create a global variable to be accessible from everywhere
let analytics = Analytics() <<~ GoogleProvider(trackingId: "<GA_TRACKING_ID>") <<~ MixpanelProvider(token: "<MIXPANEL_TOKEN>") <<~ FacebookProvider()

// Simple Enum for Events
public enum Track {
    public enum Event : String {
        case secondScreenTap  = "SecondScreenTap"
        case closeTap = "CloseTap"
    }
    
    public enum Screen : String {
        case first  = "first"
        case second = "second"
    }
}

//
// Add simple wrapper to use newly defined enums with Analytical
//
extension Analytical {
    func track(event: Track.Event, properties: Properties? = nil) {
        self.event(name: event.rawValue, properties: properties)
    }
    
    func track(screen: Track.Screen, properties: Properties? = nil) {
        self.screen(name: screen.rawValue, properties: properties)
    }
    
    func time(event: Track.Event, properties: Properties? = nil) {
        self.time(name: event.rawValue, properties: properties)
    }
    
    func finish(event: Track.Event, properties: Properties? = nil) {
        self.finish(name: event.rawValue, properties: properties)
    }
}
```

## Usage

Some analytics providers require to be setup when application finishes launching. Make sure to add call to `setup` to your `application:didFinishLaunchingWithOptions` method:

```swift
analytics.setup(with: application, launchOptions: launchOptions)
```

Some analytics providers require to log application activation (Facebook for example), so you should add the code below to your `applicationDidBecomeActive:` method.

```swift
analytics.activate()
```

*In both cases ensure that analytics providers are initialized before calling this method.*

### Tracking events and screens:

```swift
// Calls using above wrapper
analytics.track(event: .secondScreenTap)
analytics.track(screen: .first)

//
// Original call with String
//
analytics.screen(name: Track.Screen.first.rawValue)
```

See Example project for more examples.

### Tracking properties

```swift
analytics.track(event: .closeTap, ["property" : 12.00])
analytics.track(screen: .first, ["property" : 12.00])
```

### Identification

If your application has identified user, you should call `identify` method. If your user is anonymous, you may use `analytics.deviceId` property to retrieve UUID. After first retrieval, it is stored to `UserDefaults` and used in all next calls. If your application is linked to `iAd.framework`, it will return `ASIdentifierManager.sharedManager().advertisingIdentifier` as a `String`. Analytics does not depend on iAd directly and will use runtime introspection to detect it. It does respect **Limit Ad Tracking** setting in user's privacy settings.

```swift
analytics.identify(analytics.deviceId)
```

## FAQ

*Where is Carthage support?*

Analytical does not support Carthage for providers, as it depends on several external frameworks. You can use the core Analytical as a framework and add specific providers manually, as described under Manual installation.

Contact
======

Dal Rupnik

- [legoless](https://github.com/legoless) on **GitHub**
- [@thelegoless](https://twitter.com/thelegoless) on **Twitter**
- [dal@unifiedsense.com](mailto:dal@unifiedsense.com)

License
======

**Analytical** is available under the **MIT** license. See [LICENSE](https://github.com/Legoless/Analytical/blob/master/LICENSE) file for more information.
