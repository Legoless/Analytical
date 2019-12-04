//
//  Facebook.swift
//  Analytical
//
//  Created by Dal Rupnik on 18/07/16.
//  Copyright © 2019 Unified Sense. All rights reserved.
//

import FBSDKCoreKit

open class FacebookProvider : BaseProvider<ApplicationDelegate>, AnalyticalProvider {
    public static let ignoreCustomEvents = "FacebookIgnoreCustomEvents"
    
    public var ignoreCustomEvents = false
    
    //
    // MARK: Analytical
    //
    
    public func setup(with properties: Properties?) {
        instance = ApplicationDelegate.shared
        
        if let application = properties?[Property.Launch.application.rawValue] as? UIApplication {
            instance.application(application, didFinishLaunchingWithOptions: properties?[Property.Launch.options.rawValue] as? [UIApplication.LaunchOptionsKey: Any])
        }
        
        if let ignoreCustomEvents = properties?[FacebookProvider.ignoreCustomEvents] as? Bool {
            self.ignoreCustomEvents = ignoreCustomEvents
        }
    }
    
    public override func activate() {
        AppEvents.activateApp()
    }
    
    public func flush() {
        AppEvents.flush()
    }
    
    public func reset() {
        //
        // No way to reset user properties with Facebook
        //
    }
    
    open override func event(_ event: AnalyticalEvent) {
        guard let event = update(event: event) else {
            return
        }
        
        switch event.type {
        case .time:
            super.event(event)
        case .finishTime:
            super.event(event)
            
            AppEvents.logEvent(AppEvents.Name(rawValue: event.name), parameters: event.properties ?? [:])
        default:
            if event.type == .purchase {
                
                let price = (event.properties?[Property.Purchase.price.rawValue] as? NSDecimalNumber)?.doubleValue
                var currency = event.properties?[Property.Purchase.currency.rawValue] as? String
                
                if currency == nil {
                    currency = event.properties?[AppEvents.ParameterName.currency.rawValue] as? String
                }
                
                AppEvents.logPurchase(price ?? 0.0, currency: currency ?? "USD", parameters: event.properties ?? [:])
            }
            else {
                AppEvents.logEvent(AppEvents.Name(rawValue: event.name), parameters: event.properties ?? [:])
            }
        }
        
        delegate?.analyticalProviderDidSendEvent(self, event: event)
    }
    
    public func identify(userId: String, properties: Properties?) {
        AppEvents.setUser(email: userId, firstName: nil, lastName: nil, phone: nil, dateOfBirth: nil, gender: nil, city: nil, state: nil, zip: nil, country: nil)
        
        if let properties = properties {
            set(properties: properties)
        }
    }
    
    public func alias(userId: String, forId: String) {
        //
        // No alias tracking with Facebook
        //
    }
    
    open func set(properties: Properties) {
        guard let preparedProperties = prepare(properties: properties) else {
            return
        }
        
        AppEvents.updateUserProperties(preparedProperties, handler: nil)
    }
    
    public func increment(property: String, by number: NSDecimalNumber) {
        AppEvents.logEvent(AppEvents.Name(rawValue: property), valueToSum: number.doubleValue)
    }
    
    public override func addDevice(token: Data) {
        AppEvents.setPushNotificationsDeviceToken(token)
    }
    public override func push(payload: [AnyHashable : Any], event: EventName?) {
        guard let event = event else {
            return
        }
        AppEvents.logPushNotificationOpen(payload, action: event)
    }
    
    open override func update(event: AnalyticalEvent) -> AnalyticalEvent? {
        //
        // Ensure Super gets a chance to update event.
        //
        guard var event = super.update(event: event) else {
            return nil
        }
        
        //
        // Update event name and properties based on Facebook's values
        //
        var shouldIgnoreCurrentEvent = ignoreCustomEvents
        
        if let defaultName = DefaultEvent(rawValue: event.name), let updatedName = parse(name: defaultName) {
            event.name = updatedName
            
            shouldIgnoreCurrentEvent = false
        }
        
        guard !shouldIgnoreCurrentEvent else {
            return nil
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
            return AppEvents.Name.completedRegistration.rawValue
        case .completedTutorial:
            return AppEvents.Name.completedTutorial.rawValue
        case .addedToCart:
            return AppEvents.Name.addedToCart.rawValue
        case .viewContent:
            return AppEvents.Name.viewedContent.rawValue
        case .initiatedCheckout:
            return AppEvents.Name.initiatedCheckout.rawValue
        case .rating:
            return AppEvents.Name.rated.rawValue
        case .addedPaymentInfo:
            return AppEvents.Name.addedPaymentInfo.rawValue
        case .achievedLevel:
            return AppEvents.Name.achievedLevel.rawValue
        case .addedToWishlist:
            return AppEvents.Name.addedToWishlist.rawValue
        case .search:
            return AppEvents.Name.searched.rawValue
        case .spendCredits:
            return AppEvents.Name.spentCredits.rawValue
        case .unlockedAchievement:
            return AppEvents.Name.unlockedAchievement.rawValue
        case .contact:
            return AppEvents.Name.contact.rawValue
        case .customizeProduct:
            return AppEvents.Name.customizeProduct.rawValue
        case .donate:
            return AppEvents.Name.donate.rawValue
        case .findLocation:
            return AppEvents.Name.findLocation.rawValue
        case .schedule:
            return AppEvents.Name.schedule.rawValue
        //case .subscriptionHeartbeat:
        //    return AppEvents.Name.subscriptionHeartbeat.rawValue
        case .startTrial:
            return AppEvents.Name.startTrial.rawValue
        case .submitApplication:
            return AppEvents.Name.submitApplication.rawValue
        case .subscribe:
            return AppEvents.Name.subscribe.rawValue
        case .adImpression:
            return AppEvents.Name.adImpression.rawValue
        case .adClick:
            return AppEvents.Name.adClick.rawValue
        default:
            return nil
        }
    }
    
    open func prepare(properties: Properties?) -> Properties? {
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
            return AppEvents.ParameterName.contentType.rawValue
        case Property.Purchase.sku.rawValue:
            return AppEvents.ParameterName.contentID.rawValue
        case Property.Purchase.currency.rawValue:
            return AppEvents.ParameterName.currency.rawValue
        default:
            return property
        }
    }
}
