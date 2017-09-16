//
//  AnalyticalProvider
//  Analytical
//
//  Created by Dal Rupnik on 18/07/16.
//  Copyright © 2016 Unified Sense. All rights reserved.
//

import Foundation

/*!
 *  Set provider delegate to modify certain analyics events on a single point of entry.
 */
public protocol AnalyticalProviderDelegate : class {
    /*!
     *  This method will be called on the delegate, before the event is sent. If delegate returns nil, event will be discarded.
     */
    func analyticalProviderWillSendEvent(_ provider: AnalyticalProvider, event: AnalyticalEvent) -> AnalyticalEvent?
}

/*!
 *  Analytical provider protocol, that implements any
 */
public protocol AnalyticalProvider {
    //
    // MARK: Delegate
    //
    weak var delegate : AnalyticalProviderDelegate? { get set }
    
    //
    // MARK: Common Methods
    //
    
    /*!
     Prepares analytical provider with selected properities and initializes all systems.
     
     - parameter properties: properties of analytics.
     */
    func setup(with properties: Properties?)
    
    /*!
     Should be called when app is becomes active.
     */
    func activate()
    
    /*!
     Should be called when app resigns active.
     */
    func resign()
    
    /*!
     Manually force the current loaded events to be dispatched.
     */
    func flush()
    
    /*!
     Resets all user data.
     */
    func reset()
    
    //
    // MARK: Tracking
    //
    
    /*!
     Logs a specific event to analytics.
     
     - parameter event: event struct
     */
    func event(_ event: AnalyticalEvent)
    
    //
    // MARK: User Tracking
    //
    
    /*!
     Identify an user with analytics. Do this as soon as user is known.
     
     - parameter userId:      user id
     - parameter properties:  different traits and properties
     */
    func identify(userId: String, properties: Properties?)
    
    /*!
     Connect the existing anonymous user with the alias (for example, after user signs up),
     and he was using the app anonymously before. This is used to connect the registered user
     to the dynamically generated ID it was given before. Identify will be called automatically.
     
     - parameter userId: user
     */
    func alias(userId: String, forId: String)
    
    /*!
     Sets properties to currently identified user.
     
     - parameter properties: properties
     */
    func set(properties: Properties)
    
    /*!
     Sets global properties to be sent on all events.
 
     - parameter properties: properties
     - paramater overwrite:  if properties should be overwritten, if previously set.
     */
    func global(properties: Properties, overwrite: Bool)
    
    /*!
     Increments currently set property by a number.
     
     - parameter property: property to increment
     - parameter number:   number to incrememt by
     */
    func increment(property: String, by number: NSDecimalNumber)
    
    /*!
     Make a purchase for the current user.
     
     - parameter amount:     amount
     - parameter properties: properties, such as SKU, Product ID, Tax, etc.
     */
    func purchase(amount: NSDecimalNumber, properties: Properties?)
    
    /*!
     Add device token to the provider for push notification support.
 
     - parameter token: token
     */
    func addDevice(token: Data)
    
    /*!
     Log push notification to the provider.
 
     - parameter payload:   push notification payload
     - parameter event:     action of the push
     */
    func push(payload: [AnyHashable : Any], event: EventName?)
}
