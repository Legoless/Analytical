//
//  ProviderState.swift
//  Analytical
//
//  Created by Vid Vozelj on 5. 8. 25.
//

import Foundation

public actor ProviderState {
    public var globalProperties: Properties?
    public var events: [EventName : Date] = [:]
    public var properties: [EventName : Properties]  = [:]
        
    public init() { }
    
    public var delegate: (any AnalyticalProviderDelegate)?
    
    public func getDelegate() async -> AnalyticalProviderDelegate? {
        delegate
    }
    
    public func setDelegate(_ delegate: AnalyticalProviderDelegate?) async {
        self.delegate = delegate
    }
    
    public func activate() async {}
    
    public func resign() async {}
    
    public func event(_ event: AnalyticalEvent) async {
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
    
    public func update(event: AnalyticalEvent) async -> AnalyticalEvent? {
        if let delegate = delegate, let selfProvider = self as? AnalyticalProvider {
            return delegate.analyticalProviderShouldSendEvent(selfProvider, event: event)
        }
        else {
            return event
        }
    }
    
    public func global(properties: Properties, overwrite: Bool) async {
        globalProperties = await mergeGlobal(properties: properties, overwrite: overwrite)
    }
    
    public func addDevice(token: Data) async {
        // No push feature
    }
    
    public func push(payload: Properties, event: EventName?) async {
        // No push logging feature, so we log a default event
        
        let properties : Properties? = (payload as? Properties) ?? nil
        
        let defaultEvent = AnalyticalEvent(type: .default, name: DefaultEvent.pushNotification.rawValue, properties: properties)
        
        await self.event(defaultEvent)
    }
    
    public func mergeGlobal(properties: Properties?, overwrite: Bool) async -> Properties {
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
