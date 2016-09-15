//
//  FlurryProvider.swift
//  Analytical
//
//  Created by Dal Rupnik on 18/07/16.
//  Copyright © 2016 Unified Sense. All rights reserved.
//

import Flurry_iOS_SDK

public class FlurryProvider : Provider<Flurry>, Analytical {
    public static let ApiKey = "ApiKey"
    
    public var uncaughtExceptions: Bool = false {
        didSet {
            Flurry.setCrashReportingEnabled(uncaughtExceptions)
        }
    }
    
    public func setup(with properties: Properties?) {
        Flurry.startSession(properties?[FlurryProvider.ApiKey] as? String)
    }
    
    public func flush() {
    }
    
    public func reset() {
        
    }
    
    public override func event(_ name: EventName, properties: Properties?) {
        Flurry.logEvent(name, withParameters: properties)
    }
    
    public func screen(_ name: EventName, properties: Properties?) {
        Flurry.logEvent(name, withParameters: properties)
        Flurry.logPageView()
    }
    
    public override func time(_ name: EventName, properties: Properties?) {
        super.time(name, properties: properties)
        
        Flurry.logEvent(name, withParameters: properties, timed: true)
    }
    
    public func finishTime(_ name: EventName, properties: Properties?) {
        Flurry.endTimedEvent(name, withParameters: properties)
    }
    
    public func identify(_ userId: String, properties: Properties?) {
        Flurry.setUserID(userId)
        
        if let properties = properties {
            set(properties)
        }
    }
    
    public func alias(_ userId: String, forId: String) {
        //
        // Flurry has no specific Alias mechanism, so just set the forId.
        //
        Flurry.setUserID(forId)
    }
    
    open func set(_ properties: Properties) {
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
    
    public func increment(_ property: String, by number: NSDecimalNumber) {
        
    }
    
    public func purchase(_ amount: NSDecimalNumber, properties: Properties?) {
        event(DefaultEvent.purchase.rawValue, properties: properties)
    }    
}
