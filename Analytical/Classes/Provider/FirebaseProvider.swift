//
//  FirebaseProvider.swift
//  SpeechBlubsPro
//
//  Created by Vid Vozelj on 08/06/2023.
//  Copyright © 2023 Blub Blub Inc. All rights reserved.
//

import Firebase
import Analytical

public class FirebaseProvider: BaseProvider<FirebaseApp>, AnalyticalProvider {
    public static let GoogleAppId = "GoogleAppIdKey"
    public static let BundleId = "BundleIdKey"
    public static let APIKey = "APIKey"
    public static let ProjectID = "ProjectID"
    public static let GCMSenderId = "GCMSenderID"
    
    public func setup(with properties: Analytical.Properties?) {
        
        guard let googleAppId = properties?[FirebaseProvider.GoogleAppId] as? String, let gcmSenderId = properties?[FirebaseProvider.GCMSenderId] as? String, let apiKey = properties?[FirebaseProvider.APIKey] as? String, let projectID = properties?[FirebaseProvider.ProjectID] as? String, let bundleId = properties?[FirebaseProvider.BundleId] as? String else {
            return
        }
        
        let options = FirebaseOptions(googleAppID: googleAppId, gcmSenderID: gcmSenderId)
        
        options.bundleID = bundleId
        
        options.apiKey = apiKey
        
        options.projectID = projectID
        
        FirebaseApp.configure(options: options);
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
    
    public override func event(_ event: AnalyticalEvent) {
        guard let event = update(event: event) else {
            return
        }
        switch event.type {
        case .default, .purchase:
            Analytics.logEvent(event.name, parameters: mergeGlobal(properties: event.properties, overwrite: true))
        case .finishTime:
            super.event(event)
            
            Analytics.logEvent(event.name, parameters: mergeGlobal(properties: event.properties, overwrite: true))
        default:
            super.event(event)
        }
        
        delegate?.analyticalProviderDidSendEvent(self, event: event)
    }
    
    public override func update(event: AnalyticalEvent) -> AnalyticalEvent? {
        //
        // Ensure Super gets a chance to update event.
        //
        guard var event = super.update(event: event) else {
            return nil
        }
        
        event.properties = prepare(properties: mergeGlobal(properties: event.properties, overwrite: true))
        
        return event
    }
    
    private func prepare(properties: Properties?) -> Properties? {
        guard let properties = properties else {
            return nil
        }
        
        var finalProperties : Properties = properties
        
        for (property, value) in properties {
            
            if let parsed = parse(value: value) {
                finalProperties[property] = parsed
            }
        }
        
        return finalProperties
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
    
    public func flush() {}
    
    public func reset() {}
    
    public func identify(userId: String, properties: Properties? = nil) {
        Analytics.setUserID(userId)
        
        if let properties = properties {
            set(properties: properties)
        }
    }
    
    public func alias(userId: String, forId: String) {
    }
    
    public func increment(property: String, by number: NSDecimalNumber) {
    }
}
