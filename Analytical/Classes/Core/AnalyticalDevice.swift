//
//  AnalyticalDevice.swift
//  Analytical
//
//  Created by Vid Vozelj on 30. 7. 25.
//

import ObjectiveC
import Foundation

public enum IdentifierType: Sendable {
    case idfa
    case idfv
    case random
}

public final class AnalyticalDevice {
    private let deviceKey = "AnalyticsDeviceKey"
    
    private let identityProvider: (@Sendable (IdentifierType) -> UUID?)?
    
    public init(identityProvider: (@Sendable (IdentifierType) -> UUID?)? = nil) {
        self.identityProvider = identityProvider
    }
        
    public var deviceId: String {
        let userDefaults = UserDefaults.standard
        
        if let advertisingIdentifier = identityProvider?(.idfa)?.uuidString {
            return advertisingIdentifier
        }
        
        if let id = userDefaults.string(forKey: deviceKey) {
            return id
        }
        
        if let id = identityProvider?(.idfv)?.uuidString {
            userDefaults.set(id, forKey: deviceKey)
            return id
        }
        
        let id = identityProvider?(.random)?.uuidString ?? randomId()
        userDefaults.set(id, forKey: deviceKey)
        
        return id
    }
}
