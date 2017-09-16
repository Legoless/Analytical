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
    public weak var delegate : AnalyticalProviderDelegate?
    
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
            events[name] = Date()
            
            if let properties = properties {
                self.properties[name] = properties
            }
        case .finishTime:
            
            var properties = properties
            
            if properties == nil {
                properties = [:]
            }
            
            if let time = events[name] {
                properties![Property.time.rawValue] = time.timeIntervalSinceNow as AnyObject?
            }
            
            let finishEvent = AnalyticalEvent(type: .default, name: event.name, properties: event.properties)
            
            event(finishEvent)
        default:
            //
            // A Generic Provider has no way to know how to send events.
            //
            assert(false)
        }
    }
    
    open func update(event: AnalyticalEvent) -> AnalyticalEvent? {
        if let delegate = delegate {
            return delegate.analyticalProviderWillSendEvent(self, event: event)
        }
        else {
            return event
        }
    }
    
    open func global(properties: Properties, overwrite: Bool = true) {
        globalProperties = mergeGlobal(properties: properties, overwrite: overwrite)
    }
        
    open func purchase(amount: NSDecimalNumber, properties: Properties?) {
        event(name: DefaultEvent.purchase.rawValue, properties: properties)
    }
    
    open func addDevice(token: Data) {
        // No push feature
    }
    open func push(payload: [AnyHashable : Any], event: EventName?) {
        // No push logging feature, so we log a default event
        
        let properties : Properties? = (payload as? Properties) ?? nil
        
        self.event(name: DefaultEvent.pushNotification.rawValue, properties: properties)
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
