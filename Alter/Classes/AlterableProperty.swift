//
//  MappableProperty.swift
//  Alter
//
//  Created by Nayanda Haberty on 18/11/20.
//

import Foundation

public protocol AlterableProperty: class, Codable {
    var key: String? { get set }
    func trySet(_ some: Any?) throws
    func getAlteredValue() -> Any?
    func getMappedValue() -> Any?
    func decode(using container: KeyedDecodingContainer<AlterCodingKey>) throws
    func encode(using container: inout KeyedEncodingContainer<AlterCodingKey>) throws
}

extension AlterableProperty {
    func encode<ToEncode: Encodable>(
        using container: inout KeyedEncodingContainer<AlterCodingKey>,
        value: ToEncode) throws {
        guard let key = self.key else {
            throw AlterError.whenEncode(
                type: ToEncode.self,
                reason: "AlterableProperty did not have key"
            )
        }
        try container.encode(value, forKey: AlterCodingKey(stringValue: key))
    }
    
    func getValueFrom<ToDecode: Decodable>(container: KeyedDecodingContainer<AlterCodingKey>) throws -> ToDecode {
        guard let codingKey = container.allKeys.first(where: { $0.stringValue == key }) else {
            throw AlterError.whenDecode(
                type: Self.self,
                reason: "property key did not matched any KeyedDecodingContainer keys"
            )
        }
        return try container.decode(ToDecode.self, forKey: codingKey)
    }
}

@propertyWrapper
public class Mapped<Value: Codable>: AlterableProperty, Codable {
    
    public var key: String?
    
    public var wrappedValue: Value
    
    public init(wrappedValue: Value, key: String) {
        self.wrappedValue = wrappedValue
        self.key = key
    }
    
    public init<Key: RawRepresentable>(wrappedValue: Value, key: Key) where Key.RawValue == String {
        self.wrappedValue = wrappedValue
        self.key = key.rawValue
    }
    
    public init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }
    
    public required init(from decoder: Decoder) throws {
        wrappedValue = try .init(from: decoder)
    }
    
    public func encode(to encoder: Encoder) throws {
        try wrappedValue.encode(to: encoder)
    }
    
    public func decode(using container: KeyedDecodingContainer<AlterCodingKey>) throws {
        wrappedValue = try getValueFrom(container: container)
    }
    
    public func encode(using container: inout KeyedEncodingContainer<AlterCodingKey>) throws {
        try encode(using: &container, value: wrappedValue)
    }
    
    public func trySet(_ some: Any?) throws {
        guard let value = some as? Value else {
            throw AlterError.whenSet(
                into: Value.self,
                reason: "value set into \(key ?? "unknown") Mapped property is not \(String(describing: Value.self))"
            )
        }
        wrappedValue = value
    }
    
    public func getAlteredValue() -> Any? {
        wrappedValue
    }
    
    public func getMappedValue() -> Any? {
        wrappedValue
    }
}

@propertyWrapper
public class AlterMapped<Value, AlteredValue, Alterer: TypeAlterer>
: AlterableProperty, Codable where Alterer.Value == Value, Alterer.AlteredValue == AlteredValue {
    
    public var key: String?
    
    public var wrappedValue: Value
    
    public var projectedValue: AlteredValue {
        alterer.alter(value: wrappedValue)
    }
    
    var alterer: Alterer
    
    public init(wrappedValue: Value, key: String, alterer: Alterer) {
        self.wrappedValue = wrappedValue
        self.key = key
        self.alterer = alterer
    }
    
    public init<Key: RawRepresentable>(wrappedValue: Value, key: Key, alterer: Alterer) where Key.RawValue == String {
        self.wrappedValue = wrappedValue
        self.key = key.rawValue
        self.alterer = alterer
    }
    
    public init(wrappedValue: Value, alterer: Alterer) {
        self.wrappedValue = wrappedValue
        self.alterer = alterer
    }
    
    public required init(from decoder: Decoder) throws {
        throw AlterError.whenDecode(
            type: Value.self,
            reason: "ManualMapped propertyWrapper cannot be initialize using decoder because there's no Mapper provided"
        )
    }
    
    public func encode(to encoder: Encoder) throws {
        try projectedValue.encode(to: encoder)
    }
    
    public func decode(using container: KeyedDecodingContainer<AlterCodingKey>) throws {
        let realValue: AlteredValue = try getValueFrom(container: container)
        wrappedValue = alterer.alterBack(value: realValue)
    }
    
    public func encode(using container: inout KeyedEncodingContainer<AlterCodingKey>) throws {
        try encode(using: &container, value: projectedValue)
    }
    
    public func trySet(_ some: Any?) throws {
        if let value = some as? Value {
            wrappedValue = value
        } else if let realValue = some as? AlteredValue {
            wrappedValue = alterer.alterBack(value: realValue)
        } else {
            throw AlterError.whenSet(
                into: Value.self,
                reason: "value set into \(key ?? "unknown") AlterMapped property is not \(String(describing: Value.self)) or \(String(describing: AlteredValue.self))"
            )
        }
    }
    
    public func getAlteredValue() -> Any? {
        projectedValue
    }
    
    public func getMappedValue() -> Any? {
        wrappedValue
    }
    
}
