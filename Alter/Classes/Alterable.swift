//
//  Alterable.swift
//  Alter
//
//  Created by Nayanda Haberty on 18/11/20.
//

import Foundation

/// Alterable Protocol and Codable
public typealias AlterCodable = Alterable & Codable

/// MutableAlterable Protocol and Codable
public typealias MutableAlterCodable = MutableAlterable & Codable

/// Alterable Protocol
public protocol Alterable {
    /// Decode strategy. Default is `ignoreUnknownKey`. Implement this to use custom strategy.
    /// This property will be read when decoded using method `decodeMappedProperties(from:)` or default `init(from:)`.
    /// If the value is `throwErrorOnUnknownKey`, it will throw error if decoder did not have key mapped.
    var decodeStrategy: DecodeStrategy { get }
    
    /// Property Decode Error Handling. Default is `ignoreError`. Implement this to use custom strategy.
    /// This property will be read when decoded using method `decodeMappedProperties(from:)` or default `init(from:)`.
    /// If the value is `ignoreError`, it will not throw error when fail to decode properties and use default value instead
    /// If the value is `throwError`, it will throw error when fail to decode properties
    /// If the value is `handleError` it will run closure provided by `handleError` enum when fail to decode properties
    var propertyDecodeErrorHandling: PropertyDecodeErrorHandling { get }
    
    /// Default init
    init()
    
    /// Shortcut to convert Alterable to Data using `JSONEncoder`
    /// - Parameter prettyPrinted: if true, it will use prettyPrinted outputFormatting
    func toJSONData(prettyPrinted: Bool) throws -> Data
    
    /// Shortcut to convert Alterable to Data using `JSONEncoder`
    func toJSONData() throws -> Data
    
    /// Shortcut to convert Alterable to String using `JSONEncoder`
    /// - Parameter prettyPrinted: if true, it will use prettyPrinted outputFormatting
    func toJSONString(prettyPrinted: Bool) throws -> String
    
    /// Shortcut to convert Alterable to String using `JSONEncoder`
    func toJSONString() throws -> String
    
    /// Shortcut to convert Alterable to Dictionary using `JSONEncoder` and `JSONSerialization`
    func toJSON() throws -> [String: Any]
}

/// Alterable which could be accessed by using subscript
public protocol MutableAlterable: Alterable {
    
    subscript<Value>(mappedKey key: String) -> Value? { get set }
    
}

public enum DecodeStrategy {
    case ignoreUnknownKey
    case throwErrorOnUnknownKey
}

public enum PropertyDecodeErrorHandling {
    public typealias ErrorHandler = (String, Error) throws -> Void
    case ignoreError
    case throwError
    case handleError(ErrorHandler)
}

public extension Alterable where Self: Codable {
    var decodeStrategy: DecodeStrategy { .ignoreUnknownKey }
    var propertyDecodeErrorHandling: PropertyDecodeErrorHandling { .ignoreError }
    
    init(from decoder: Decoder) throws {
        self.init()
        try decodeMappedProperties(from: decoder)
    }
    
    /// Method to decode all mapped property from given `Decoder` and return `KeyedDecodingContainer`
    /// - Parameter decoder: Decoder
    /// - Throws: Error occurs when decode. If error is from Alter, it will be `AlterError`
    /// - Returns: KeyedDecodingContainer of AlterCodingKey
    @discardableResult
    func decodeMappedProperties(from decoder: Decoder) throws -> KeyedDecodingContainer<AlterCodingKey> {
        let container = try decoder.container(keyedBy: AlterCodingKey.self)
        try alterableProperties.forEach { alterable in
            guard let rootKey = alterable.rootKey else { return }
            guard container.allKeys.contains(where: { $0.stringValue == rootKey }) else {
                if decodeStrategy == .throwErrorOnUnknownKey {
                    throw AlterError.whenDecode(
                        type: Self.self,
                        reason: "key did not match any mapped property"
                    )
                }
                return
            }
            do {
                try alterable.decode(using: container)
            } catch {
                switch propertyDecodeErrorHandling {
                case .ignoreError:
                    return
                case .handleError(let handler):
                    try handler(rootKey, error)
                case .throwError:
                    throw error
                }
            }
        }
        return container
    }
    
    /// Shortcut of `try JSONDecoder().decode(Self.self, from: jsonData)`
    /// - Parameter jsonData: Data representation of JSON String
    /// - Throws: Error occurs when decode
    /// - Returns: Decoded JSON Data
    static func from(jsonData: Data) throws -> Self {
        try JSONDecoder().decode(Self.self, from: jsonData)
    }
    
    /// Shortcut to decode JSON dictionary into Decoded Object using `JSONSerialization` and `JSONDecoder`
    /// - Parameter json: JSON dictionary
    /// - Throws: Error occurs when decode
    /// - Returns: Decoded JSON
    static func from(json: [String: Any]) throws -> Self {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try from(jsonData: data)
    }
    
    /// Shortcut to decode JSON String into Decoded Object using `JSONDecoder`
    /// - Parameter jsonString: String representation of JSON
    /// - Throws: Error occurs when decode. If error is from Alter, it will be `AlterError`
    /// - Returns: Decoded JSON String
    static func from(jsonString: String) throws -> Self {
        guard let jsonData = jsonString.data(using: .utf8) else {
            throw AlterError.whenAltering(
                from: String.self,
                into: Self.self,
                reason: "failed to convert string into Data encoded using UTF-8"
            )
        }
        return try from(jsonData: jsonData)
    }
    
    func toJSONData(prettyPrinted: Bool) throws -> Data {
        let encoder = JSONEncoder()
        if prettyPrinted {
            encoder.outputFormatting = .prettyPrinted
        }
        return try encoder.encode(self)
    }
    
    func toJSONData() throws -> Data {
        try toJSONData(prettyPrinted: false)
    }
    
    func toJSON() throws -> [String: Any] {
        let jsonData = try toJSONData()
        guard let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] else {
            throw AlterError.whenAltering(
                from: Self.self,
                into: [String: Any].self,
                reason: "failed to serialize \(String(describing: Self.self)) using JSONSerialization into JSON Object"
            )
        }
        return json
    }
    
    func toJSONString(prettyPrinted: Bool) throws -> String {
        let jsonData = try toJSONData(prettyPrinted: prettyPrinted)
        guard let jsonString = String(data: jsonData, encoding: .utf8) else {
            throw AlterError.whenAltering(
                from: Self.self,
                into: String.self,
                reason: "failed to convert Data into string using UTF-8 encoding"
            )
        }
        return jsonString
    }
    
    func toJSONString() throws -> String {
        try toJSONString(prettyPrinted: false)
    }
    
    func encode(to encoder: Encoder) throws {
        try encodeMappedProperties(to: encoder)
    }
    
    /// Method to encode all mapped property from given `Encoder` and return `KeyedEncodingContainer`
    /// - Parameter encoder: Encoder
    /// - Throws: Error occurs when encode. If error is from Alter, it will be `AlterError`
    /// - Returns: KeyedEncodingContainer of AlterCodingKey
    @discardableResult
    func encodeMappedProperties(to encoder: Encoder) throws -> KeyedEncodingContainer<AlterCodingKey> {
        var container = encoder.container(keyedBy: AlterCodingKey.self)
        try alterableProperties.forEach { alterable in
            try alterable.encode(using: &container)
        }
        return container
    }
    
    internal var alterableProperties: [AlterableProperty] {
        Mirror(reflecting: self).alterableProperties
    }
}

public extension MutableAlterable where Self: Codable {
    
    subscript<Value, Key: RawRepresentable>(mappedKey key: Key) -> Value? where Key.RawValue == String {
        get {
            return self[mappedKey: key.rawValue]
        }
        set {
            self[mappedKey: key.rawValue] = newValue
        }
    }
    
    subscript<Value>(mappedKey key: String) -> Value? {
        get {
            guard let property = alterableProperties.first(where: { $0.key == key }) else {
                debugPrint("Alter Error: cannot find mapped property with key \(key) in \(String(describing: Self.self))")
                return nil
            }
            guard let value = property.getMappedValue() as? Value ?? property.getAlteredValue() as? Value else {
                debugPrint("Alter Error: cannot cast property value into \(String(describing: Value.self)) in property with key \(key) inside \(String(describing: Self.self))")
                return nil
            }
            return value
        }
        set {
            guard let property = alterableProperties.first(where: { $0.key == key }) else {
                return
            }
            do {
                try property.trySet(newValue)
            } catch {
                debugPrint(error.localizedDescription)
            }
        }
    }
}
