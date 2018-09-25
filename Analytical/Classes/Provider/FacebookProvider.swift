//
//  Facebook.swift
//  Analytical
//
//  Created by Dal Rupnik on 18/07/16.
//  Copyright © 2018 Unified Sense. All rights reserved.
//

import FBSDKCoreKit

public class FacebookProvider : BaseProvider<FBSDKApplicationDelegate>, AnalyticalProvider {
    
    //
    // MARK: Analytical
    //
    
    public func setup(with properties: Properties?) {
        instance = FBSDKApplicationDelegate.sharedInstance()
        
        if let application = properties?[Property.Launch.application.rawValue] as? UIApplication {
            instance.application(application, didFinishLaunchingWithOptions: properties?[Property.Launch.options.rawValue] as? [UIApplication.LaunchOptionsKey: Any])
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
    
    public override func event(_ event: AnalyticalEvent) {
        guard let event = update(event: event) else {
            return
        }
        
        switch event.type {
        case .time:
            super.event(event)
        case .finishTime:
            super.event(event)
            
            FBSDKAppEvents.logEvent(event.name, parameters: event.properties)
        default:
            if event.type == .purchase {
                
                let price = (event.properties?[Property.Purchase.price.rawValue] as? NSDecimalNumber)?.doubleValue
                var currency = event.properties?[Property.Purchase.currency.rawValue] as? String
                
                if currency == nil {
                    currency = event.properties?[FBSDKAppEventParameterNameCurrency] as? String
                }
                
                FBSDKAppEvents.logPurchase(price ?? 0.0, currency: currency, parameters: event.properties!)
            }
            else {
                FBSDKAppEvents.logEvent(event.name, parameters: event.properties)
            }
        }
        
        delegate?.analyticalProviderDidSendEvent(self, event: event)
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
    
    public override func addDevice(token: Data) {
        FBSDKAppEvents.setPushNotificationsDeviceToken(token)
    }
    public override func push(payload: [AnyHashable : Any], event: EventName?) {
        FBSDKAppEvents.logPushNotificationOpen(payload, action: event)
    }
    
    public override func update(event: AnalyticalEvent) -> AnalyticalEvent? {
        //
        // Ensure Super gets a chance to update event.
        //
        guard var event = super.update(event: event) else {
            return nil
        }
        
        //
        // Update event name and properties based on Facebook's values
        //
        
        if let defaultName = DefaultEvent(rawValue: event.name), let updatedName = parse(name: defaultName) {
            event.name = updatedName
        }
        
        event.properties = prepare(properties: mergeGlobal(properties: event.properties, overwrite: true))
        
        return event
    }
    
    //
    // MARK: Private Methods
    //
    
    private func parse(name: DefaultEvent) -> String? {
        switch name {
        case .completedRegistration:
            return FBSDKAppEventNameCompletedRegistration
        case .completedTutorial:
            return FBSDKAppEventNameCompletedTutorial
        case .addedToCart:
            return FBSDKAppEventNameAddedToCart
        case .viewContent:
            return FBSDKAppEventNameViewedContent
        case .initiatedCheckout:
            return FBSDKAppEventNameInitiatedCheckout
        case .rating:
            return FBSDKAppEventNameRated
        case .addedPaymentInfo:
            return FBSDKAppEventNameAddedPaymentInfo
        case .achievedLevel:
            return FBSDKAppEventNameAchievedLevel
        case .addedToWishlist:
            return FBSDKAppEventNameAddedToWishlist
        case .search:
            return FBSDKAppEventNameSearched
        case .spendCredits:
            return FBSDKAppEventNameSpentCredits
        case .unlockedAchievement:
            return FBSDKAppEventNameUnlockedAchievement
        case .contact:
            return FBSDKAppEventNameContact
        case .customizeProduct:
            return FBSDKAppEventNameCustomizeProduct
        case .donate:
            return FBSDKAppEventNameDonate
        case .findLocation:
            return FBSDKAppEventNameFindLocation
        case .schedule:
            return FBSDKAppEventNameSchedule
        case .startTrial:
            return FBSDKAppEventNameStartTrial
        case .submitApplication:
            return FBSDKAppEventNameSubmitApplication
        case .subscribe:
            return FBSDKAppEventNameSubscribe
        case .adImpression:
            return FBSDKAppEventNameAdImpression
        case .adClick:
            return FBSDKAppEventNameAdClick
        default:
            return nil
        }
    }
    
    private func prepare(properties: Properties?) -> Properties? {
        guard let properties = properties else {
            return nil
        }
        
        var finalProperties : Properties = [:]
        
        for (property, value) in properties {
            
            let property = parse(property: property)
            
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
    
    private func parse(property: String) -> String {
        switch property {
        case Property.Purchase.category.rawValue:
            return FBSDKAppEventParameterNameContentType
        case Property.Purchase.sku.rawValue:
            return FBSDKAppEventParameterNameContentID
        case Property.Purchase.currency.rawValue:
            return FBSDKAppEventParameterNameCurrency
        default:
            return property
        }
    }
}
