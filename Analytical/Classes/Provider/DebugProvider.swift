//
//  DebugProvider.swift
//  Analytical
//
//  Created by Dal Rupnik on 19/07/16.
//  Copyright © 2016 Unified Sense. All rights reserved.
//

import XCGLogger

public class DebugProvider : Provider<XCGLogger>, Analytical {
    public func setup(properties: Properties?) {
        instance = XCGLogger(identifier: "com.unifiedsense.analytical.logger", includeDefaultDestinations: true)
        instance.setup(.Verbose, showLogIdentifier: false, showFunctionName: false, showThreadName: false, showLogLevel: false, showFileNames: false, showLineNumbers: false)
        
        instance.debug("Setuped provider with properties: \(properties)")
    }
    
    public override func activate() {
        instance.debug("Provider was activated.")
    }
    
    public func flush() {
        instance.debug("Provider data was flushed.")
    }
    
    public func reset() {
        instance.debug("Provider user data was reset.")
    }
    
    public override func event(name: EventName, properties: Properties?) {
        instance.debug("Event \(name) was triggered with properties: \(properties)")
    }
    
    public func screen(name: EventName, properties: Properties?) {
        instance.debug("Event \(name) was triggered with properties: \(properties)")
    }
    
    public override func time (name: EventName, properties: Properties?) {
        super.time(name, properties: properties)
        
        instance.debug("Timed event \(name) was triggered with properties: \(properties)")
    }
    
    public override func finish (name: EventName, properties: Properties?) {
        instance.debug("Event \(name) was completed with properties in time \(events): \(properties)")
    }
    
    public func identify(userId: String, properties: Properties?) {
        instance.debug("User \(userId) was identified with properties: \(properties)")
    }
    
    public func alias(userId: String, forId: String) {
        instance.debug("Alias \(userId) was connected to \(userId).")
    }
    
    public func set(properties: Properties) {
        instance.debug("Properties \(properties) were set for the user.")
    }
    
    public func increment(property: String, by number: NSDecimalNumber) {
        instance.debug("Property \(property) was increased by number: \(number)")
    }
    
    public func purchase(amount: NSDecimalNumber, properties: Properties?) {
        instance.debug("Purchase for \(amount) was triggered with properties: \(properties)")
    }
}