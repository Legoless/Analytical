//
//  Facebook.swift
//  Analytical
//
//  Created by Dal Rupnik on 18/07/16.
//  Copyright © 2016 Unified Sense. All rights reserved.
//

import FBSDKCoreKit

public class FacebookProvider : Provider<FBSDKApplicationDelegate>, Analytical {
    public override init () {
        
    }
    
    //
    // MARK: Analyical
    //
    
    public func setup(with properties: Properties?) {
        instance = FBSDKApplicationDelegate.sharedInstance()
        
        if let launchOptions = properties?[Property.Launch.options.rawValue] as? [UIApplicationLaunchOptionsKey: Any], let application = properties?[Property.Launch.application.rawValue] as? UIApplication {
            instance.application(application, didFinishLaunchingWithOptions: launchOptions)
        }
    }
    
    public override func activate() {
        FBSDKAppEvents.activateApp()
    }
    
    public func flush() {
        FBSDKAppEvents.flush()
    }
    
    public func reset() {
        //
        // No way to reset user properties with Facebook
        //
    }
    
    public override func event(name: EventName, properties: Properties?) {
        FBSDKAppEvents.logEvent(name, parameters: properties)
    }
    
    public func screen(name: EventName, properties: Properties?) {
        event(name: name, properties: properties)
    }
    
    public func identify(userId: String, properties: Properties?) {
        FBSDKAppEvents.setUserID(userId)
        
        if let properties = properties {
            set(properties: properties)
        }
    }
    
    public func alias(userId: String, forId: String) {
        //
        // No alias tracking with Facebook
        //
    }
    
    public func set(properties: Properties) {
        FBSDKAppEvents.updateUserProperties(properties, handler: nil)
    }
    
    public func increment(property: String, by number: NSDecimalNumber) {
        FBSDKAppEvents.logEvent(property, valueToSum: number.doubleValue)
    }
    
    public func purchase(amount: NSDecimalNumber, properties: Properties?) {
        let properties = prepareProperties(properties)
        
        let currency = properties[Property.Purchase.currency.rawValue] as? String
        
        var finalParameters : [String : Any] = [:]
        finalParameters[FBSDKAppEventParameterNameContentType] = properties[Property.category.rawValue]
        finalParameters[FBSDKAppEventParameterNameContentID] = properties[Property.Purchase.sku.rawValue]
        finalParameters[FBSDKAppEventParameterNameCurrency] = currency
        
        FBSDKAppEvents.logPurchase(amount.doubleValue, currency: currency, parameters: finalParameters)
    }
    
    public func addDevice(token: Data) {
        FBSDKAppEvents.setPushNotificationsDeviceToken(token)
    }
    public func push(payload: [AnyHashable : Any]?, event: EventName?) {
        FBSDKAppEvents.logPushNotificationOpen(payload, action: event)
    }
    
    fileprivate func prepareProperties(_ properties: Properties?) -> Properties {
        var currentProperties : Properties! = properties
        
        if currentProperties == nil {
            currentProperties = [:]
        }
        
        return currentProperties
    }
}
