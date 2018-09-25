//
//  AppsFlyerProvider.swift
//  Analytical
//
//  Created by Dal Rupnik on 29/11/17.
//  Copyright © 2017 Unified Sense. All rights reserved.
//

import AppsFlyerLib
import Analytical

open class AppsFlyerProvider : BaseProvider<AppsFlyerTracker>, AnalyticalProvider {
    public static let DevKey = "AppFlyerDevKey"
    public static let AppleAppId = "AppleAppIdKey"
    
    open func setup(with properties: Properties?) {
        instance = AppsFlyerTracker.shared()
        
        if let devKey = properties?[AppsFlyerProvider.DevKey] as? String {
            instance.appsFlyerDevKey = devKey
        }
        
        if let appleAppId = properties?[AppsFlyerProvider.AppleAppId] as? String {
            instance.appleAppID = appleAppId
        }
    }
    
    open override func activate() {
        instance.trackAppLaunch()
    }
    
    open func flush() {

    }
    
    open func reset() {

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
        
        if let defaultName = DefaultEvent(rawValue: event.name), let updatedName = parse(name: defaultName) {
            event.name = updatedName
        }
        
        event.properties = prepare(properties: mergeGlobal(properties: event.properties, overwrite: true))
        
        return event
    }
    
    open override func event(_ event: AnalyticalEvent) {
        guard let event = update(event: event) else {
            return
        }
        
        switch event.type {
        case .default, .screen, .finishTime:
            instance.trackEvent(event.name, withValues: event.properties)
        case .purchase:
            if let price = event.properties?[Property.Purchase.price.rawValue] as? NSDecimalNumber {
                instance.validateAndTrack(inAppPurchase: event.properties?[Property.Purchase.sku.rawValue] as? String, price: price.stringValue, currency: event.properties?[Property.Purchase.currency.rawValue] as? String, transactionId: event.properties?[Property.Purchase.transactionId.rawValue] as? String, additionalParameters: event.properties, success: { object in }, failure: { error, object in })
            }
            else {
                instance.trackEvent(event.name, withValues: event.properties)
            }
        case .time:
            super.event(event)
        }
        
        delegate?.analyticalProviderDidSendEvent(self, event: event)
    }
    
    open func identify(userId: String, properties: Properties?) {
        instance.customerUserID = userId
        instance.setUserEmails([ userId ], with: EmailCryptTypeSHA256)
    }
    
    open func alias(userId: String, forId: String) {

    }
    
    open func set(properties: Properties) {

    }
    
    open override func global(properties: Properties, overwrite: Bool) {

    }
    
    open func increment(property: String, by number: NSDecimalNumber) {

    }
    
    open override func push(payload: [AnyHashable : Any], event: EventName?) {
        instance.handlePushNotification(payload)
    }
    
    open override func addDevice(token: Data) {
        instance.registerUninstall(token)
    }
    
    //
    // MARK: Private Methods
    //
    
    private func parse(name: DefaultEvent) -> String? {
        switch name {
        case .achievedLevel:
            return AFEventLevelAchieved
        case .addedPaymentInfo:
            return AFEventAddPaymentInfo
        case .addedToCart:
            return AFEventAddToCart
        case .addedToWishlist:
            return AFEventAddToWishlist
        case .completedRegistration:
            return AFEventCompleteRegistration
        case .completedTutorial:
            return AFEventTutorial_completion
        case .initiatedCheckout:
            return AFEventInitiatedCheckout
        case .purchase:
            return AFEventPurchase
        case .rating:
            return AFEventRate
        case .search:
            return AFEventSearch
        case .spendCredits:
            return AFEventSpentCredits
        case .unlockedAchievement:
            return AFEventAchievementUnlocked
        case .viewContent:
            return AFEventContentView
        case .viewItemList:
            return AFEventListView
        case .travelBooking:
            return AFEventTravelBooking
        case .share:
            return AFEventShare
        case .invite:
            return AFEventInvite
        case .login:
            return AFEventLogin
        case .findLocation:
            return AFEventLocation
        case .subscribe:
            return AFEventSubscribe
        case .startTrial:
            return AFEventStartTrial
        case .adImpression:
            return AFEventAdView
        case .adClick:
            return AFEventAdClick
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
            
            finalProperties[property] = value
        }
        
        return finalProperties
    }
    
    private func parse(property: String) -> String {
        switch property {
        case Property.Purchase.category.rawValue:
            return AFEventParamContentType
        case Property.Purchase.sku.rawValue:
            return AFEventParamContentId
        case Property.Purchase.currency.rawValue:
            return AFEventParamCurrency
        case Property.Purchase.price.rawValue:
            return AFEventParamRevenue
        case Property.Purchase.quantity.rawValue:
            return AFEventParamQuantity
        case Property.Content.searchTerm.rawValue:
            return AFEventParamSearchString
        case Property.Content.score.rawValue:
            return AFEventParamScore
        case Property.Content.description.rawValue:
            return AFEventParamDescription
        case Property.Content.maxRating.rawValue:
            return AFEventParamMaxRatingValue
        case Property.User.registrationMethod.rawValue:
            return AFEventParamRegistrationMethod
        case Property.User.level.rawValue:
            return AFEventParamLevel
        default:
            return property
        }
    }
}
