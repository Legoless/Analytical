# Analytical

Analytical is a simple lightweight abstract analytics wrapper for Swift. Similar to [ARAnalytics](https://github.com/orta/ARAnalytics), but for Swift.


[![CI Status](http://img.shields.io/travis/Dal Rupnik/Analytical.svg?style=flat)](https://travis-ci.org/Dal Rupnik/Analytical)
[![Version](https://img.shields.io/cocoapods/v/Analytical.svg?style=flat)](http://cocoapods.org/pods/Analytical)
[![License](https://img.shields.io/cocoapods/l/Analytical.svg?style=flat)](http://cocoapods.org/pods/Analytical)
[![Platform](https://img.shields.io/cocoapods/p/Analytical.svg?style=flat)](http://cocoapods.org/pods/Analytical)

## Example

To separate analytics initialization code, a new Swift file is recommended:

```swift
let analytics = Analytics() <<~ GoogleProvider(trackingId: "GA-1231231-1") <<~ MixpanelProvider(token: "<MIXPANEL_TOKEN>") <<~ FacebookProvider()
```

## Installation

Analytical is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "Analytical"
```

Specify the providers you wish to use.

```ruby
pod "Analytical/Facebook"
pod "Analytical/Mixpanel"
```

# Google Analytics

Analytical provides Google Analytics provider, but due to it's incompatibility with Swift frameworks, it must be installed manually. To do this there are 3 steps required:

1. Add `pod "Google/Analytics"` and pod `"Analytical/Core"` to your targets's podfile.
2. Run `pod install`
3. Add `#import <Google/Analytics.h>` to your Application Bridging Header.
3. Drag & drop `GoogleProvider.swift` to your project.
4. Normally instantiate `GoogleProvider` from Analytical with Google Tracking ID.

## Author

Dal Rupnik, legoless@gmail.com

## License

Analytical is available under the MIT license. See the LICENSE file for more info.
