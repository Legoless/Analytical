//
//  AnswersProvider.swift
//  Analytical
//
//  Created by Dal Rupnik on 30/05/17.
//  Copyright © 2017 Unified Sense. All rights reserved.
//
import Analytical
import Crashlytics
import Fabric

public class AnswersProvider : BaseProvider<Answers>, AnalyticalProvider {
    public func setup(with properties: Properties?) {
        Fabric.with([ Answers.self, Crashlytics.self ])
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
        case .purchase:
            guard let amount = event.properties?[Property.Purchase.price.rawValue] as? NSDecimalNumber else {
                return
            }
            
            Answers.logPurchase(withPrice: amount, currency: event.properties?[Property.Purchase.currency.rawValue] as? String, success: true, itemName: event.properties?[Property.Purchase.item.rawValue] as? String, itemType: event.properties?[Property.Purchase.category.rawValue] as? String, itemId: event.properties?[Property.Purchase.sku.rawValue] as? String, customAttributes: mergeGlobal(properties: event.properties, overwrite: true))
        case .screen:
            Answers.logContentView(withName: event.name, contentType: "screen", contentId: event.properties?[Property.Content.identifier.rawValue] as? String, customAttributes: properties)
        case .default:
            switch event.name {
            case DefaultEvent.signUp.rawValue:
                Answers.logSignUp(withMethod: event.properties?[Property.User.registrationMethod.rawValue] as? String, success: NSNumber(value: true), customAttributes: mergeGlobal(properties: properties, overwrite: true))
            case DefaultEvent.login.rawValue:
                Answers.logLogin(withMethod: event.properties?[Property.User.registrationMethod.rawValue] as? String, success: NSNumber(value: true), customAttributes: mergeGlobal(properties: properties, overwrite: true))
            case DefaultEvent.share.rawValue:
                Answers.logShare(withMethod: nil, contentName: event.properties?[Property.Content.description.rawValue] as? String, contentType: event.properties?[Property.Content.type.rawValue] as? String, contentId: event.properties?[Property.Content.identifier.rawValue] as? String, customAttributes: mergeGlobal(properties: properties, overwrite: true))
            case DefaultEvent.invite.rawValue:
                Answers.logInvite(withMethod: nil, customAttributes: mergeGlobal(properties: properties, overwrite: true))
            case DefaultEvent.achievedLevel.rawValue:
                Answers.logLevelEnd(event.properties?[Property.Content.identifier.rawValue] as? String, score: NSNumber(value: (event.properties?[Property.Content.identifier.rawValue] as? Double) ?? 0.0), success: NSNumber(value: true), customAttributes: mergeGlobal(properties: properties, overwrite: true))
            case DefaultEvent.addedToCart.rawValue:
                Answers.logAddToCart(withPrice: event.properties?[Property.Purchase.price.rawValue] as? NSDecimalNumber, currency: event.properties?[Property.Purchase.currency.rawValue] as? String, itemName: event.properties?[Property.Purchase.item.rawValue] as? String, itemType: event.properties?[Property.Purchase.category.rawValue] as? String, itemId: event.properties?[Property.Purchase.sku.rawValue] as? String, customAttributes: mergeGlobal(properties: properties, overwrite: true))
            case DefaultEvent.initiatedCheckout.rawValue:
                Answers.logStartCheckout(withPrice: event.properties?[Property.Purchase.price.rawValue] as? NSDecimalNumber, currency: event.properties?[Property.Purchase.currency.rawValue] as? String, itemCount: NSNumber(value: (event.properties?[Property.Content.identifier.rawValue] as? Int) ?? 0), customAttributes: mergeGlobal(properties: properties, overwrite: true))
            case DefaultEvent.rating.rawValue:
                Answers.logRating(nil, contentName: event.properties?[Property.Content.description.rawValue] as? String, contentType: event.properties?[Property.Content.type.rawValue] as? String, contentId: event.properties?[Property.Content.identifier.rawValue] as? String, customAttributes: mergeGlobal(properties: properties, overwrite: true))
            case DefaultEvent.search.rawValue:
                Answers.logSearch(withQuery: event.properties?[Property.Content.searchTerm.rawValue] as? String, customAttributes: mergeGlobal(properties: properties, overwrite: true))
            default:
                Answers.logCustomEvent(withName: event.name, customAttributes: mergeGlobal(properties: properties, overwrite: true))
            }
            
        default:
            super.event(event)
        }
        
        delegate?.analyticalProviderDidSendEvent(self, event: event)
    }
    
    public func identify(userId: String, properties: Properties?) {
        Answers.logLogin(withMethod: properties?[Property.User.type.rawValue] as? String, success: true, customAttributes: properties)
    }
    
    public func alias(userId: String, forId: String) {
    }
    
    public func set(properties: Properties) {
    }
    
    public func increment(property: String, by number: NSDecimalNumber) {
        
    }
}
