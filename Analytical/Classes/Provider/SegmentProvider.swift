//
//  Segment.swift
//  Application
//
//  Created by Dal Rupnik on 18/07/16.
//  Copyright © 2016 Blub Blub. All rights reserved.
//

import Analytics

public class SegmentProvider : Provider <SEGAnalytics>, Analytical {
    public static let Configuration = "Configuration" // Needs a type SEGAnalyticsConfiguration
    public static let WriteKey      = "WriteKey"    // Needs a String
    
    //
    // MARK: Private Properties
    //
    
    private var _userId = ""
    private var _properties : Properties? = nil
    
    //
    // MARK: Analytical
    //
    
    public var uncaughtExceptions: Bool = false
    
    public func setup (properties : Properties? = nil) {
        if let configuration = properties?[SegmentProvider.Configuration] as? SEGAnalyticsConfiguration {
            SEGAnalytics.setupWithConfiguration(configuration)
        }
        else if let writeKey = properties?[SegmentProvider.WriteKey] as? String {
            let configuration = SEGAnalyticsConfiguration(writeKey: writeKey)
            
            SEGAnalytics.setupWithConfiguration(configuration)
        }
        
        instance = SEGAnalytics.sharedAnalytics()
    }
    
    public func flush() {
        instance.flush()
    }
    
    public func reset() {
        instance.reset()
    }
    
    public func event(name: EventName, properties: Properties?) {
        instance.track(name, properties: properties)
    }
    
    public func screen(name: EventName, properties: Properties?) {
        instance.screen(name, properties: properties)
    }
    
    public func finishTime(name: EventName, properties: Properties?) {
        
        var properties = properties
        
        if properties == nil {
            properties = [:]
        }
        
        properties![Property.Time.rawValue] = events[name]
        
        instance.track(name, properties: properties)
    }
    
    public func identify(userId: String, properties: Properties?) {
        _userId = userId
        _properties = properties
        
        instance.identify(userId, traits: properties)
    }
    
    public func alias(userId: String, forId: String) {
        instance.alias(userId)
    }
    
    public func set(properties: Properties) {
        //
        // Segment has no specific user dictionary method, so we remember user's properties,
        // every time it is identified. This method combines the properties with new properties,
        // thus always identifying same user with larger set of properties.
        //
        
        var finalProperties = properties
        
        if let existingProperties = _properties {
            for (key, value) in existingProperties {
                if finalProperties[key] == nil {
                    finalProperties[key] = value
                }
            }
            
            _properties = finalProperties
        }
        
        instance.identify(_userId, traits: finalProperties)
    }
    
    public func increment(property: String, by number: NSDecimalNumber) {
        
    }
    
    public func purchase(amount: NSDecimalNumber, properties: Properties?) {
        var properties = properties
        
        if properties == nil {
            properties = [:]
        }
        
        properties![Property.Purchase.Price.rawValue] = amount
        
        instance.track(DefaultEvent.Purchase.rawValue, properties: properties)
    }
}
