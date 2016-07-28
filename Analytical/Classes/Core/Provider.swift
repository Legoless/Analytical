//
//  Provider.swift
//  Application
//
//  Created by Dal Rupnik on 18/07/16.
//  Copyright © 2016 Blub Blub. All rights reserved.
//

import Foundation

public class Provider <T> : NSObject {
    var events : [EventName : NSDate] = [:]
    var properties : [EventName : Properties] = [:]
    
    public internal(set) var instance : T! = nil
    
    public func activate() {
        
    }
    
    public func event(name: EventName, properties: Properties? = nil) {
        //
        // A Generic Provider has no way to know how to send events.
        //
        assert(false)
    }
    
    public func time(name: EventName, properties: Properties? = nil) {
        events[name] = NSDate()
        
        if let properties = properties {
            self.properties[name] = properties
        }
    }
    
    public func finish(name: EventName, properties: Properties?) {
        
        var properties = properties
        
        if properties == nil {
            properties = [:]
        }
        
        if let time = events[name] {
            properties![Property.Time.rawValue] = time.timeIntervalSinceNow
        }
                
        event(name, properties: properties)
    }
}