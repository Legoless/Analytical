//
//  Analytics.swift
//  Analytical
//
//  Created by Dal Rupnik on 18/07/16.
//  Copyright © 2017 Unified Sense. All rights reserved.
//

import ObjectiveC
import Foundation
#if canImport(UIKit)
import UIKit
#endif

public enum IdentifierType {
    case idfa
    case idfv
    case random
}

/// Serves as a bounce wrapper for Analytics providers
open class Analytics: AnalyticalProvider, @unchecked Sendable {
    private static let DeviceKey = "AnalyticsDeviceKey"
    
    private var userDefaults = UserDefaults.standard
    
    public weak var delegate: AnalyticalProviderDelegate?
    
    public private(set) var providers = [AnalyticalProvider]()
    
    public var deviceId: String {
        if let advertisingIdentifier = identityProvider?(.idfa)?.uuidString {
            return advertisingIdentifier
        }
        
        if let id = userDefaults.string(forKey: Analytics.DeviceKey) {
            return id
        }
        
        if let id = identityProvider?(.idfv)?.uuidString {
            userDefaults.set(id, forKey: Analytics.DeviceKey)
            
            return id
        }
        
        let id = identityProvider?(.random)?.uuidString ?? Analytics.randomId()
        
        userDefaults.set(id, forKey: Analytics.DeviceKey)
        
        return id
    }
    
    /// Set a block to be called when IDFA/IDFV identifier is needed.
    public var identityProvider: ((IdentifierType) -> UUID?)?
    
    public init(identityProvider: ((IdentifierType) -> UUID?)?) {
        self.identityProvider = identityProvider
    }
    
    // MARK: - Public Methods
    
    #if os(iOS) || os(tvOS)
    /// If one of your providers requires launch options and application reference, this method must be called, or parameters must manually be provided.
    /// - Parameters:
    ///   - application: UIApplication instance
    ///   - launchOptions: launch options
    open func setup(with application: UIApplication?, launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        var properties : Properties = [:]
        
        if let application = application {
            properties[Property.Launch.application.rawValue] = application
        }
        
        if let launchOptions = launchOptions {
            properties[Property.Launch.options.rawValue] = launchOptions
        }
        
        setup(with: properties)
    }
    #endif
    
    public func provider<T: AnalyticalProvider>(ofType type: T.Type) -> T? {
        return providers.filter { return ($0 is T) }.first as? T
    }
    
    public func addProvider(provider: AnalyticalProvider) {
        providers.append(provider)
    }
    
    // MARK: - Analytical
    
    public func setup(with properties: Properties? = nil) {
        providers.forEach { $0.setup(with: properties) }
    }
    public func activate() {
        providers.forEach { $0.activate() }
    }
    public func resign() {
        providers.forEach { $0.resign() }
    }    
    public func flush() {
        providers.forEach { $0.flush() }
    }
    public func reset() {
        providers.forEach { $0.reset() }
    }
    public func event(_ event: AnalyticalEvent) {
        var event = event
        
        // Ask delegate for event. If delegate returns nil, skip the event delivery.
        if let delegate = delegate, let updatedEvent = delegate.analyticalProviderShouldSendEvent(self, event: event) {
            event = updatedEvent
        } else if delegate != nil {
            return
        }
        
        providers.forEach { $0.event(event) }
        
        delegate?.analyticalProviderDidSendEvent(self, event: event)
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
    public func global(properties: Properties, overwrite: Bool) {
        providers.forEach { $0.global(properties: properties, overwrite: overwrite) }
    }
    public func increment(property: String, by number: NSDecimalNumber) {
        providers.forEach { $0.increment(property: property, by: number) }
    }
    public func addDevice(token: Data) {
        providers.forEach { $0.addDevice(token: token) }
    }
    public func push(payload: [AnyHashable: Any], event: EventName?) {
        providers.forEach { $0.push(payload: payload, event: event) }
    }
    
    // MARK: - Private Methods
    
    private static func randomId(_ length: Int = 64) -> String {
        let charactersString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let charactersArray: [Character] = Array(charactersString)
        
        let count = UInt32(charactersString.count)
        
        var string = ""
        
        for _ in 0..<length {
            let rand = Int(arc4random_uniform(count))
            
            string.append(charactersArray[rand])
        }
        
        return string
    }
}

// MARK: - Analytics operator

precedencegroup AnalyticalPrecedence {
    associativity: left
    higherThan: LogicalConjunctionPrecedence
}


infix operator <<~: AnalyticalPrecedence

public func <<~ (left: Analytics, right: AnalyticalProvider) -> Analytics {
    left.addProvider(provider: right)
    
    return left
}
