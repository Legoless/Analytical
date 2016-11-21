//
//  Analytical
//  Analytical
//
//  Created by Dal Rupnik on 18/07/16.
//  Copyright © 2016 Unified Sense. All rights reserved.
//

import Foundation

public typealias Properties = [String : Any]
public typealias EventName = String

public enum Property : String {
    case category       = "category"
    case time           = "time"
    
    public enum Launch : String {
        case application    = "application"
        case options        = "launchOptions"
    }
    
    public enum Purchase : String {
        case affiliation    = "affiliation"
        case country        = "country"
        case currency       = "currency"
        case item           = "item"
        case price          = "price"
        case sku            = "sku"
        case shipping       = "shipping"
        case quantity       = "quantity"
        case tax            = "tax"
        case transactionId  = "transactionId"
    }
    
    public enum User : String {
        case age        = "age"
        case gender     = "gender"
    }
}

/*!
 Some providers may not support logging certain events separately. Analytical still logs those events,
 using Analytical methods, but default event names are used instead and are tracked as normal events.
 
 - Purchase:   Log a purchase
 - ScreenView: Log a screen view
 */
public enum DefaultEvent : String {
    case purchase       = "AnalyticalEventPurchase"
    case screenView     = "AnalyticalEventScreenView"
}

public protocol Analytical {
    //
    // MARK: Common Methods
    //
    
    /*!
     Prepares analytical provider with selected properities and initializes all systems.
     
     - parameter properties: properties of analytics.
     */
    func setup(with properties: Properties?)
    
    /*!
     Called when app is activated.
     */
    func activate()
    
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
     
     - parameter name:       name of the event
     - parameter properties: additional properties
     */
    func event(name: EventName, properties: Properties?)
    
    /*!
     Logs a specific screen to analytics.
     
     - parameter name:       name of the screen
     - parameter properties: additional properties
     */
    func screen(name: EventName, properties: Properties?)
    
    /*!
     Track time for event name
     
     - parameter name:       name of the event
     - parameter properties: properties
     */
    func time (name: EventName, properties: Properties?)
    
    /*!
     Finish tracking time for event
     
     - parameter name:       event
     - parameter properties: properties
     */
    func finish (name: EventName, properties: Properties?)
    
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
}
