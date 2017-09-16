//
//  Facebook.swift
//  Analytical
//
//  Created by Dal Rupnik on 18/07/16.
//  Copyright © 2016 Unified Sense. All rights reserved.
//

import FBSDKCoreKit

/*
extension FacebookProvider {
    func completedRegistration () {
        event(name: FBSDKAppEventNameCompletedRegistration, properties: nil)
    }
    
    func completedTutorial () {
        event(name: FBSDKAppEventNameCompletedTutorial, properties: nil)
    }
    
    func addToCart(product: Product, category: String) {
        logEvent(name: FBSDKAppEventNameAddedToCart, product: product, category: category)
    }
    
    func contentView(product: Product, category: String) {
        logEvent(name: FBSDKAppEventNameViewedContent, product: product, category: category)
    }
    
    func initiatedCheckout(product: Product, category: String) {
        logEvent(name: FBSDKAppEventNameInitiatedCheckout, product: product, category: category)
    }
    
    private func logEvent(name: String, product: Product, category: String) {
        let properties = self.purchaseProperties(product: product, category: category)
        
        var finalProperties : [String : Any] = [:]
        finalProperties[FBSDKAppEventParameterNameContentType] = category
        finalProperties[FBSDKAppEventParameterNameContentID] = properties[Property.Purchase.sku.rawValue]
        finalProperties[FBSDKAppEventParameterNameCurrency] = properties[Property.Purchase.currency.rawValue]
        
        FBSDKAppEvents.logEvent(name, valueToSum: product.price.doubleValue, parameters: finalProperties)
    }
}*/


public class FacebookProvider : BaseProvider<FBSDKApplicationDelegate>, AnalyticalProvider {
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
        
        let finalProperties = prepare(properties: mergeGlobal(properties: properties, overwrite: true))
        
        FBSDKAppEvents.logEvent(name, parameters: finalProperties)
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
        FBSDKAppEvents.updateUserProperties(prepare(properties: properties), handler: nil)
    }
    
    public func increment(property: String, by number: NSDecimalNumber) {
        FBSDKAppEvents.logEvent(property, valueToSum: number.doubleValue)
    }
    
    public override func purchase(amount: NSDecimalNumber, properties: Properties?) {
        let properties = preparePurchase(properties: mergeGlobal(properties: properties, overwrite: true))
        
        let currency = properties[Property.Purchase.currency.rawValue] as? String
        
        var finalParameters : [String : Any] = [:]
        finalParameters[FBSDKAppEventParameterNameContentType] = properties[Property.category.rawValue]
        finalParameters[FBSDKAppEventParameterNameContentID] = properties[Property.Purchase.sku.rawValue]
        finalParameters[FBSDKAppEventParameterNameCurrency] = currency
        
        FBSDKAppEvents.logPurchase(amount.doubleValue, currency: currency, parameters: finalParameters)
    }
    
    public override func addDevice(token: Data) {
        FBSDKAppEvents.setPushNotificationsDeviceToken(token)
    }
    public override func push(payload: [AnyHashable : Any], event: EventName?) {
        FBSDKAppEvents.logPushNotificationOpen(payload, action: event)
    }
    
    
    //
    // MARK: Private Methods
    //
    
    private func prepare(properties: Properties?) -> Properties? {
        guard let properties = properties else {
            return nil
        }
        
        var finalProperties : Properties = [:]
        
        for (property, value) in properties {
            
            if value is String || value is Int || value is Bool || value is Double || value is Float {
                finalProperties[property] = value
            }
            else {
                finalProperties[property] = String(describing: value)
            }
            
        }
        
        return finalProperties
    }
    
    
    private func preparePurchase(properties: Properties?) -> Properties {
        var currentProperties : Properties! = properties
        
        if currentProperties == nil {
            currentProperties = [:]
        }
        
        return currentProperties
    }
}
