//
//  FirebaseProvider.swift
//  Analytical
//
//  Created by Dal Rupnik on 30/05/17.
//  Copyright © 2017 Unified Sense. All rights reserved.
//

import Analytical
import Firebase

public class FirebaseProvider : Provider<FIRAnalytics>, Analytical {
    private var key : String
    
    public static let ApiKey = "ApiKey"
    
    public init (key: String) {
        self.key = key
        
        super.init()
    }
    
    public func setup(with properties: Properties?) {
        FIRApp.configure()
    }
    
    public func flush() {
    }
    
    public func reset() {
        
    }
    
    public override func event(name: EventName, properties: Properties?) {
        FIRAnalytics.logEvent(withName: name, parameters: mergeGlobal(properties: properties, overwrite: true))
    }
    
    public func screen(name: EventName, properties: Properties?) {
        FIRAnalytics.setScreenName(name, screenClass: nil)
    }
    
    public func finishTime(_ name: EventName, properties: Properties?) {
        FIRAnalytics.logEvent(withName: name, parameters: mergeGlobal(properties: properties, overwrite: true))
    }
    
    public func identify(userId: String, properties: Properties?) {
        FIRAnalytics.setUserID(userId)
        
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
            
            FIRAnalytics.setUserPropertyString(value, forName: property)
        }

    }
    
    public func increment(property: String, by number: NSDecimalNumber) {
        
    }
}
