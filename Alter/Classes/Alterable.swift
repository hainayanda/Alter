//
//  Alterable.swift
//  Alter
//
//  Created by Nayanda Haberty on 18/11/20.
//

import Foundation

public protocol Alterable: Codable {
    var decodeStrategy: DecodeStrategy { get }
    init()
    func toJSONData(prettyPrinted: Bool) throws -> Data
    func toJSONData() throws -> Data
    func toJSONString(prettyPrinted: Bool) throws -> String
    func toJSONString() throws -> String
    func toJSON() throws -> [String: Any]
}

public enum DecodeStrategy {
    case ignoreUnknownKey
    case throwErrorOnUnknownKey
}

public extension Alterable {
    var decodeStrategy: DecodeStrategy { .ignoreUnknownKey }
    
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
    
    init(from decoder: Decoder) throws {
        self.init()
        try decodeMappable(from: decoder)
    }
    
    @discardableResult
    func decodeMappable(from decoder: Decoder) throws -> KeyedDecodingContainer<AlterCodingKey> {
        let container = try decoder.container(keyedBy: AlterCodingKey.self)
        try alterableProperties.forEach { alterable in
            if decodeStrategy == .throwErrorOnUnknownKey,
               !container.allKeys.contains(where: { $0.stringValue == alterable.key }) {
                throw AlterError.whenDecode(
                    type: Self.self,
                    reason: "key did not match any mapped property"
                )
            }
            try alterable.decode(using: container)
        }
        return container
    }
    
    static func from(jsonData: Data) throws -> Self {
        try JSONDecoder().decode(Self.self, from: jsonData)
    }
    
    static func from(json: [String: Any]) throws -> Self {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try from(jsonData: data)
    }
    
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
        try encodeMappable(to: encoder)
    }
    
    @discardableResult
    func encodeMappable(to encoder: Encoder) throws -> KeyedEncodingContainer<AlterCodingKey> {
        var container = encoder.container(keyedBy: AlterCodingKey.self)
        try alterableProperties.forEach { alterable in
            try alterable.encode(using: &container)
        }
        return container
    }
    
    private func prepareProperty(_ alterableProperty: AlterableProperty, label: String) {
        alterableProperty.key = alterableProperty.key ?? label.replacingOccurrences(
            of: "^_",
            with: "",
            options: .regularExpression,
            range: nil
        )
    }
    
    var alterableProperties: [AlterableProperty] {
        let reflection = Mirror(reflecting: self)
        return reflection.children.compactMap { (label, value) -> AlterableProperty?  in
            guard let label = label,
                  let alterableProperty = value as? AlterableProperty else { return nil }
            prepareProperty(alterableProperty, label: label)
            return alterableProperty
        }
    }
}
