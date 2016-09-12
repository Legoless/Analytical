//
//  Provider.swift
//  Analytical
//
//  Created by Dal Rupnik on 18/07/16.
//  Copyright © 2016 Unified Sense. All rights reserved.
//

import Foundation

open class Provider <T> : NSObject {
    open var events : [EventName : Date] = [:]
    open var properties : [EventName : Properties] = [:]
    
    open var instance : T! = nil
    
    public override init () {
        super.init()
    }
    
    open func activate() {
        
    }
    
    open func event(_ name: EventName, properties: Properties? = nil) {
        //
        // A Generic Provider has no way to know how to send events.
        //
        assert(false)
    }
    
    open func time(_ name: EventName, properties: Properties? = nil) {
        events[name] = Date()
        
        if let properties = properties {
            self.properties[name] = properties
        }
    }
    
    open func finish(_ name: EventName, properties: Properties?) {
        
        var properties = properties
        
        if properties == nil {
            properties = [:]
        }
        
        if let time = events[name] {
            properties![Property.Time.rawValue] = time.timeIntervalSinceNow as AnyObject?
        }
        
        event(name, properties: properties)
    }
}
