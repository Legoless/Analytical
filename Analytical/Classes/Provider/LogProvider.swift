//
//  DebugProvider.swift
//  Analytical
//
//  Created by Dal Rupnik on 19/07/16.
//  Copyright © 2016 Unified Sense. All rights reserved.
//

import XCGLogger

open class DebugProvider : Provider<XCGLogger>, Analytical {
    open func setup(_ properties: Properties?) {
        instance = XCGLogger(identifier: "com.unifiedsense.analytical.logger", includeDefaultDestinations: true)
        instance.setup(level: .verbose, showLogIdentifier: false, showFunctionName: false, showThreadName: false, showLevel: false, showFileNames: false, showLineNumbers: false)
        
        instance.debug("Setuped provider with properties: \(properties)")
    }
    
    open override func activate() {
        instance.debug("Provider was activated.")
    }
    
    open func flush() {
        instance.debug("Provider data was flushed.")
    }
    
    open func reset() {
        instance.debug("Provider user data was reset.")
    }
    
    open override func event(_ name: EventName, properties: Properties?) {
        instance.debug("Event \(name) was triggered with properties: \(properties)")
    }
    
    open func screen(_ name: EventName, properties: Properties?) {
        instance.debug("Event \(name) was triggered with properties: \(properties)")
    }
    
    open override func time (_ name: EventName, properties: Properties?) {
        super.time(name, properties: properties)
        
        instance.debug("Timed event \(name) was triggered with properties: \(properties)")
    }
    
    open override func finish (_ name: EventName, properties: Properties?) {
        instance.debug("Event \(name) was completed with properties in time \(self.events): \(properties)")
    }
    
    open func identify(_ userId: String, properties: Properties?) {
        instance.debug("User \(userId) was identified with properties: \(properties)")
    }
    
    open func alias(_ userId: String, forId: String) {
        instance.debug("Alias \(userId) was connected to \(userId).")
    }
    
    open func set(_ properties: Properties) {
        instance.debug("Properties \(properties) were set for the user.")
    }
    
    open func increment(_ property: String, by number: NSDecimalNumber) {
        instance.debug("Property \(property) was increased by number: \(number)")
    }
    
    open func purchase(_ amount: NSDecimalNumber, properties: Properties?) {
        instance.debug("Purchase for \(amount) was triggered with properties: \(properties)")
    }
}
