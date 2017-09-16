//
//  FirebaseProvider.swift
//  Analytical
//
//  Created by Dal Rupnik on 30/05/17.
//  Copyright © 2017 Unified Sense. All rights reserved.
//

import Analytical
import Firebase

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
    
    
    public override func event(name: EventName, properties: Properties?) {
        //Analytics.logEvent(Ana, parameters: )
        
        //Analytics.logEvent(withName: name, parameters: mergeGlobal(properties: properties, overwrite: true))
    }
    
    public func screen(name: EventName, properties: Properties?) {
        //Analytics.setScreenName(name, screenClass: nil)
    }
    
    public func finishTime(_ name: EventName, properties: Properties?) {
        //Analytics.logEvent(withName: name, parameters: mergeGlobal(properties: properties, overwrite: true))
    }
    
    public func flush() {
    }
    
    public func reset() {
        
    }
    
    
    public override func time(name: EventName, properties: Properties?) {
        
    }
    
    public override func activate() {
        Analytics.logEvent(AnalyticsEventAppOpen, parameters: [:])
    }
    
    public override func resign() {
        
    }
    
    public override func global(properties: Properties, overwrite: Bool) {
        
    }
    
    public override func addDevice(token: Data) {
        
    }
    
    public override func push(payload: [AnyHashable : Any], event: EventName?) {
        
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
