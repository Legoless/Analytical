//
//  Mixpanel.swift
//  Analytical
//
//  Created by Dal Rupnik on 18/07/16.
//  Copyright © 2016 Unified Sense. All rights reserved.
//

import Mixpanel

public class MixpanelProvider : Provider<MixpanelInstance>, Analytical {
    fileprivate var token : String
    
    public static let ApiToken = "ApiToken"
    
    public init(token: String) {
        self.token = token
        
        super.init()
    }
    
    //
    // MARK: Analytical
    //
    
    public func setup(_ properties: Properties?) {
        
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
    
    public override func event(_ name: EventName, properties: Properties? = nil) {
        instance.track(event: name, properties: properties as? [String : MixpanelType])
    }
    
    public func screen(_ name: EventName, properties: Properties? = nil) {
        //
        // Mixpanel does not specifically track screens, so just send out an event.
        //
        instance.track(event: name, properties: properties as? [String : MixpanelType])
    }
    
    public override func time(_ name: EventName, properties: Properties? = nil) {
        super.time(name, properties: properties)
        
        instance.time(event: name)
    }
    
    public func identify(_ userId: String, properties: Properties? = nil) {
        
        instance.identify(distinctId: userId)
        
        if let properties = properties as? [String : MixpanelType] {
            instance.registerSuperProperties(properties)
        }
    }
    
    public func alias(_ userId: String, forId: String) {
        instance.createAlias(userId, distinctId: forId)
        instance.identify(distinctId: forId)
    }
    
    public func set(_ properties: Properties) {
        guard let properties = properties as? [String : MixpanelType] else {
            return
        }
        
        instance.people.set(properties: properties)
    }
    
    public func increment(_ property: String, by number: NSDecimalNumber) {
        instance.people.increment(property: property, by: number.doubleValue)
    }
    
    public func purchase(_ amount: NSDecimalNumber, properties: Properties?) {
        instance.people.trackCharge(amount: amount.doubleValue, properties: properties as? [String : MixpanelType])
    }
}
