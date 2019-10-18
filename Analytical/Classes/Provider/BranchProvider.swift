//
//  BranchProvider.swift
//  Analytical_Example
//
//  Created by Erik Drobne on 17/10/2019.
//  Copyright © 2019 Unified Sense. All rights reserved.
//

import Analytical
import Branch

public class BranchProvider : BaseProvider<Branch>, AnalyticalProvider {
    
    public static let ShouldUseTestKey = false
    public static let IsDebugEnabled = false
    public static let ShouldStartSession = true
    
    private var launchOptions = [UIApplication.LaunchOptionsKey: Any]?
    
    public func setup(with properties: Properties?) {
        launchOptions = properties?[Property.Launch.options.rawValue] as? [UIApplication.LaunchOptionsKey: Any]
        
        if let shouldUseTestKey = properties?[BranchProvider.ShouldUseTestKey] as? Bool {
            Branch.setUseTestBranchKey(shouldUseTestKey)
        }
        
        instance = Branch.getInstance()
        
        if properties?[BranchProvider.IsDebugEnabled] as? Bool ?? false {
            instance.setDebug()
        }
        
        if let shouldStartSession = properties?[BranchProvider.ShouldStartSession] as? Bool, shouldStartSession {
            initSession()
        }
    }
    
    public func initSession() {
        instance.initSession(launchOptions: launchOptions, andRegisterDeepLinkHandler: { params, error in
            
        })
    }
    
    public func flush() {
    
    }
    
    public func reset() {
        
    }
    
    public func identify(userId: String, properties: Properties?) {
        instance.setIdentity(userId)
    }
    
    public func alias(userId: String, forId: String) {
        
    }
    
    public func set(properties: Properties) {
        
    }
    
    public func increment(property: String, by number: NSDecimalNumber) {
        
    }
    
    public override func update(event: AnalyticalEvent) -> AnalyticalEvent? {
        guard let event = super.update(event: event) else {
            return nil
        }
        
        return event
    }
    
    public override func event(_ event: AnalyticalEvent) {
        guard let event = update(event: event) else {
            return
        }
        
        guard let defaultName = DefaultEvent(rawValue: event.name), let branchEvent = branchEvent(for: defaultName) else {
            return
        }
        
        BranchEvent.standardEvent(branchEvent).logEvent()
        delegate?.analyticalProviderDidSendEvent(self, event: event)
    }
    
    public override func activate() {
        
    }
    
    private func branchEvent(for name: DefaultEvent) -> BranchStandardEvent? {
        switch name {
        case .startTrial:
            return .startTrial
        case .addedToCart:
            return .addToCart
        case .spendCredits:
            return .spendCredits
        default:
            return nil
        }
    }
}
