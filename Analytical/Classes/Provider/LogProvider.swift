//
//  LogProvider.swift
//  Analytical
//
//  Created by Dal Rupnik on 19/07/16.
//  Copyright © 2016 Unified Sense. All rights reserved.
//

import Foundation
import os.log

extension OSLog {
    func debug (_ message: StaticString, _ args: CVarArg...) {
        os_log(message, log: self, type: .debug, args)
    }
}

open class LogProvider : BaseProvider<OSLog>, AnalyticalProvider {
    open func setup(with properties: Properties?) {
        
        instance = OSLog(subsystem: "com.unifiedsense.analytical.logger", category: "Analytics")
        
        /*
        instance = XCGLogger(identifier: "com.unifiedsense.analytical.logger", includeDefaultDestinations: true)
        instance.setup(level: .verbose, showLogIdentifier: false, showFunctionName: false, showThreadName: false, showLevel: false, showFileNames: false, showLineNumbers: false)
        
        instance.debug("Setup LogProvider with properties: \(String(describing: properties))")*/
        
        instance.debug("Setup LogProvider with properties: %@", String(describing: properties))
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
    
    open override func event(_ event: AnalyticalEvent) {
        guard let event = update(event: event) else {
            return
        }
        
        switch event.type {
        case .screen:
            instance.debug("Screen %@ was logged with properties: %@", name, String(describing: properties))
        case .time:
            super.event(event)
            
            instance.debug("Timed event %@ was started with properties: %@", name, String(describing: properties))
        case .purchase:
            instance.debug("Purchase for %@ was triggered with properties: %@", amount, String(describing: properties))
        case .finishTime:
            super.event(event)
            
            instance.debug("Event %@ was completed with properties in time %@: %@", name, self.events, String(describing: properties))
        default:
            instance.debug("Event %@ was logged with properties: %@", name, String(describing: properties))
        }
        
        delegate?.analyticalProviderDidSendEvent(self, event: event)
    }
    
    open func identify(userId: String, properties: Properties?) {
        instance.debug("User %@ was identified with properties: %@", userId, String(describing: properties))
    }
    
    open func alias(userId: String, forId: String) {
        instance.debug("Alias %@ was connected to %@.", forId, userId)
    }
    
    open func set(properties: Properties) {
        instance.debug("Properties %@ were set for the user.", String(describing: properties))
    }
    
    open override func global(properties: Properties, overwrite: Bool) {
        instance.debug("Global properties %@ were set with overwrite: %d.", String(describing: properties), overwrite as CVarArg)
    }
    
    open func increment(property: String, by number: NSDecimalNumber) {
        instance.debug("Property %@ was increased by number: %@", property, number)
    }
    
    open override func addDevice(token: Data) {
        let deviceToken = token.map { String(format: "%02.2hhx", $0) }.joined()
        instance.debug("Added device token: %@", deviceToken)
    }
}
