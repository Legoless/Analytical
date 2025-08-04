//
//  AnalyticalEvent.swift
//  Analytical
//
//  Created by Dal Rupnik on 16/09/2017.
//  Copyright © 2017 Unified Sense. All rights reserved.
//

import Foundation

public typealias Properties = [String: SendableValue]
public typealias EventName = String

public struct AnalyticalEvent: Sendable {
    public enum EventType: Sendable {
        case `default`
        case screen
        case time
        case finishTime
        case purchase
    }

    public var type = EventType.default
    public var name : EventName
    public var properties : Properties?

    public init(type: EventType, name: EventName, properties: Properties? = nil) {
        self.type = type
        self.name = name
        if let props = properties {
            // Convert [String: Any] to [String: SendableValue]
            var converted = Properties()
            for (key, value) in props {
                converted[key] = SendableValue(value)
            }
            self.properties = converted
        } else {
            self.properties = nil
        }
    }
}


public enum SendableValue: Sendable, Codable {
    case string(String)
    case int(Int)
    case double(Double)
    case bool(Bool)
    case dictionary([String: SendableValue])
    case array([SendableValue])
    case url(URL)
    case date(Date)
    case null

    // Convenience init from Any? — safely maps allowed types to SendableValue
    public init(_ value: Any?) {
        print("SendableValue init received:", type(of: value), "=", value ?? "nil")
        var neki: Any?
        
        if let sendable = value as? SendableValue {
            neki = (value as! SendableValue).unwrapped
        }
        else {
            neki = value
        }
        switch neki {
        case let string as String:
            self = .string(string)
            break
        case let int as Int:
            self = .int(int)
            break
        case let double as Double:
            self = .double(double)
            break
        case let bool as Bool:
            self = .bool(bool)
            break
        case let dict as [String: Any]:
            var converted = [String: SendableValue]()
            for (key, val) in dict {
                converted[key] = SendableValue(val)
            }
            self = .dictionary(converted)
            break
        case let array as [Any]:
            self = .array(array.map { SendableValue($0) })
            break
        case let url as URL:
            self = .url(url)
        case let date as Date:
            self = .date(date)
        default:
            // Unsupported types fallback to null
            self = .null
            break
        }
    }

    // Optional: unwrap SendableValue to Any
    public var unwrapped: Any? {
        switch self {
        case .string(let s): return s
        case .int(let i): return i
        case .double(let d): return d
        case .bool(let b): return b
        case .dictionary(let dict):
            return dict.mapValues { $0.unwrapped }
        case .array(let arr):
            return arr.map { $0.unwrapped }
        case .url(let u): return u
        case .date(let date): return date
        case .null:
            return nil
        }
    }
}

public struct Payload: Sendable {
    public let data: [String: SendableValue]

    public init(_ dict: [AnyHashable: Any]) {
        var result: [String: SendableValue] = [:]
        for (key, value) in dict {
            if let keyString = key.base as? String {
                result[keyString] = SendableValue(value)
            }
        }
        self.data = result
    }
}

public extension Dictionary where Key == String, Value == Any {
    func toAnalyticalProperties() -> Analytical.Properties {
        var result = Analytical.Properties()
        for (key, value) in self {
            result[key] = SendableValue(value)
        }
        return result
    }
}

public extension Dictionary where Key == String, Value == SendableValue {
    func unwrapped() -> [String: Any] {
        var result: [String: Any] = [:]
        for (key, value) in self {
            result[key] = value.unwrapped
        }
        return result
    }
}
