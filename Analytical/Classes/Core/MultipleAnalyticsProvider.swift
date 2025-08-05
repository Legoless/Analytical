//
//  MultipleAnalyticsProvider.swift
//  MultipleAnalyticsProvider
//
//  Created by Dal Rupnik on 18/07/16.
//  Copyright © 2017 Unified Sense. All rights reserved.
//

import ObjectiveC
import Foundation
#if canImport(UIKit)
import UIKit
#endif

/// Serves as a bounce wrapper for Analytics providers
public actor MultipleAnalyticsProvider: AnalyticalProvider {
    private var delegate: AnalyticalProviderDelegate?

    public func getDelegate() async -> AnalyticalProviderDelegate? {
        delegate
    }

    public func setDelegate(_ delegate: AnalyticalProviderDelegate?) async {
        self.delegate = delegate
    }
    
    public private(set) var providers = [AnalyticalProvider]()
    
    public init() { }
    
    // MARK: - Public Methods
    
    #if os(iOS) || os(tvOS)
    /// If one of your providers requires launch options and application reference, this method must be called, or parameters must manually be provided.
    /// - Parameters:
    ///   - application: UIApplication instance
    ///   - launchOptions: launch options
    public func setup(with application: UIApplication?, launchOptions: [UIApplication.LaunchOptionsKey: Any]?) async {
        var properties : Properties = [:]
        
        if let application = application {
            properties[Property.Launch.application.rawValue] = SendableValue(application)
        }
        
        if let launchOptions = launchOptions {
            properties[Property.Launch.options.rawValue] = SendableValue(launchOptions)
        }
        
        await setup(with: properties)
    }
    #endif
    
    public func provider<T: AnalyticalProvider>(ofType type: T.Type) -> T? {
        return providers.filter { return ($0 is T) }.first as? T
    }
    
    public func addProvider(provider: AnalyticalProvider) {
        providers.append(provider)
    }
    
    // MARK: - Analytical
    public func setup(with properties: Properties? = nil) async {
        for provider in  await providers {
                await provider.setup(with: properties)
            }
    }
    
    public func activate() async {
        for provider in providers {
            await provider.activate()
        }
    }

    public func resign() async {
        for provider in providers {
            await provider.resign()
        }
    }

    public func flush() async {
        for provider in providers {
            await provider.flush()
        }
    }

    public func reset() async {
        for provider in providers {
            await provider.reset()
        }
    }
    public func event(_ event: AnalyticalEvent) async {
        var event = event
        
        // Ask delegate for event. If delegate returns nil, skip the event delivery.
        if let delegate = delegate, let updatedEvent = delegate.analyticalProviderShouldSendEvent(self, event: event) {
            event = updatedEvent
        } else if delegate != nil {
            return
        }
        
        for provider in providers {
            await provider.event(event)
        }
                
        delegate?.analyticalProviderDidSendEvent(self, event: event)
    }
    
    public func identify(userId: String, properties: Properties? = nil) async {
        for provider in providers {
            await provider.identify(userId: userId, properties: properties)
        }
    }

    public func alias(userId: String, forId: String) async {
        for provider in providers {
            await provider.alias(userId: userId, forId: forId)
        }
    }

    public func set(properties: Properties) async {
        for provider in providers {
            await provider.set(properties: properties)
        }
    }

    public func global(properties: Properties, overwrite: Bool) async {
        for provider in providers {
            await provider.global(properties: properties, overwrite: overwrite)
        }
    }

    public func increment(property: String, by number: NSDecimalNumber) async {
        for provider in providers {
            await provider.increment(property: property, by: number)
        }
    }

    public func addDevice(token: Data) async {
        for provider in providers {
            await provider.addDevice(token: token)
        }
    }

    public func push(payload: Payload, event: EventName?) async {
        for provider in providers {
            await provider.push(payload: payload, event: event)
        }
    }
    
    
    static func randomId(_ length: Int = 64) -> String {
        let characters = Array("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")
        
        let result = (0..<length).compactMap { _ in characters.randomElement() }
        
        return String(result)
    }
}
