# Analytical

Analytical is a simple light-weight analytics wrapper for iOS Swift projects. Inspired by [ARAnalytics](https://github.com/orta/ARAnalytics), which is a powerful Objective-C library. Analytical does not support all advanced functionalities of it's providers, but it allows to directly access each instance for specific configuration.


[![CI Status](https://travis-ci.org/Legoless/Analytical.svg?branch=master)](https://travis-ci.org/legoless/Analytical)
[![Version](https://img.shields.io/cocoapods/v/Analytical.svg?style=flat)](http://cocoapods.org/pods/Analytical)
[![License](https://img.shields.io/cocoapods/l/Analytical.svg?style=flat)](http://cocoapods.org/pods/Analytical)
[![Platform](https://img.shields.io/cocoapods/p/Analytical.svg?style=flat)](http://cocoapods.org/pods/Analytical)

Currently available providers:

- Facebook Analytics
- Flurry
- Google Analytics
- Mixpanel
- Segment.io

## Installation

Analytical is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
!use_frameworks

pod "Analytical"
```

The complete Podspec will install all providers, but you may specify the providers you wish to use.

```ruby
!use_frameworks

pod "Analytical/Facebook"
pod "Analytical/Flurry"
pod "Analytical/Log"
pod "Analytical/Mixpanel"
pod "Analytical/Segment"
```
The `Log` podspec will install a simple logger to output tracking calls to Xcode.

## Google Analytics

Analytical provides Google Analytics provider, but due to it's incompatibility with Swift frameworks, it must be installed manually. To do this there are 5 steps required:

1. Add `pod "Google/Analytics"` and `pod "Analytical/Core"` to your targets's podfile.
2. Run `pod install`
3. Add `#import <Google/Analytics.h>` to your Application Bridging Header.
4. Drag & drop `GoogleProvider.swift` to your project.
5. Normally instantiate `GoogleProvider` from Analytical with Google Tracking ID.

## Configuration

To separate analytics initialization code, a new Swift file is recommended:

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
// Add simple wrapper to use Enums with Analytical
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

If your application has identified user, you should call `identify` method. If your user is anonymous, you may use `analytics.deviceId` property to retrieve UUID. After first retrieval, it is stored to `NSUserDefaults`.

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
