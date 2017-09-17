//
//  Segment.swift
//  Analytical
//
//  Created by Dal Rupnik on 18/07/16.
//  Copyright © 2017 Unified Sense. All rights reserved.
//

import Analytics

public class SegmentProvider : BaseProvider <SEGAnalytics>, AnalyticalProvider {
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
    
    open override func event(_ event: AnalyticalEvent) {
        guard let event = update(event: event) else {
            return
        }
        switch event.type {
        case .default:
            let finalProperties = mergeGlobal(properties: event.properties, overwrite: true)
            
            instance.track(event.name, properties: finalProperties)
        case .screen:
            let finalProperties = mergeGlobal(properties: event.properties, overwrite: true)
            
            instance.screen(event.name, properties: finalProperties)
        case .finishTime:
            
            var properties = mergeGlobal(properties: event.properties, overwrite: true)
            
            properties[Property.time.rawValue] = events[event.name]
            
            instance.track(event.name, properties: properties)
        case .purchase:
            let properties = mergeGlobal(properties: event.properties, overwrite: true)
            
            instance.track(DefaultEvent.purchase.rawValue, properties: properties)
        default:
            super.event(event)
        }
        
        delegate?.analyticalProviderDidSendEvent(self, event: event)
    }
    
    open func identify(userId: String, properties: Properties?) {
        _userId = userId
        _properties = properties
        
        instance.identify(userId, traits: properties)
    }
    
    open func alias(userId: String, forId: String) {
        instance.alias(userId)
    }
    
    open func set(properties: Properties) {
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
    
    open func increment(property: String, by number: NSDecimalNumber) {
        
    }
    
    public override func addDevice(token: Data) {
        instance.registeredForRemoteNotifications(withDeviceToken: token)
    }
    public override func push(payload: [AnyHashable : Any], event: EventName?) {
        instance.receivedRemoteNotification(payload)
    }
}
