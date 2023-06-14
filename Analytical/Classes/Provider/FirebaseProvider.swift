//
//  FirebaseProvider.swift
//  Analytical
//
//  Created by Dal Rupnik on 30/05/17.
//  Copyright © 2017 Unified Sense. All rights reserved.
//


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

public class FirebaseProvider: BaseProvider<Firebase.Analytics>, AnalyticalProvider {
    public static let GoogleAppId = "GoogleAppIdKey"
    public static let BundleId = "BundleIdKey"
    public static let APIKey = "APIKey"
    public static let ProjectID = "ProjectID"
    public static let GCMSenderId = "GCMSenderID"
    
    public func setup(with properties: Properties?) {
        
        guard let googleAppId = properties?[FirebaseProvider.GoogleAppId] as? String, let gcmSenderId = properties?[FirebaseProvider.GCMSenderId] as? String, let apiKey = properties?[FirebaseProvider.APIKey] as? String, let projectID = properties?[FirebaseProvider.ProjectID] as? String, let bundleId = properties?[FirebaseProvider.BundleId] as? String else {
            return
        }
        
        let options = FirebaseOptions(googleAppID: googleAppId, gcmSenderID: gcmSenderId)
        
        options.bundleID = bundleId
        
        options.apiKey = apiKey
        
        options.projectID = projectID
        
        FirebaseApp.configure(options: options);
    }
    
    public override func event(_ event: AnalyticalEvent) {
            guard let event = update(event: event) else {
                return
            }
            
            switch event.type {
            case .default, .purchase:
                Analytics.logEvent(event.name, parameters: mergeGlobal(properties: event.properties, overwrite: true))
            case .screen:
                Analytics.logEvent(AnalyticsEventScreenView,
                                   parameters: [AnalyticsParameterScreenName: event.name])
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
            
            let properties = prepare(properties: properties)!
            
            for (property, value) in properties {
                if let value = value as? String {
                    Analytics.setUserProperty(value, forName: property)
                }
                else {
                    Analytics.setUserProperty(String(describing: value), forName: property)
                }
                
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
            case .earnCredits:
                return AnalyticsEventEarnVirtualCurrency
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
            case .removeFromCart:
                return AnalyticsEventRemoveFromCart
            case .search:
                return AnalyticsEventSearch
            case .share:
                return AnalyticsEventShare
            case .completedRegistration:
                return AnalyticsEventSignUp
            case .spendCredits:
                return AnalyticsEventSpendVirtualCurrency
            case .beginTutorial:
                return AnalyticsEventTutorialBegin
            case .unlockedAchievement:
                return AnalyticsEventUnlockAchievement
            case .viewItem:
                return AnalyticsEventViewItem
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
                
                if let parsed = parse(value: value) {
                    finalProperties[property] = parsed
                }
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
            case Property.Purchase.price.rawValue:
                return AnalyticsParameterValue
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
            default:
                return property
            }
        }
        
        private func parse(value: Any) -> Any? {
            if let string = value as? String {
                if string.count > 35 {
                    let maxTextSize = string.index(string.startIndex, offsetBy: 35)
                    let substring = string[..<maxTextSize]
                    return String(substring)
                }
                
                return value
            }
            
            if let number = value as? Int {
                return NSNumber(value: number)
            }
            
            if let number = value as? UInt {
                return NSNumber(value: number)
            }
            
            if let number = value as? Bool {
                return NSNumber(value: number)
            }
            
            if let number = value as? Float {
                return NSNumber(value: number)
            }
            
            if let number = value as? Double {
                return NSNumber(value: number)
            }
            
            return nil
        }
    }
