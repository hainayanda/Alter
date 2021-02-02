//
//  Array+Extensions.swift
//  Alter
//
//  Created by Nayanda Haberty on 21/01/21.
//

import Foundation

public extension Array where Element: Alterable {
    /// Shortcut to convert array of Alterable to Data representation of JSON using JSONSerialization
    /// - Parameter prettyPrinted: if true, it will use prettyPrinted outputFormatting
    /// - Throws: Error occurs when serializing
    /// - Returns: Data representation of JSON Array
    func toJSONData(prettyPrinted: Bool) throws -> Data {
        try JSONSerialization.data(withJSONObject: toJSON(), options: [.prettyPrinted])
    }
    
    /// Shortcut to convert array of Alterable to Data representation of JSON using JSONSerialization
    /// - Throws: Error occurs when serializing
    /// - Returns: Data representation of JSON
    func toJSONData() throws -> Data {
        try JSONSerialization.data(withJSONObject: toJSON(), options: [])
    }
    
    /// Shortcut to convert array of Alterable to String representation of JSON using JSONSerialization
    /// - Parameter prettyPrinted: if true, it will use prettyPrinted outputFormatting
    /// - Throws: Error occurs when serializing
    /// - Returns: String representation of JSON
    func toJSONString(prettyPrinted: Bool) throws -> String {
        guard let string = String(data: try toJSONData(prettyPrinted: prettyPrinted), encoding: .utf8) else {
            throw AlterError.whenAltering(
                from: Self.self,
                into: String.self,
                reason: "failed to convert Data into string using UTF-8 encoding"
            )
        }
        return string
    }
    
    /// Shortcut to convert array of Alterable to String representation of JSON using JSONSerialization
    /// - Throws: Error occurs when serializing
    /// - Returns: String representation of JSON
    func toJSONString() throws -> String {
        guard let string = String(data: try toJSONData(), encoding: .utf8) else {
            throw AlterError.whenAltering(
                from: Self.self,
                into: String.self,
                reason: "failed to convert Data into string using UTF-8 encoding"
            )
        }
        return string
    }
    
    /// Convert array of Alterable to JSON
    /// - Throws: Error occurs when serializing
    /// - Returns: Array of JSON
    func toJSON() throws -> [[String: Any]] {
        try compactMap { try $0.toJSON() }
    }
}
