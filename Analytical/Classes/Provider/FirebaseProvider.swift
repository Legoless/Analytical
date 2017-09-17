//
//  FirebaseProvider.swift
//  Analytical
//
//  Created by Dal Rupnik on 30/05/17.
//  Copyright © 2017 Unified Sense. All rights reserved.
//

import Analytical
import Firebase

public enum FirebaseProperties : String {
    case customOne
    case creativeName
    case creativeSlot
    case groupId
    case index
    case locationId
    
    case numberOfNights
    case numberOfPassengers
    case numberOfRooms
    
    case travelClass
}

public class FirebaseProvider : BaseProvider<Firebase.Analytics>, AnalyticalProvider {
    
    public static let GoogleAppId = "GoogleAppIdKey"
    public static let BundleId = "BundleIdKey"
    public static let GCMSenderId = "GCMSenderID"
    
    public func setup(with properties: Properties?) {
        
        guard let googleAppId = properties?[FirebaseProvider.GoogleAppId] as? String, let gcmSenderId = properties?[FirebaseProvider.GCMSenderId] as? String else {
            return
        }
        
        let options = FirebaseOptions(googleAppID: googleAppId, gcmSenderID: gcmSenderId)
        
        if let bundleId = properties?[FirebaseProvider.BundleId] as? String {
            options.bundleID = bundleId
        }
        
        FirebaseApp.configure(options: options)
    }
    
    public override func event(_ event: AnalyticalEvent) {
        guard let event = update(event: event) else {
            return
        }
        
        switch event.type {
        case .default:
            Analytics.logEvent(event.name, parameters: mergeGlobal(properties: event.properties, overwrite: true))
        case .screen:
            Analytics.setScreenName(event.name, screenClass: nil)
        case .finishTime:
            super.event(event)
            
            Analytics.logEvent(event.name, parameters: mergeGlobal(properties: event.properties, overwrite: true))
        default:
            super.event(event)
        }
        
        delegate?.analyticalProviderDidSendEvent(self, event: event)
    }
    
    public func flush() {
    }
    
    public func reset() {
        
    }
    
    public override func activate() {
        Analytics.logEvent(AnalyticsEventAppOpen, parameters: [:])
    }
    
    public func identify(userId: String, properties: Properties?) {
        Analytics.setUserID(userId)
        
        if let properties = properties {
            set(properties: properties)
        }
    }
    
    public func alias(userId: String, forId: String) {
    }
    
    public func set(properties: Properties) {
        
        for (property, value) in properties {
            guard let value = value as? String else {
                continue
            }
            
            Analytics.setUserProperty(value, forName: property)
        }
        
    }
    
    public func increment(property: String, by number: NSDecimalNumber) {
        
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
        case .addedPaymentInfo:
            return AnalyticsEventAddPaymentInfo
        case .addedToWishlist:
            return AnalyticsEventAddToWishlist
        case .completedTutorial:
            return AnalyticsEventTutorialComplete
        case .addedToCart:
            return AnalyticsEventAddToCart
        case .viewContent:
            return AnalyticsEventSelectContent
        case .initiatedCheckout:
            return AnalyticsEventBeginCheckout
        case .campaignEvent:
            return AnalyticsEventCampaignDetails
        case .checkoutProgress:
            return AnalyticsEventCheckoutProgress
        case .earnCredits:
            return AnalyticsEventEarnVirtualCurrency
        case .purchase:
            return AnalyticsEventEcommercePurchase
        case .joinGroup:
            return AnalyticsEventJoinGroup
        case .generateLead:
            return AnalyticsEventGenerateLead
        case .levelUp:
            return AnalyticsEventLevelUp
        case .signUp:
            return AnalyticsEventLogin
        case .postScore:
            return AnalyticsEventPostScore
        case .presentOffer:
            return AnalyticsEventPresentOffer
        case .refund:
            return AnalyticsEventPurchaseRefund
        case .removeFromCart:
            return AnalyticsEventRemoveFromCart
        case .search:
            return AnalyticsEventSearch
        case .checkoutOption:
            return AnalyticsEventSetCheckoutOption
        case .share:
            return AnalyticsEventShare
        case .completedRegistration:
            return AnalyticsEventSignUp
        case .spendCredits:
            return AnalyticsEventSpendVirtualCurrency
        case .beganTutorial:
            return AnalyticsEventTutorialBegin
        case .unlockedAchievement:
            return AnalyticsEventUnlockAchievement
        case .viewItem:
            return AnalyticsEventViewItem
        case .viewItemList:
            return AnalyticsParameterItemList
        case .searchResults:
            return AnalyticsEventViewSearchResults
        default:
            return nil
        }
    }
    
    private func prepare(properties: Properties?) -> Properties? {
        guard let properties = properties else {
            return nil
        }
        
        var finalProperties : Properties = properties
        
        for (property, value) in properties {
            
            let property = parse(property: property)
            
            finalProperties[property] = value
        }
        
        return finalProperties
    }
    
    
    private func parse(property: String) -> String {
        switch property {
        case Property.Purchase.quantity.rawValue:
            return AnalyticsParameterQuantity
        case Property.Purchase.item.rawValue:
            return AnalyticsParameterItemName
        case Property.Purchase.sku.rawValue:
            return AnalyticsParameterItemID
        case Property.Purchase.category.rawValue:
            return AnalyticsParameterItemCategory
        case Property.Purchase.source.rawValue:
            return AnalyticsParameterItemLocationID
        case Property.Purchase.price.rawValue:
            return AnalyticsParameterPrice
        case Property.Purchase.currency.rawValue:
            return AnalyticsParameterCurrency
        case Property.Location.origin.rawValue:
            return AnalyticsParameterOrigin
        case Property.Location.destination.rawValue:
            return AnalyticsParameterDestination
        case Property.startDate.rawValue:
            return AnalyticsParameterStartDate
        case Property.endDate.rawValue:
            return AnalyticsParameterEndDate
        case Property.Purchase.medium.rawValue:
            return AnalyticsParameterMedium
        case Property.Purchase.campaign.rawValue:
            return AnalyticsParameterCampaign
        case Property.term.rawValue:
            return AnalyticsParameterTerm
        case Property.Content.identifier.rawValue:
            return AnalyticsParameterContent
        case Property.User.registrationMethod.rawValue:
            return AnalyticsParameterSignUpMethod
        default:
            return property
        }
    }
}
