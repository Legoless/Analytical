//
//  Mixpanel.swift
//  Application
//
//  Created by Dal Rupnik on 18/07/16.
//  Copyright © 2016 Blub Blub. All rights reserved.
//

import Mixpanel

public class MixpanelProvider : Provider<Mixpanel>, Analytical {
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
        
        instance = Mixpanel.sharedInstanceWithToken(token)
    }
    
    public func flush() {
        instance.flush()
    }
    
    public func reset() {
        instance.reset()
    }
    
    public override func event(name: EventName, properties: Properties? = nil) {
        instance.track(name, properties: properties)
    }
    
    public func screen(name: EventName, properties: Properties? = nil) {
        //
        // Mixpanel does not specifically track screens, so just send out an event.
        //
        instance.track(name, properties: properties)
    }
    
    public override func time(name: EventName, properties: Properties? = nil) {
        super.time(name, properties: properties)
        
        instance.timeEvent(name)
    }
    
    public func identify(userId: String, properties: Properties? = nil) {
        
        instance.identify(userId)
        
        if let properties = properties {
            instance.registerSuperProperties(properties)
        }
    }
    
    public func alias(userId: String, forId: String) {
        instance.createAlias(userId, forDistinctID: forId)
        instance.identify(forId)
    }
    
    public func set(properties: Properties) {
        instance.people.set(properties)
    }
    
    public func increment(property: String, by number: NSDecimalNumber) {
        instance.people.increment(property, by: number)
    }
    
    public func purchase(amount: NSDecimalNumber, properties: Properties?) {
        instance.people.trackCharge(amount, withProperties: properties)
    }
}