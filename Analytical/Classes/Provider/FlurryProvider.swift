//
//  FlurryProvider.swift
//  Analytical
//
//  Created by Dal Rupnik on 18/07/16.
//  Copyright © 2016 Unified Sense. All rights reserved.
//

import Flurry_iOS_SDK

public class FlurryProvider : BaseProvider<Flurry>, AnalyticalProvider {
    private var key : String
    
    public static let ApiKey = "ApiKey"
    
    public init (key: String) {
        self.key = key
        
        super.init()
    }
    
    public func setup(with properties: Properties?) {
        if let key = properties?[FlurryProvider.ApiKey] as? String {
            self.key = key
        }
        
        if let launchOptions = properties?[Property.Launch.options.rawValue] as? [UIApplicationLaunchOptionsKey: Any] {
            Flurry.startSession(key, withOptions: launchOptions)
        }
        else {
            Flurry.startSession(key)
        }
    }
    
    public func flush() {
    }
    
    public func reset() {
        
    }
    
    public override func event(_ event: AnalyticalEvent) {
        switch event.type {
            case 
        }
    }
    
    public override func event(name: EventName, properties: Properties?) {
        let finalProperties = prepare(properties: mergeGlobal(properties: properties, overwrite: true))
        
        Flurry.logEvent(name, withParameters: finalProperties)
    }
    
    public func screen(name: EventName, properties: Properties?) {
        let finalProperties = prepare(properties: mergeGlobal(properties: properties, overwrite: true))
        
        Flurry.logEvent(name, withParameters: finalProperties)
        Flurry.logPageView()
    }
    
    public override func time(name: EventName, properties: Properties?) {
        super.time(name: name, properties: properties)
        
        let finalProperties = prepare(properties: mergeGlobal(properties: properties, overwrite: true))
        
        Flurry.logEvent(name, withParameters: finalProperties, timed: true)
    }
    
    public func finishTime(_ name: EventName, properties: Properties?) {
        
        let finalProperties = prepare(properties: mergeGlobal(properties: properties, overwrite: true))
        
        Flurry.endTimedEvent(name, withParameters: finalProperties)
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
        
        Flurry.sessionProperties(prepare(properties: properties)!)
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
    
    private func prepare(properties: Properties?) -> [String : Any]? {
        guard let properties = properties else {
            return nil
        }
        
        var finalProperties : [String : Any] = [:]
        
        for (property, value) in properties {
            
            // Flurry will stop working and not send any property data, if there is an object that does not respond to "length"
            finalProperties[property] = String(describing: value)
        }
        
        return finalProperties
    }
}
