//
//  FlurryProvider.swift
//  Analytical
//
//  Created by Dal Rupnik on 18/07/16.
//  Copyright © 2016 Unified Sense. All rights reserved.
//

import Flurry_iOS_SDK

public class FlurryProvider : Provider<Flurry>, Analytical {
    private var key : String
    
    public static let ApiKey = "ApiKey"
    
    public var uncaughtExceptions: Bool = false {
        didSet {
            Flurry.setCrashReportingEnabled(uncaughtExceptions)
        }
    }
    
    public init (key: String) {
        self.key = key
        
        super.init()
    }
    
    public func setup(with properties: Properties?) {
        if let key = properties?[FlurryProvider.ApiKey] as? String {
            self.key = key
        }
        
        Flurry.startSession(key)
    }
    
    public func flush() {
    }
    
    public func reset() {
        
    }
    
    public override func event(name: EventName, properties: Properties?) {
        Flurry.logEvent(name, withParameters: properties)
    }
    
    public func screen(name: EventName, properties: Properties?) {
        Flurry.logEvent(name, withParameters: properties)
        Flurry.logPageView()
    }
    
    public override func time(name: EventName, properties: Properties?) {
        super.time(name: name, properties: properties)
        
        Flurry.logEvent(name, withParameters: properties, timed: true)
    }
    
    public func finishTime(_ name: EventName, properties: Properties?) {
        Flurry.endTimedEvent(name, withParameters: properties)
    }
    
    public func identify(userId: String, properties: Properties?) {
        Flurry.setUserID(userId)
        
        if let properties = properties {
            set(properties: properties)
        }
    }
    
    public func alias(userId: String, forId: String) {
        //
        // Flurry has no specific Alias mechanism, so just set the forId.
        //
        Flurry.setUserID(forId)
    }
    
    open func set(properties: Properties) {
        if let age = properties[Property.User.age.rawValue] as? Int32 {
            Flurry.setAge(age)
        }
        
        if let gender = properties[Property.User.gender.rawValue] as? String {
            Flurry.setGender(gender)
        }
        
        //
        // Other properties will be discarded.
        //
        // TODO: Under debug configurations, print out a warning.
        //
    }
    
    public func increment(property: String, by number: NSDecimalNumber) {
        
    }
    
    public func purchase(amount: NSDecimalNumber, properties: Properties?) {
        event(name: DefaultEvent.purchase.rawValue, properties: properties)
    }    
}
