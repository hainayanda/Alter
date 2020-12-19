//
//  Decoder+Extensions.swift
//  Alter
//
//  Created by Nayanda Haberty on 24/11/20.
//

import Foundation

public extension KeyedDecodingContainer where Key == AlterCodingKey {
    func decode<Result: Decodable, Key: RawRepresentable>(forKey key: Key) throws -> Result where Key.RawValue == String {
        try decode(forKey: key.rawValue)
    }
    
    func decode<Result: Decodable>(forKey key: String) throws -> Result {
        guard let codingKey = allKeys.first(where: { $0.stringValue == key }) else {
            throw AlterError.whenDecode(
                type: Result.self,
                reason: "decode with key \(key)"
            )
        }
        return try decode(Result.self, forKey: codingKey)
    }
}

public extension KeyedEncodingContainer where Key == AlterCodingKey {
    mutating func encode<Value: Encodable, Key: RawRepresentable>(value: Value, forKey key: Key) throws where Key.RawValue == String {
        try encode(value: value, forKey: key.rawValue)
    }
    
    mutating func encode<Value: Encodable>(value: Value, forKey key: String) throws {
        try encode(value, forKey: AlterCodingKey(stringValue: key))
    }
}
