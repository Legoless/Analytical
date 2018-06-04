//
//  AdjustProvider.swift
//  Analytical
//
//  Created by Dal Rupnik on 6/1/18.
//  Copyright © 2018 Unified Sense. All rights reserved.
//

import Adjust
import Analytical
import Foundation

public protocol AdjustProviderDelegate : AnalyticalProviderDelegate {
    func adjustEvent(for analyticalEvent: AnalyticalEvent) -> ADJEvent?
}

public extension AdjustProviderDelegate {
    func adjustEvent(for analyticalEvent: AnalyticalEvent) -> ADJEvent? {
        let event = ADJEvent(eventToken: analyticalEvent.name)
        
        if analyticalEvent.type == .purchase {
            if let price = (analyticalEvent.properties?[Property.Purchase.price.rawValue] as? NSDecimalNumber)?.doubleValue, let currency = analyticalEvent.properties?[Property.Purchase.currency.rawValue] as? String {
            
                event?.setRevenue(price, currency: currency)
            }
        }
        
        if let transactionId = analyticalEvent.properties?[Property.Purchase.transactionId.rawValue] as? String {
            event?.setTransactionId(transactionId)
        }
        
        return event
    }
}

open class AdjustProvider : BaseProvider<Adjust>, AnalyticalProvider {
    
    public enum EnvironmentType {
        case sandbox
        case production
        
        fileprivate var original : String {
            switch self {
            case .sandbox:
                return ADJEnvironmentSandbox
            case .production:
                return ADJEnvironmentProduction
            }
        }
    }
    
    public static let Environment = "AdjustEnvironment"
    public static let Token = "AdjustKey"
    
    open func setup(with properties: Properties?) {
        guard let token = properties?[AdjustProvider.Token] as? String, let environment = properties?[AdjustProvider.Environment] as? EnvironmentType else {
            return
        }
        
        let config = ADJConfig(appToken: token, environment: environment.original)
        config?.delayStart = 5
        config?.eventBufferingEnabled = true
        
        instance = Adjust.getInstance() as? Adjust
        
        instance.appDidLaunch(config)
    }
    
    open override func activate() {
    }
    
    open func flush() {
        
    }
    
    open func reset() {
        
    }
    
    open override func addDevice(token: Data) {
        instance.setDeviceToken(token)
    }
    
    open override func event(_ event: AnalyticalEvent) {
        guard let event = update(event: event) else {
            return
        }
        
        guard let eventObject = (delegate as? AdjustProviderDelegate)?.adjustEvent(for: event) else {
            return
        }
        
        switch event.type {
        case .default, .screen, .finishTime, .purchase:
            instance.trackEvent(eventObject)
        case .time:
            super.event(event)
        }
        
        delegate?.analyticalProviderDidSendEvent(self, event: event)
    }
    
    public func alias(userId: String, forId: String) {
    }
    public func identify(userId: String, properties: Properties?) {

    }
    public func increment(property: String, by number: NSDecimalNumber) {
    }
    
    open func set(properties: Properties) {
        guard let properties = prepare(properties: properties) else {
            return
        }
        
        for (property, value) in properties {
            if let value = value as? String {
                instance.addSessionCallbackParameter(property, value: value)
            }
        }
    }
    
    private func prepare(properties: Properties?) -> Properties? {
        guard let properties = properties else {
            return nil
        }
        
        var finalProperties : Properties = [:]
        
        for (property, value) in properties {
            
            if value is String {
                finalProperties[property] = value
            }
            else {
                finalProperties[property] = String(describing: value)
            }
            
        }
        
        return finalProperties
    }
}
