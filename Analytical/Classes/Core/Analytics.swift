//
//  Analytics.swift
//  Application
//
//  Created by Dal Rupnik on 18/07/16.
//  Copyright © 2016 Blub Blub. All rights reserved.
//

///
/// Serves as a bounce wrapper for Analytics providers
///
public class Analytics : Analytical {
    public var providers : [Analytical] = []
    
    //
    // MARK: Public Methods
    //
    
    /*!
     If one of your providers requires launch options and application reference, this method must be called,
     or parameteres must manually be provided.
     
     - parameter application:   UIApplication instance
     - parameter launchOptions: launch options
     */
    public func setup(application: UIApplication?, launchOptions: [NSObject : AnyObject]?) {
        var properties : Properties = [:]
        
        if let launchOptions = launchOptions {
            properties = [Property.Launch.Options.rawValue : launchOptions]
        }
            
        setup(properties)
    }
    
    //
    // MARK: Analytical
    //
    
    public func setup(properties: Properties? = nil) {
        providers.forEach { $0.setup(properties) }
    }
    public func activate() {
        providers.forEach { $0.activate() }
    }
    public func flush() {
        providers.forEach { $0.flush() }
    }
    public func reset() {
        providers.forEach { $0.reset() }
    }
    public func event(name: EventName, properties: Properties?) {
        providers.forEach { $0.event(name, properties: properties) }
    }
    public func screen(name: EventName, properties: Properties?) {
        providers.forEach { $0.screen(name, properties: properties) }
    }
    public func time (name: EventName, properties: Properties?) {
        providers.forEach { $0.time(name, properties: properties) }
    }
    public func finish (name: EventName, properties: Properties?) {
        providers.forEach { $0.finish(name, properties: properties) }
    }
    public func identify(userId: String, properties: Properties?) {
        providers.forEach { $0.identify(userId, properties: properties) }
    }
    public func alias(userId: String, forId: String) {
        providers.forEach { $0.alias(userId, forId: forId) }
    }
    public func set(properties: Properties) {
        providers.forEach { $0.set(properties) }
    }
    public func increment(property: String, by number: NSDecimalNumber) {
        providers.forEach { $0.increment(property, by: number) }
    }
    public func purchase(amount: NSDecimalNumber, properties: Properties?) {
        providers.forEach { $0.purchase(amount, properties: properties) }
    }
}

//
// MARK: Convenience API
//

//
// Analytics operator
//

infix operator <<~ { associativity left precedence 160 }

func <<~ (left: Analytics, right: Analytical) -> Analytics {
    left.providers.append(right)
    
    return left
}
