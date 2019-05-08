//
//  SmartlookProvider.swift
//  Analytical
//
//  Created by Dal Rupnik on 18/07/16.
//  Copyright © 2018 Unified Sense. All rights reserved.
//

import Analytical
import Smartlook


public class SmartlookProvider : BaseProvider<Smartlook>, AnalyticalProvider {

    
    public static let Key = "SmartlookKey"
    
    //
    // MARK: Analytical
    //
    
    public func setup(with properties: Properties?) {
        guard let key = properties?[SmartlookProvider.Key] as? String else {
            return
        }
        
        Smartlook.start(withKey: key)
    }
    
    public override func activate() {

    }
    
    public func flush() {

    }
    
    public func reset() {
    }
    
    public override func event(_ event: AnalyticalEvent) {
        guard let event = update(event: event) else {
            return
        }
        
        switch event.type {
        case .time:
            super.event(event)
        case .finishTime:
            super.event(event)
            
            Smartlook.recordCustomEvent(withEventName: event.name, propertiesDictionary: prepare(properties: event.properties))
        default:            
            Smartlook.recordCustomEvent(withEventName: event.name, propertiesDictionary: prepare(properties: event.properties))
        }
        
        delegate?.analyticalProviderDidSendEvent(self, event: event)
    }
    
    public func identify(userId: String, properties: Properties?) {
        Smartlook.setUserIdentifier(userId)
        
        if let properties = properties {
            set(properties: properties)
        }
    }
    
    public func increment(property: String, by number: NSDecimalNumber) {
    }
    
    public func alias(userId: String, forId: String) {
    }
    
    public func set(properties: Properties) {
        guard let preparedProperties = prepare(properties: properties) else {
            return
        }
        
        Smartlook.setUserPropertiesDictionary(preparedProperties)
    }
    
    private func prepare(properties: Properties?) -> [String : String]? {
        guard let properties = properties else {
            return nil
        }
        
        var finalProperties : [String : String] = [:]
        
        for (property, value) in properties {
            
            if let value = value as? String {
                finalProperties[property] = value
            }
            else {
                finalProperties[property] = String(describing: value)
            }
            
        }
        
        return finalProperties
    }
}
