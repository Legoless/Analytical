//
//  Provider.swift
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
open class Provider <T> : NSObject {
    
    // Stores global properties
    private var globalProperties : Properties?
    
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
    
    open func event(name: EventName, properties: Properties? = nil) {
        //
        // A Generic Provider has no way to know how to send events.
        //
        assert(false)
    }
    
    open func global(properties: Properties, overwrite: Bool = true) {
        globalProperties = mergeGlobal(properties: properties, overwrite: overwrite)
    }
    
    open func time(name: EventName, properties: Properties? = nil) {
        events[name] = Date()
        
        if let properties = properties {
            self.properties[name] = properties
        }
    }
    
    open func finish(name: EventName, properties: Properties?) {
        
        var properties = properties
        
        if properties == nil {
            properties = [:]
        }
        
        if let time = events[name] {
            properties![Property.time.rawValue] = time.timeIntervalSinceNow as AnyObject?
        }
        
        event(name: name, properties: properties)
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
