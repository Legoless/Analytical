//
//  AnalyticalProvider
//  Analytical
//
//  Created by Dal Rupnik on 18/07/16.
//  Copyright © 2016 Unified Sense. All rights reserved.
//

import Foundation

/// Set provider delegate to modify certain analytics events on a single point of entry.
public protocol AnalyticalProviderDelegate: Sendable {

    /// This method will be called on the delegate, before the event is sent.
    /// If delegate returns nil, event will be discarded.
    /// - Parameters:
    ///   - provider: provider
    ///   - event: event
    func analyticalProviderShouldSendEvent(_ provider: AnalyticalProvider, event: AnalyticalEvent) -> AnalyticalEvent?
    
    /// Called when provider finishes sending an event.
    /// - Parameters:
    ///   - provider: provider.
    ///   - event: event that was sent.
    func analyticalProviderDidSendEvent(_ provider: AnalyticalProvider, event: AnalyticalEvent)
}

/// Default implementation of delegate, to make both methods optional without Obj-C runtime.
public extension AnalyticalProviderDelegate {
    func analyticalProviderShouldSendEvent(_ provider: AnalyticalProvider, event: AnalyticalEvent) -> AnalyticalEvent? {
        return event
    }
    
    func analyticalProviderDidSendEvent(_ provider: AnalyticalProvider, event: AnalyticalEvent) {
    }
}

/// Analytical provider protocol
public protocol AnalyticalProvider: Sendable {
    //
    // MARK: Delegate
    //
    func getDelegate() async -> AnalyticalProviderDelegate?
    
    func setDelegate(_ delegate: AnalyticalProviderDelegate?) async
    
    //
    // MARK: Common Methods
    //
    
    /// Prepares analytical provider with selected properties and initializes all systems.
    /// - Parameter properties: properties of analytics.
    func setup(with properties: Properties?) async
    
    /// Should be called when app is becomes active.
    func activate() async
    
    /// Should be called when app resigns active.
    func resign() async
    
    /// Manually force the current loaded events to be dispatched.
    func flush() async
    
    /// Resets all user data.
    func reset() async
    
    //
    // MARK: Tracking
    //

    /// Logs a specific event to analytics.
    /// - Parameter event: event
    func event(_ event: AnalyticalEvent) async
    
    //
    // MARK: User Tracking
    //
     
    /// Identify a user with analytics. Do this as soon as user is known.
    /// - Parameters:
    ///   - userId: user id
    ///   - properties: different traits and properties
    func identify(userId: String, properties: Properties?) async
    
    /// Connect the existing anonymous user with the alias (for example, after user signs up),
    /// and he was using the app anonymously before.
    /// This is used to connect the registered user to the dynamically generated ID
    /// it was given before. Identify will be called automatically.
    /// - Parameters:
    ///   - userId: user
    ///   - forId: anonymous id
    func alias(userId: String, forId: String) async
    
    /// Sets properties to currently identified user.
    /// - Parameter properties: properties
    func set(properties: Properties) async
    
    /// Sets global properties to be sent on all events.
    /// - Parameters:
    ///   - properties: properties
    ///   - overwrite: if properties should be overwritten, if previously set.
    func global(properties: Properties, overwrite: Bool) async
    

    /// Increments currently set property by a number.
    /// - Parameters:
    ///   - property: property to increment
    ///   - number: number to increment by
    func increment(property: String, by number: NSDecimalNumber) async
    
    /// Add device token to the provider for push notification support.
    /// - Parameter token: token
    func addDevice(token: Data) async
    
    /// Log push notification to the provider.
    /// - Parameters:
    ///   - payload: push notification payload
    ///   - event: action of the push
    func push(payload: Payload, event: EventName?) async
}

/*!
 *  Convenience extensions
 */
public extension AnalyticalProvider {
    func event(_ defaultEvent: DefaultEvent, properties: Properties? = nil) async {
        await event(name: defaultEvent.rawValue, properties: properties)
    }
    func event(name: EventName, properties: Properties? = nil) async {
        await event(AnalyticalEvent(type: .default, name: name, properties: properties))
    }
    func screen(name: EventName, properties: Properties? = nil) async {
        await event(AnalyticalEvent(type: .screen, name: name, properties: properties))
    }
    func time (name: EventName, properties: Properties? = nil) async {
        await event(AnalyticalEvent(type: .time, name: name, properties: properties))
    }
    func finish (name: EventName, properties: Properties? = nil) async {
        await event(AnalyticalEvent(type: .finishTime, name: name, properties: properties))
    }
}

public extension AnalyticalProvider {
    public func convertToProperties(_ dictionary: [String: Any]?) -> Analytical.Properties? {
        guard let dictionary else {
            return nil
        }
        var result = Analytical.Properties()
        for (key, value) in dictionary {
            result[key] = SendableValue(value)
        }
        return result
    }
}


