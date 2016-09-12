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
    
    public func setup(_ properties: Properties?) {
        instance = FBSDKApplicationDelegate.sharedInstance()
        
        if let launchOptions = properties?[Property.Launch.Options.rawValue] as? [AnyHashable: Any], let application = properties?[Property.Launch.Application.rawValue] as? UIApplication {
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
    
    public override func event(_ name: EventName, properties: Properties?) {
        FBSDKAppEvents.logEvent(name, parameters: properties)
    }
    
    public func screen(_ name: EventName, properties: Properties?) {
        event(name, properties: properties)
    }
    
    public func identify(_ userId: String, properties: Properties?) {
        //
        // No user tracking with Facebook
        //
    }
    
    public func alias(_ userId: String, forId: String) {
        //
        // No alias tracking with Facebook
        //
    }
    
    public func set(_ properties: Properties) {
        //
        // No custom properties
        //
    }
    
    public func increment(_ property: String, by number: NSDecimalNumber) {
        FBSDKAppEvents.logEvent(property, valueToSum: number.doubleValue)
    }
    
    public func purchase(_ amount: NSDecimalNumber, properties: Properties?) {
        let properties = prepareProperties(properties)
        
        let currency = properties[Property.Purchase.Currency.rawValue] as? String
        
        var finalParameters : [String : AnyObject] = [:]
        finalParameters[FBSDKAppEventParameterNameContentType] = properties[Property.Category.rawValue] as? String as AnyObject?
        finalParameters[FBSDKAppEventParameterNameContentID] = properties[Property.Purchase.Sku.rawValue] as? String as AnyObject?
        finalParameters[FBSDKAppEventParameterNameCurrency] = currency as AnyObject?
        
        FBSDKAppEvents.logPurchase(amount.doubleValue, currency: currency, parameters: finalParameters)
    }
    
    fileprivate func prepareProperties(_ properties: Properties?) -> Properties {
        var currentProperties : Properties! = properties
        
        if currentProperties == nil {
            currentProperties = [:]
        }
        
        return currentProperties
    }
}
