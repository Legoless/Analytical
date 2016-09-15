//
//  Segment.swift
//  Analytical
//
//  Created by Dal Rupnik on 18/07/16.
//  Copyright © 2016 Unified Sense. All rights reserved.
//

import Analytics

open class SegmentProvider : Provider <SEGAnalytics>, Analytical {
    open static let Configuration = "Configuration" // Needs a type SEGAnalyticsConfiguration
    open static let WriteKey      = "WriteKey"    // Needs a String
    
    //
    // MARK: Private Properties
    //
    
    fileprivate var _userId = ""
    fileprivate var _properties : Properties? = nil
    
    //
    // MARK: Analytical
    //
    
    open var uncaughtExceptions: Bool = false
    
    open func setup (with properties : Properties? = nil) {
        if let configuration = properties?[SegmentProvider.Configuration] as? SEGAnalyticsConfiguration {
            SEGAnalytics.setup(with: configuration)
        }
        else if let writeKey = properties?[SegmentProvider.WriteKey] as? String {
            let configuration = SEGAnalyticsConfiguration(writeKey: writeKey)
            
            SEGAnalytics.setup(with: configuration)
        }
        
        instance = SEGAnalytics.shared()
    }
    
    open func flush() {
        instance.flush()
    }
    
    open func reset() {
        instance.reset()
    }
    
    open override func event(_ name: EventName, properties: Properties?) {
        instance.track(name, properties: properties)
    }
    
    open func screen(_ name: EventName, properties: Properties?) {
        instance.screen(name, properties: properties)
    }
    
    open func finishTime(_ name: EventName, properties: Properties?) {
        
        var properties = properties
        
        if properties == nil {
            properties = [:]
        }
        
        properties![Property.time.rawValue] = events[name]
        
        instance.track(name, properties: properties)
    }
    
    open func identify(_ userId: String, properties: Properties?) {
        _userId = userId
        _properties = properties
        
        instance.identify(userId, traits: properties)
    }
    
    open func alias(_ userId: String, forId: String) {
        instance.alias(userId)
    }
    
    open func set(_ properties: Properties) {
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
    
    open func increment(_ property: String, by number: NSDecimalNumber) {
        
    }
    
    open func purchase(_ amount: NSDecimalNumber, properties: Properties?) {
        var properties = properties
        
        if properties == nil {
            properties = [:]
        }
        
        properties![Property.Purchase.price.rawValue] = amount
        
        instance.track(DefaultEvent.purchase.rawValue, properties: properties)
    }
}
