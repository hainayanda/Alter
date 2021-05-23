//
//  MappableProperty.swift
//  Alter
//
//  Created by Nayanda Haberty on 18/11/20.
//

import Foundation

protocol AlterableProperty: class, Codable {
    var key: String? { get set }
    var nestedKeys: [String] { get }
    var rootKey: String? { get }
    var propertyKey: String? { get }
    var isNested: Bool { get }
    func trySet(_ some: Any?) throws
    func getAlteredValue() -> Any?
    func getMappedValue() -> Any?
    func decode(using container: KeyedDecodingContainer<AlterCodingKey>) throws
    func encode(using container: inout KeyedEncodingContainer<AlterCodingKey>) throws
}

extension AlterableProperty {
    public var nestedKeys: [String] {
        guard let key = key else {
            return []
        }
        return key.components(separatedBy: ".")
    }
    
    public var rootKey: String? {
        nestedKeys.first
    }
    
    public var propertyKey: String? {
        nestedKeys.last
    }
    
    public var isNested: Bool {
        nestedKeys.count > 1
    }
}

extension AlterableProperty {
    
    func encode<ToEncode: Encodable>(
        using container: inout KeyedEncodingContainer<AlterCodingKey>,
        value: ToEncode) throws {
        guard isNested else {
            try encodeNonNested(using: &container, value: value)
            return
        }
        try encodeNested(using: &container, value: value)
    }
    
    func encodeNested<ToEncode: Encodable>(
        using container: inout KeyedEncodingContainer<AlterCodingKey>,
        value: ToEncode) throws {
        var nestedContainer = container
        for (index, nestedKey) in nestedKeys.enumerated() where index + 1 != nestedKeys.count {
            nestedContainer = nestedContainer.nestedContainer(
                keyedBy: AlterCodingKey.self,
                forKey: AlterCodingKey(stringValue: nestedKey)
            )
        }
        try encodeNonNested(using: &nestedContainer, value: value)
    }
    
    func encodeNonNested<ToEncode: Encodable>(
        using container: inout KeyedEncodingContainer<AlterCodingKey>,
        value: ToEncode) throws {
        guard let key = self.propertyKey else {
            throw AlterError.whenEncode(
                type: ToEncode.self,
                reason: "AlterableProperty did not have key"
            )
        }
        try container.encode(value, forKey: AlterCodingKey(stringValue: key))
    }
    
    func getValueFrom<ToDecode: Decodable>(container: KeyedDecodingContainer<AlterCodingKey>) throws -> ToDecode {
        guard let codingKey = container.allKeys.first(where: { $0.stringValue == rootKey }) else {
            throw AlterError.whenDecode(
                type: Self.self,
                reason: "property key did not matched any KeyedDecodingContainer keys"
            )
        }
        guard isNested else {
            return try container.decode(ToDecode.self, forKey: codingKey)
        }
        var nestedContainer = container
        var nestedCodingKey = codingKey
        for (index, nestedKey) in nestedKeys.enumerated() {
            nestedCodingKey = AlterCodingKey(stringValue: nestedKey)
            if index + 1 != nestedKeys.count {
                nestedContainer = try nestedContainer.nestedContainer(
                    keyedBy: AlterCodingKey.self,
                    forKey: nestedCodingKey
                )
            }
        }
        return try nestedContainer.decode(ToDecode.self, forKey: nestedCodingKey)
    }
}

@propertyWrapper
public class Mapped<Value: Codable>: AlterableProperty, Codable {
    
    var key: String?
    
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
    
    func decode(using container: KeyedDecodingContainer<AlterCodingKey>) throws {
        wrappedValue = try getValueFrom(container: container)
    }
    
    func encode(using container: inout KeyedEncodingContainer<AlterCodingKey>) throws {
        try encode(using: &container, value: wrappedValue)
    }
    
    func trySet(_ some: Any?) throws {
        guard let value = some as? Value else {
            throw AlterError.whenSet(
                into: Value.self,
                reason: "value set into \(key ?? "unknown") Mapped property is not \(String(describing: Value.self))"
            )
        }
        wrappedValue = value
    }
    
    func getAlteredValue() -> Any? {
        wrappedValue
    }
    
    func getMappedValue() -> Any? {
        wrappedValue
    }
}

@propertyWrapper
public class AlterMapped<Value, AlteredValue, Alterer: TypeAlterer>
: AlterableProperty, Codable where Alterer.Value == Value, Alterer.AlteredValue == AlteredValue {
    
    var key: String?
    
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
    
    func decode(using container: KeyedDecodingContainer<AlterCodingKey>) throws {
        let realValue: AlteredValue = try getValueFrom(container: container)
        wrappedValue = alterer.alterBack(value: realValue)
    }
    
    func encode(using container: inout KeyedEncodingContainer<AlterCodingKey>) throws {
        try encode(using: &container, value: projectedValue)
    }
    
    func trySet(_ some: Any?) throws {
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
    
    func getAlteredValue() -> Any? {
        projectedValue
    }
    
    func getMappedValue() -> Any? {
        wrappedValue
    }
    
}

extension Mapped: Equatable where Value: Equatable {
    public static func == (lhs: Mapped<Value>, rhs: Mapped<Value>) -> Bool {
        lhs.wrappedValue == rhs.wrappedValue
    }
}

extension AlterMapped: Equatable where Value: Equatable {
    public static func == (lhs: AlterMapped<Value, AlteredValue, Alterer>, rhs: AlterMapped<Value, AlteredValue, Alterer>) -> Bool {
        lhs.wrappedValue == rhs.wrappedValue
    }
}

extension Mapped: Hashable where Value: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(wrappedValue)
    }
}

extension AlterMapped: Hashable where Value: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(wrappedValue)
    }
}
