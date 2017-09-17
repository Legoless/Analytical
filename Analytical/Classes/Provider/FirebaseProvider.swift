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
}
