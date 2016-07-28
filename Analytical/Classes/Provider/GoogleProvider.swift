//
//  GoogleProvider.swift
//  Application
//
//  Created by Dal Rupnik on 18/07/16.
//  Copyright © 2016 Blub Blub. All rights reserved.
//

import Analytical
import Foundation

public class GoogleProvider : Provider<GAITracker>, Analytical {
    public static let TrackingId = "TrackingId"
    
    private var gai : GAI!
    private var trackingId : String?
    
    public var uncaughtExceptions : Bool = false {
        didSet {
            gai.trackUncaughtExceptions = uncaughtExceptions
        }
    }
    
    init(trackingId: String? = nil) {
        self.trackingId = trackingId
        
        super.init()
    }
    
    //
    // MARK: Analytical
    //
    
    public func setup(properties: Properties?) {
        
        gai = GAI.sharedInstance()
        gai.trackUncaughtExceptions = false
        //gai.logger.logLevel = GAILogLevel.Verbose
        
        if let trackingId = properties?[GoogleProvider.TrackingId] as? String {
            self.trackingId = trackingId
        }
            
        if let trackingId = trackingId {
            instance = gai.trackerWithTrackingId(trackingId)
        }
        else {
            var configureError:NSError?
            GGLContext.sharedInstance().configureWithError(&configureError)
            assert(configureError == nil, "Error configuring Google services: \(configureError)")
            
            instance = gai.defaultTracker
        }
    }
    
    public func flush() {
        gai.dispatch()
    }
    
    public func reset() {
        //
        // Google has no user variable reset mechanism, as there is no retrieval mechanism.
        //
        // TODO: Should this be implemented on the provider side, just for the sake of completion?
        //
    }
    
    public override func event(name: EventName, properties: Properties? = nil) {
        //
        // Google Analytics works with Category, Action, Label and Value,
        // where both Category and Action are required.
        //
        
        let properties = prepareProperties(properties)
        
        instance.send(GAIDictionaryBuilder.createEventWithCategory(properties["category"] as? String, action: name, label: properties["label"] as? String, value: properties["value"] as? NSNumber).parsed)
    }
    
    public func screen(name: EventName, properties: Properties? = nil) {
        //
        // Send screen as an event in addition
        //
        event(name, properties: properties)
        
        instance.set(kGAIScreenName, value: name)
        instance.send(GAIDictionaryBuilder.createScreenView().build() as [NSObject : AnyObject])
    }
    
    public override func finish(name: EventName, properties: Properties? = nil) {
        
        guard let startDate = events[name] else {
            return
        }
        
        event(name, properties: properties)
        
        let properties = prepareProperties(properties)
        
        let interval = NSNumber(double: NSDate().timeIntervalSinceDate(startDate))
        
        instance.send(GAIDictionaryBuilder.createTimingWithCategory(properties["category"] as? String, interval: interval, name: name, label: properties["label"] as? String).parsed)
    }
    
    public func identify(userId: String, properties: Properties? = nil) {
        instance.set(kGAIUserId, value: userId)
        
        if let properties = properties {
            set(properties)
        }
    }
    
    public func alias(userId: String, forId: String) {
        //
        // No alias power for Google Analytics
        //
        
        identify(forId)
    }
    
    public func set(properties: Properties) {
        let properties = prepareProperties(properties)
        
        for (property, value) in properties {
            guard let value = value as? String else {
                continue
            }
            
            instance.set(property, value: value)
        }
    }
    
    public func increment(property: String, by number: NSDecimalNumber) {
        //
        // No increment for Google Analytics
        //
    }
    
    public func purchase(amount: NSDecimalNumber, properties: Properties? = nil) {
        let properties = prepareProperties(properties)
        
        let transactionId = properties[Property.Purchase.TransactionId.rawValue] as? String
        let affilation = properties[Property.Purchase.Affiliation.rawValue] as? String
        let tax = properties[Property.Purchase.Tax.rawValue] as? NSNumber
        let shipping = properties[Property.Purchase.Shipping.rawValue] as? NSNumber
        let currency = properties[Property.Purchase.Currency.rawValue] as? String
        
        let transaction = GAIDictionaryBuilder.createTransactionWithId(transactionId, affiliation: affilation, revenue: amount, tax: tax, shipping: shipping, currencyCode: currency)
        
        let item = properties[Property.Purchase.Item.rawValue] as? String
        let category = properties[Property.Category.rawValue] as? String
        let sku = properties[Property.Purchase.Sku.rawValue] as? String
        let quantity = properties[Property.Purchase.Quantity.rawValue] as? NSNumber
        
        let itemTransaction = GAIDictionaryBuilder.createItemWithTransactionId(transactionId, name: item, sku: sku, category: category, price: amount, quantity: quantity, currencyCode: currency)
        
        instance.send(transaction.parsed)
        instance.send(itemTransaction.parsed)
    }
    
    //
    // MARK: Private Methods
    //
    
    private func prepareProperties(properties: Properties?) -> Properties {
        var currentProperties : Properties! = properties
        
        if currentProperties == nil {
            currentProperties = [:]
        }
        
        if currentProperties["category"] == nil {
            currentProperties["category"] = "default"
        }
        
        return currentProperties
    }
}

//
// MARK: Extensions for helper methods
//
extension GAIDictionaryBuilder {
    var parsed : [NSObject : AnyObject] {
        return self.build() as [NSObject : AnyObject]
    }
}