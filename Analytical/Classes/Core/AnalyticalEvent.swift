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
        self.properties = properties
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
        var inputValue: Any?
        
        if let sendable = value as? SendableValue {
            inputValue = (value as! SendableValue).unwrapped
        }
        else {
            inputValue = value
        }
        switch inputValue {
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

extension SendableValue: CustomDebugStringConvertible{

    public var debugDescription: String {
        switch self {
        case .string(let string):
            return "\"\(string)\""
        case .int(let value):
            return "\(value)"
        case .double(let double):
            return "\(double)"
        case .bool(let bool):
            return "\(bool)"
        case .dictionary(let entries):
            let stringEntries = entries.map { "\"\($0)\": \($1.debugDescription)" }.joined(separator: ", ")
            return "{\(stringEntries)}"
        case .array(let values):
            let stringValues = values.map(\.debugDescription).joined(separator: ", ")
            return "[\(stringValues)]"
        case .url(let url):
            return url.debugDescription
        case .date(let date):
            return date.debugDescription
        case .null:
            return "nil"
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
