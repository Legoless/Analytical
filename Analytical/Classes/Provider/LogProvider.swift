//
//  LogProvider.swift
//  Analytical
//
//  Created by Dal Rupnik on 19/07/16.
//  Copyright © 2016 Unified Sense. All rights reserved.
//

import XCGLogger

open class LogProvider : Provider<XCGLogger>, Analytical {
    open func setup(with properties: Properties?) {
        instance = XCGLogger(identifier: "com.unifiedsense.analytical.logger", includeDefaultDestinations: true)
        instance.setup(level: .verbose, showLogIdentifier: false, showFunctionName: false, showThreadName: false, showLevel: false, showFileNames: false, showLineNumbers: false)
        
        instance.debug("Setup LogProvider with properties: \(String(describing: properties))")
    }
    
    open override func activate() {
        instance.debug("LogProvider was activated.")
    }
    
    open func flush() {
        instance.debug("LogProvider data was flushed.")
    }
    
    open func reset() {
        instance.debug("LogProvider user data was reset.")
    }
    
    open override func event(name: EventName, properties: Properties?) {
        instance.debug("Event \(name) was logged with properties: \(String(describing: properties))")
    }
    
    open func screen(name: EventName, properties: Properties?) {
        instance.debug("Screen \(name) was logged with properties: \(String(describing: properties))")
    }
    
    open override func time (name: EventName, properties: Properties?) {
        super.time(name: name, properties: properties)
        
        instance.debug("Timed event \(name) was started with properties: \(String(describing: properties))")
    }
    
    open override func finish (name: EventName, properties: Properties?) {
        super.finish(name: name, properties: properties)
        
        instance.debug("Event \(name) was completed with properties in time \(self.events): \(String(describing: properties))")
    }
    
    open func identify(userId: String, properties: Properties?) {
        instance.debug("User \(userId) was identified with properties: \(String(describing: properties))")
    }
    
    open func alias(userId: String, forId: String) {
        instance.debug("Alias \(userId) was connected to \(userId).")
    }
    
    open func set(properties: Properties) {
        instance.debug("Properties \(properties) were set for the user.")
    }
    
    open func increment(property: String, by number: NSDecimalNumber) {
        instance.debug("Property \(property) was increased by number: \(number)")
    }
    
    open override func purchase(amount: NSDecimalNumber, properties: Properties?) {
        instance.debug("Purchase for \(amount) was triggered with properties: \(String(describing: properties))")
    }
    
    open override func addDevice(token: Data) {
        let deviceToken = token.map { String(format: "%02.2hhx", $0) }.joined()
        instance.debug("Added device token: \(deviceToken)")
    }
}
