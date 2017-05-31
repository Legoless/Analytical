//
//  AnswersProvider.swift
//  Analytical
//
//  Created by Dal Rupnik on 30/05/17.
//  Copyright © 2017 Unified Sense. All rights reserved.
//

import Analytical
import Answers
import Fabric

public class AnswersProvider : Provider<Answers>, Analytical {
    public func setup(with properties: Properties?) {
        Fabric.with([ Answers.self ])
    }
    
    public func flush() {
    }
    
    public func reset() {
        
    }
    
    public override func event(name: EventName, properties: Properties?) {
        Answers.logCustomEvent(withName: name, customAttributes: mergeGlobal(properties: properties, overwrite: true))
    }
    
    public func screen(name: EventName, properties: Properties?) {
        Answers.logContentView(withName: name, contentType: "screen", contentId: properties?[Property.Content.identifier.rawValue] as? String, customAttributes: properties)
    }
    
    
    public func finishTime(_ name: EventName, properties: Properties?) {
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
    
    public override func purchase(amount: NSDecimalNumber, properties: Properties?) {
        Answers.logPurchase(withPrice: amount, currency: properties?[Property.Purchase.currency.rawValue] as? String, success: true, itemName: properties?[Property.Purchase.item.rawValue] as? String, itemType: properties?[Property.category.rawValue] as? String, itemId: properties?[Property.Purchase.sku.rawValue] as? String, customAttributes: mergeGlobal(properties: properties, overwrite: true))
    }
}
