//
//  AnalyticalEvent.swift
//  Analytical
//
//  Created by Dal Rupnik on 16/09/2017.
//  Copyright © 2017 Unified Sense. All rights reserved.
//

import Foundation

public typealias Properties = [String : Any]
public typealias EventName = String

public struct AnalyticalEvent {
    public enum EventType {
        case `default`
        case screen
        case time
        case finishTime
        case purchase
    }
    
    public var type = EventType.default
    public var name : EventName
    public var properties : Properties?
}
