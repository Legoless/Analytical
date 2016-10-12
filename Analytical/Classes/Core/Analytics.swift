//
//  Analytics.swift
//  Analytical
//
//  Created by Dal Rupnik on 18/07/16.
//  Copyright © 2016 Unified Sense. All rights reserved.
//

import UIKit

///
/// Serves as a bounce wrapper for Analytics providers
///
open class Analytics : Analytical {
    fileprivate static let DeviceKey = "AnalyticsDeviceKey"
    
    fileprivate var userDefaults = UserDefaults.standard
    
    open var providers : [Analytical] = []
    
    open var deviceId : String {
        if let id = userDefaults.string(forKey: Analytics.DeviceKey) {
            return id
        }
        
        if let id = UIDevice.current.identifierForVendor?.uuidString {
            userDefaults.set(id, forKey: Analytics.DeviceKey)
            
            return id
        }
        
        let id = Analytics.randomId()
        
        userDefaults.set(id, forKey: Analytics.DeviceKey)
        
        return id
    }
    
    public init () {
    }
    
    //
    // MARK: Public Methods
    //
    
    /*!
     If one of your providers requires launch options and application reference, this method must be called,
     or parameteres must manually be provided.
     
     - parameter application:   UIApplication instance
     - parameter launchOptions: launch options
     */
    open func setup(_ application: UIApplication?, launchOptions: [UIApplicationLaunchOptionsKey: Any]?) {
        var properties : Properties = [:]
        
        if let application = application {
            properties[Property.Launch.application.rawValue] = application
        }
        
        if let launchOptions = launchOptions {
            properties[Property.Launch.options.rawValue] = launchOptions
        }
        
        setup(with: properties)
    }
    
    open func provider<T : Analytical>(_ type: T.Type) -> T? {
        return providers.filter { return ($0 is T) }.first as? T
    }
    
    //
    // MARK: Analytical
    //
    
    open func setup(with properties: Properties? = nil) {
        providers.forEach { $0.setup(with: properties) }
    }
    open func activate() {
        providers.forEach { $0.activate() }
    }
    open func flush() {
        providers.forEach { $0.flush() }
    }
    open func reset() {
        providers.forEach { $0.reset() }
    }
    open func event(_ name: EventName, properties: Properties? = nil) {
        providers.forEach { $0.event(name, properties: properties) }
    }
    open func screen(_ name: EventName, properties: Properties? = nil) {
        providers.forEach { $0.screen(name, properties: properties) }
    }
    open func time (_ name: EventName, properties: Properties? = nil) {
        providers.forEach { $0.time(name, properties: properties) }
    }
    open func finish (_ name: EventName, properties: Properties? = nil) {
        providers.forEach { $0.finish(name, properties: properties) }
    }
    open func identify(_ userId: String, properties: Properties? = nil) {
        providers.forEach { $0.identify(userId, properties: properties) }
    }
    open func alias(_ userId: String, forId: String) {
        providers.forEach { $0.alias(userId, forId: forId) }
    }
    open func set(_ properties: Properties) {
        providers.forEach { $0.set(properties) }
    }
    open func increment(_ property: String, by number: NSDecimalNumber) {
        providers.forEach { $0.increment(property, by: number) }
    }
    open func purchase(_ amount: NSDecimalNumber, properties: Properties?) {
        providers.forEach { $0.purchase(amount, properties: properties) }
    }
    
    //
    // MARK: Private Methods
    //
    
    fileprivate static func randomId(_ length: Int = 64) -> String {
        let charactersString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let charactersArray : [Character] = Array(charactersString.characters)
        
        let count = UInt32(charactersArray.count)
        
        var string = ""
        
        for _ in 0..<length {
            let rand = Int(arc4random_uniform(count))
            
            string.append(charactersArray[rand])
        }
        
        return string
    }
}

//
// MARK: Convenience API
//

//
// Analytics operator
//

precedencegroup AnalyticalPrecedence {
    associativity: left
    higherThan: LogicalConjunctionPrecedence
}


infix operator <<~: AnalyticalPrecedence

public func <<~ (left: Analytics, right: Analytical) -> Analytics {
    left.providers.append(right)
    
    return left
}
