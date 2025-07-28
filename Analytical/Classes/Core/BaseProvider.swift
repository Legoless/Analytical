//
//  BaseProvider.swift
//  Analytical
//
//  Created by Dal Rupnik on 18/07/16.
//  Copyright © 2016 Unified Sense. All rights reserved.
//

import Foundation

///
/// Provider generic class
///
/// Analytics provider generic class provides some common analytics functionality.
///
open class BaseProvider <T> : NSObject {
    
    // Stores global properties
    private var globalProperties : Properties?
    
    // Delegate
    private var delegate: AnalyticalProviderDelegate?

    public func getDelegate() async -> AnalyticalProviderDelegate? {
        delegate
    }

    public func setDelegate(_ delegate: AnalyticalProviderDelegate?) async {
        self.delegate = delegate
    }
    
    open var events : [EventName : Date] = [:]
    open var properties : [EventName : Properties] = [:]
    
    open var instance : T! = nil
    
    public override init () {
        super.init()
    }
    
    open func activate() {
        
    }
    
    open func resign() {
        
    }
    
    open func event(_ event: AnalyticalEvent) {
        switch event.type {
        case .time:
            events[event.name] = Date()
            
            if let properties = event.properties {
                self.properties[event.name] = properties
            }
        case .finishTime:
            
            var properties = event.properties
            
            if properties == nil {
                properties = [:]
            }
            
            if let time = events[event.name] {
                properties![Property.time.rawValue] = SendableValue(time.timeIntervalSinceNow)
            }
        default:
            // A Generic Provider has no way to know how to send events.
            assert(false)
        }
    }
    
    open func update(event: AnalyticalEvent) -> AnalyticalEvent? {
        if let delegate = delegate, let selfProvider = self as? AnalyticalProvider {
            return delegate.analyticalProviderShouldSendEvent(selfProvider, event: event)
        }
        else {
            return event
        }
    }
    
    open func global(properties: Properties, overwrite: Bool = true) {
        globalProperties = mergeGlobal(properties: properties, overwrite: overwrite)
    }
    
    open func addDevice(token: Data) {
        // No push feature
    }
    open func push(payload: [AnyHashable : Any], event: EventName?) {
        // No push logging feature, so we log a default event
        
        let properties : Properties? = (payload as? Properties) ?? nil
        
        let defaultEvent = AnalyticalEvent(type: .default, name: DefaultEvent.pushNotification.rawValue, properties: properties)
        
        self.event(defaultEvent)
    }
    
    public func mergeGlobal(properties: Properties?, overwrite: Bool) -> Properties {
        var final : Properties = globalProperties ?? [:]
        
        if let properties = properties {
            for (property, value) in properties {
                if final[property] == nil || overwrite == true {
                    final[property] = value
                }
            }
        }
        
        return final
    }
}
