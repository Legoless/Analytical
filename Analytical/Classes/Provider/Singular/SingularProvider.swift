//
//  SingularProvider.swift
//  Analytical
//
//  Created by Vid Vozelj on 4. 8. 25.
//

import Foundation
import Singular
import Analytical
import StoreKit

final public class SingularProvider: NSObject, AnalyticalProvider, SKPaymentTransactionObserver {
    public let actor = ProviderState()
    
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            Singular.iapComplete(transaction)
        }
    }
    
    fileprivate func setupObserver() {
        let queue = SKPaymentQueue.default()
        
        queue.add(self)
    }
        
    public static let ApiKey = "SingularApiKey"
    public static let Secret = "SingularSecret"
    public static let EspDomains = "SingularEspDomains"
    public static let DisableIAPTracking = "SingularDisableIAPTracking"    

    public func setup(with properties: Analytical.Properties?) async {
        let espDomains: [String] = (properties?[Self.EspDomains]?.unwrapped as? [String]) ?? []
        guard let key = properties?[Self.ApiKey]?.unwrapped as? String, let secret = properties?[Self.Secret]?.unwrapped as? String else {
            assertionFailure("No Api Key and/or Secret for Singular.")
            return
        }
        
        guard let config = buildConfig(key: key, secret: secret, espDomains: espDomains) else {
            return
        }
        
        Singular.start(config)
        
        let propertyIAPTracking = properties?[Self.DisableIAPTracking]?.unwrapped as? Bool ?? false
        
        if !propertyIAPTracking {
            setupObserver()
        }
    }
    
    public func event(_ event: AnalyticalEvent) {
        Task {
            guard let updatedEvent = await actor.update(event: event) else {
                return
            }
            
            let mappedEventName = map(eventName: updatedEvent.name)
            Singular.event(mappedEventName, withArgs: map(properties: updatedEvent.properties))
        
       
           await actor.getDelegate()?.analyticalProviderDidSendEvent(self, event: updatedEvent)
        }
    }
    
    public func identify(userId: String, properties: Analytical.Properties?) {
        Singular.setCustomUserId(userId)
    }
    
    public func set(properties: Analytical.Properties) {
        for (key, value) in properties {
            guard let stringValue = value.unwrapped as? String else {
                continue
            }
            Singular.setGlobalProperty(key, andValue: stringValue, overrideExisting: true)
        }
    }
    
    public func addDevice(token: Data) {
        Singular.registerDeviceToken(forUninstall: token)
    }
    
    
    private func buildConfig(key: String, secret: String, espDomains: [String] = []) -> SingularConfig? {
        // Create the config object with the SDK Key and SDK Secret
        guard let config = SingularConfig(apiKey: key, andSecret: secret) else {
            return nil
        }
        
        // Support custom ESP domains
        config.espDomains = espDomains
        
        return config
    }
    
    private func map(eventName: String) -> String {
        switch eventName {
        case DefaultEvent.rating.rawValue:
            return EVENT_SNG_RATE
        case DefaultEvent.spendCredits.rawValue:
            return EVENT_SNG_SPENT_CREDITS
        case DefaultEvent.completedTutorial.rawValue:
            return EVENT_SNG_TUTORIAL_COMPLETE
        case DefaultEvent.login.rawValue:
            return EVENT_SNG_LOGIN
        case DefaultEvent.subscribe.rawValue:
            return EVENT_SNG_SUBSCRIBE
        case DefaultEvent.startTrial.rawValue:
            return EVENT_SNG_START_TRIAL
        case DefaultEvent.viewItemList.rawValue:
            // Would this have to be Content View List?
            return EVENT_SNG_CONTENT_VIEW_LIST
        case DefaultEvent.invite.rawValue:
            return EVENT_SNG_INVITE
        case DefaultEvent.share.rawValue:
            return EVENT_SNG_SHARE
        case DefaultEvent.submitApplication.rawValue:
            return EVENT_SNG_SUBMIT_APPLICATION
        case DefaultEvent.purchase.rawValue:
            return EVENT_SNG_ECOMMERCE_PURCHASE
        case DefaultEvent.unlockedAchievement.rawValue:
            return EVENT_SNG_ACHIEVEMENT_UNLOCKED
        case DefaultEvent.addedPaymentInfo.rawValue:
            return EVENT_SNG_ADD_PAYMENT_INFO
        case DefaultEvent.addedToWishlist.rawValue:
            return EVENT_SNG_ADD_TO_WISHLIST
        case DefaultEvent.initiatedCheckout.rawValue:
            return EVENT_SNG_CHECKOUT_INITIATED
        case DefaultEvent.completedRegistration.rawValue:
            return EVENT_SNG_COMPLETE_REGISTRATION
        case DefaultEvent.viewContent.rawValue:
            return EVENT_SNG_CONTENT_VIEW
        case DefaultEvent.achievedLevel.rawValue:
            return EVENT_SNG_LEVEL_ACHIEVED
        case DefaultEvent.search.rawValue:
            return EVENT_SNG_SEARCH
        default:
            // Missing:
            // - Update
            // - View Cart
            return eventName
        }
    }
    
    private func map(properties: Properties?) -> [String: Any] {
        guard let properties = properties else {
            return [:]
        }
        
        var finalProperties: [String: Any] = [:]
        
        for (key, value) in properties {
            finalProperties[mapPropertyKey(key: key)] = value
        }
        
        return finalProperties
    }
    
    private func mapPropertyKey(key: String) -> String {
        switch key {
        case Property.Content.identifier.rawValue:
            return ATTRIBUTE_SNG_ATTR_CONTENT_ID
        case Property.Content.type.rawValue:
            return ATTRIBUTE_SNG_ATTR_CONTENT_TYPE
        case Property.User.level.rawValue:
            return ATTRIBUTE_SNG_ATTR_LEVEL
        case Property.Purchase.transactionId.rawValue:
            return ATTRIBUTE_SNG_ATTR_TRANSACTION_ID
        case Property.Purchase.sku.rawValue:
            return ATTRIBUTE_SNG_ATTR_SUBSCRIPTION_ID
        case Property.Content.score.rawValue:
            return ATTRIBUTE_SNG_ATTR_SCORE
        case Property.Content.searchTerm.rawValue:
            return ATTRIBUTE_SNG_ATTR_SEARCH_STRING
        case Property.Content.maxRating.rawValue:
            return ATTRIBUTE_SNG_ATTR_MAX
        case Property.Purchase.country.rawValue:
            return ATTRIBUTE_SNG_ATTR_COUNTRY
        case Property.Purchase.coupon.rawValue:
            return ATTRIBUTE_SNG_ATTR_COUPON_CODE
        case Property.User.registrationMethod.rawValue:
            return ATTRIBUTE_SNG_ATTR_REGISTRATION_METHOD
        case Property.Purchase.quantity.rawValue:
            return ATTRIBUTE_SNG_ATTR_QUANTITY
        case Property.Purchase.price.rawValue:
            return ATTRIBUTE_SNG_ATTR_ITEM_PRICE
        case Property.Purchase.item.rawValue:
            return ATTRIBUTE_SNG_ATTR_ITEM_DESCRIPTION
        case Property.Content.description.rawValue:
            return ATTRIBUTE_SNG_ATTR_CONTENT
        case Property.Purchase.itemList.rawValue:
            return ATTRIBUTE_SNG_ATTR_CONTENT_LIST
        case Property.Purchase.paymentInfoAvailable.rawValue:
            return ATTRIBUTE_SNG_ATTR_PAYMENT_INFO_AVAILABLE
        case Property.Purchase.source.rawValue:
            return ATTRIBUTE_SNG_ATTR_ORIGIN
        
        default:
            return key
        }
    }
    
    
    public func getDelegate() async -> AnalyticalProviderDelegate? {
        await actor.getDelegate()
    }
    public func setDelegate(_ delegate: AnalyticalProviderDelegate?) async {
        await actor.setDelegate(delegate)
    }
    public func activate() async {
        await actor.activate()
    }
    public func resign() async {
        await actor.resign()
    }
    public func global(properties: Properties, overwrite: Bool) async {
        await actor.global(properties: properties, overwrite: overwrite)
    }
    
    public func push(payload: Payload, event: Analytical.EventName?) { }
    public func flush() { }
    public func reset() { }
    public func alias(userId: String, forId: String) { }
    public func increment(property: String, by number: NSDecimalNumber) { }
}
