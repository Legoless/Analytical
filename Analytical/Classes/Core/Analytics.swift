//
//  Analytics.swift
//  Analytical
//
//  Created by Dal Rupnik on 18/07/16.
//  Copyright © 2017 Unified Sense. All rights reserved.
//

import ObjectiveC
import UIKit

///
/// Serves as a bounce wrapper for Analytics providers
///
public class Analytics : Analytical {
    private static let DeviceKey = "AnalyticsDeviceKey"
    
    private var userDefaults = UserDefaults.standard
    
    public private(set) var providers : [Analytical] = []
    
    public var deviceId : String {
        if let advertisingIdentifier = advertisingIdentifier?.uuidString {
            return advertisingIdentifier
        }
        
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
    public func setup(with application: UIApplication?, launchOptions: [UIApplicationLaunchOptionsKey: Any]?) {
        var properties : Properties = [:]
        
        if let application = application {
            properties[Property.Launch.application.rawValue] = application
        }
        
        if let launchOptions = launchOptions {
            properties[Property.Launch.options.rawValue] = launchOptions
        }
        
        setup(with: properties)
    }
    
    public func provider<T : Analytical>(_ type: T.Type) -> T? {
        return providers.filter { return ($0 is T) }.first as? T
    }
    
    public func addProvider(provider: Analytical) {
        providers.append(provider)
    }
    
    //
    // MARK: Analytical
    //
    
    public func setup(with properties: Properties? = nil) {
        providers.forEach { $0.setup(with: properties) }
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
    public func event(name: EventName, properties: Properties? = nil) {
        providers.forEach { $0.event(name: name, properties: properties) }
    }
    public func screen(name: EventName, properties: Properties? = nil) {
        providers.forEach { $0.screen(name: name, properties: properties) }
    }
    public func time (name: EventName, properties: Properties? = nil) {
        providers.forEach { $0.time(name: name, properties: properties) }
    }
    public func finish (name: EventName, properties: Properties? = nil) {
        providers.forEach { $0.finish(name: name, properties: properties) }
    }
    public func identify(userId: String, properties: Properties? = nil) {
        providers.forEach { $0.identify(userId: userId, properties: properties) }
    }
    public func alias(userId: String, forId: String) {
        providers.forEach { $0.alias(userId: userId, forId: forId) }
    }
    public func set(properties: Properties) {
        providers.forEach { $0.set(properties: properties) }
    }
    public func increment(property: String, by number: NSDecimalNumber) {
        providers.forEach { $0.increment(property: property, by: number) }
    }
    public func purchase(amount: NSDecimalNumber, properties: Properties?) {
        providers.forEach { $0.purchase(amount: amount, properties: properties) }
    }
    public func addDevice(token: Data) {
        providers.forEach { $0.addDevice(token: token) }
    }
    public func push(payload: [AnyHashable : Any], event: EventName?) {
        providers.forEach { $0.push(payload: payload, event: event) }
    }
    
    //
    // MARK: Private Methods
    //
    
    /*!
     *  Returns advertising identifier if iAd.framework is linked. 
     *
     *  @note It uses Objective-C Runtime inspection, to detect,
     *  so no direct dependency to iAd is created in Swift.
     */
    private var advertisingIdentifier : UUID? {
        guard let managerClass = NSClassFromString("ASIdentifierManager") as? NSObjectProtocol else {
            return nil
        }
        
        //
        // To ensure the dynamic code works correctly and it is future proof, we check for each call that can crash it.
        //
        
        let sharedSelector = NSSelectorFromString("sharedManager")
        
        if !managerClass.responds(to: sharedSelector) {
            return nil
        }
        
        guard let shared = managerClass.perform(sharedSelector) as? NSObjectProtocol else {
            return nil
        }
        
        guard let managerPointer = shared as? Swift.Unmanaged<AnyObject> else {
            return nil
        }
        
        guard let manager = managerPointer.takeUnretainedValue() as? NSObject else {
            return nil
        }
        
        //
        // Check if advertising is enabled to respect Apple's policy
        //
        
        let enabledSelector = NSSelectorFromString("isAdvertisingTrackingEnabled")
        
        if !manager.responds(to: enabledSelector) {
            return nil
        }
        
        guard let _ = manager.perform(enabledSelector) else {
            return nil
        }
                
        //
        // Return advertising selector
        //
        
        let advertisingSelector = NSSelectorFromString("advertisingIdentifier")
        
        if !manager.responds(to: advertisingSelector) {
            return nil
        }
        
        guard let identifier = manager.perform(advertisingSelector) else {
            return nil
        }
        
        return identifier.takeUnretainedValue() as? UUID
    }
    
    private static func randomId(_ length: Int = 64) -> String {
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
    left.addProvider(provider: right)
    
    return left
}
