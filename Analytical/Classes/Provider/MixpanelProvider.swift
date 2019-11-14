//
//  Mixpanel.swift
//  Analytical
//
//  Created by Dal Rupnik on 18/07/16.
//  Copyright © 2016 Unified Sense. All rights reserved.
//

import Mixpanel

public class MixpanelProvider : BaseProvider<MixpanelInstance>, AnalyticalProvider {
    private var token : String
    
    public static let ApiToken = "ApiToken"
    
    public init(token: String) {
        self.token = token
        
        super.init()
    }
    
    //
    // MARK: Analytical
    //
    
    public func setup(with properties: Properties?) {
        
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
    
    public override func event(_ event: AnalyticalEvent) {
        guard let event = update(event: event) else {
            return
        }
        
        switch event.type {
        case .default, .screen, .finishTime:
            instance.track(event: event.name, properties: event.properties as? [String : MixpanelType])
        case .time:
            super.event(event)
            
            instance.time(event: event.name)
        case .purchase:
            guard let amount = event.properties?[Property.Purchase.price.rawValue] as? NSDecimalNumber else {
                return
            }
            
            instance.people.trackCharge(amount: amount.doubleValue, properties: event.properties as? [String : MixpanelType])
        }
        
        delegate?.analyticalProviderDidSendEvent(self, event: event)
    }
    
    public func identify(userId: String, properties: Properties? = nil) {
        
        instance.identify(distinctId: userId)
        
        if let properties = properties {
            set(properties: properties)
        }
    }
    
    public func alias(userId: String, forId: String) {
        instance.createAlias(userId, distinctId: forId)
    }
        
    public func set(properties: Properties) {
        guard let properties = prepare(properties: properties) else {
            return
        }
        
        instance.people.set(properties: properties)
    }
    
    public override func global(properties: Properties, overwrite: Bool) {
        //
        // Mixpanel has it's own global property system, so just use it.
        //
        
        guard let properties = properties as? [String : MixpanelType] else {
            return
        }
        
        if overwrite {
            instance.registerSuperProperties(properties)
        }
        else {
            instance.registerSuperPropertiesOnce(properties)
        }
    }
    
    public func increment(property: String, by number: NSDecimalNumber) {
        instance.people.increment(property: property, by: number.doubleValue)
    }
    
    
    public override func addDevice(token: Data) {
        instance.people.addPushDeviceToken(token)
    }
    
    public override func push(payload: [AnyHashable : Any], event: EventName?) {
        /*
         Mixpanel tracks pushes automatically in latest versions.

        if let event = event {
            instance.trackPushNotification(payload, event: event)
        }
        else {
            instance.trackPushNotification(payload)
        }*/
    }
    
    //
    // MARK: Private Methods
    //
    
    private func prepare(properties: Properties) -> [String : MixpanelType]? {
        guard let properties = properties as? [String : MixpanelType] else {
            return nil
        }
        
        let mapping : [String : String] = [
            Property.User.email.rawValue : "$email",
            Property.User.name.rawValue : "$name",
            Property.User.lastLogin.rawValue : "$last_login",
            Property.User.created.rawValue : "$created",
            Property.User.firstName.rawValue : "$first_name",
            Property.User.lastName.rawValue : "$last_name"
        ]
        
        var finalProperties : [String : MixpanelType] = [:]
        
        for (property, value) in properties {
            if let map = mapping[property] {
                finalProperties[map] = value
            }
            else {
                finalProperties[property] = value
            }
        }
        
        return finalProperties
    }
}
