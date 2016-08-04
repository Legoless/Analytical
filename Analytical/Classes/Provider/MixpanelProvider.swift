//
//  Mixpanel.swift
//  Analytical
//
//  Created by Dal Rupnik on 18/07/16.
//  Copyright © 2016 Unified Sense. All rights reserved.
//

import Mixpanel

public class MixpanelProvider : Provider<MixpanelInstance>, Analytical {
    private var token : String
    
    public static let ApiToken = "ApiToken"
    
    public init(token: String) {
        self.token = token
        
        super.init()
    }
    
    //
    // MARK: Analytical
    //
    
    public func setup(properties: Properties?) {
        
        if let token = properties?[MixpanelProvider.ApiToken] as? String {
            self.token = token
        }
        
        instance = Mixpanel.initialize(token: token)
    }
    
    public func flush() {
        instance.flush()
    }
    
    public func reset() {
        instance.reset()
    }
    
    public override func event(name: EventName, properties: Properties? = nil) {
        instance.track(event: name, properties: properties)
    }
    
    public func screen(name: EventName, properties: Properties? = nil) {
        //
        // Mixpanel does not specifically track screens, so just send out an event.
        //
        instance.track(event: name, properties: properties)
    }
    
    public override func time(name: EventName, properties: Properties? = nil) {
        super.time(name, properties: properties)
        
        instance.time(event: name)
    }
    
    public func identify(userId: String, properties: Properties? = nil) {
        
        instance.identify(distinctId: userId)
        
        if let properties = properties {
            instance.registerSuperProperties(properties)
        }
    }
    
    public func alias(userId: String, forId: String) {
        instance.createAlias(userId, distinctId: forId)
        instance.identify(distinctId: forId)
    }
    
    public func set(properties: Properties) {
        instance.people.set(properties: properties)
    }
    
    public func increment(property: String, by number: NSDecimalNumber) {
        instance.people.increment(property: property, by: number.doubleValue)
    }
    
    public func purchase(amount: NSDecimalNumber, properties: Properties?) {
        instance.people.trackCharge(amount: amount.doubleValue, properties: properties)
    }
}