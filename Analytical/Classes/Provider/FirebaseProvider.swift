//
//  FirebaseProvider.swift
//  Analytical
//
//  Created by Dal Rupnik on 30/05/17.
//  Copyright © 2017 Unified Sense. All rights reserved.
//

import Analytical
import Firebase

public class FirebaseProvider : Provider<FIRApp>, Analytical {
    private var key : String
    
    public static let ApiKey = "ApiKey"
    
    public init (key: String) {
        self.key = key
        
        super.init()
    }
    
    public func setup(with properties: Properties?) {
    }
    
    public func flush() {
    }
    
    public func reset() {
        
    }
    
    public override func event(name: EventName, properties: Properties?) {
    }
    
    public func screen(name: EventName, properties: Properties?) {
    }
    
    public override func time(name: EventName, properties: Properties?) {
        super.time(name: name, properties: properties)

    }
    
    public func finishTime(_ name: EventName, properties: Properties?) {
    }
    
    public func identify(userId: String, properties: Properties?) {
    }
    
    public func alias(userId: String, forId: String) {
    }
    
    open func set(properties: Properties) {
    }
    
    public func increment(property: String, by number: NSDecimalNumber) {
        
    }
    
    public func purchase(amount: NSDecimalNumber, properties: Properties?) {

    }
}
