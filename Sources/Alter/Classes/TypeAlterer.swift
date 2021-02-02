//
//  TypeAlterer.swift
//  Alter
//
//  Created by Nayanda Haberty on 24/11/20.
//

import Foundation

/// Protocol for type converter from any value to any codable
public protocol TypeAlterer {
    associatedtype Value
    associatedtype AlteredValue: Codable
    
    /// Method to convert Value into the Codable one
    /// - Parameter value: Real Value
    func alter(value: Value) -> AlteredValue
    
    /// Method to convert AlteredValue into the real value
    /// - Parameter value: Codable AlteredValue
    func alterBack(value: AlteredValue) -> Value
}

public extension TypeAlterer {
    /// optional version of TypeAlterer
    var optionally: OptionalAlterer<Self> {
        .init(alterer: self)
    }
    
    /// array version of TypeAlterer
    var forArray: ArrayAlterer<Self> {
        .init(alterer: self)
    }
}

public struct UnixLongDateAlterer: TypeAlterer {
    public typealias Value = Date
    public typealias AlteredValue = Int64
    
    public enum Unit {
        case milisecond
        case second
        
        var multiplier: Double {
            self == .milisecond ? 1000 : 1
        }
    }
    
    public let unit: Unit
    
    public init(unit: Unit = .second) {
        self.unit = unit
    }
    
    public func alter(value: Date) -> Int64 {
        .init(value.timeIntervalSince1970 * unit.multiplier)
    }
    
    public func alterBack(value: Int64) -> Date {
        .init(timeIntervalSince1970: .init(integerLiteral: value) / unit.multiplier)
    }
}

public struct StringDateAlterer: TypeAlterer {
    public typealias Value = Date
    public typealias AlteredValue = String
    
    public let pattern: String
    public var formatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = pattern
        return formatter
    }
    
    public init(pattern: String) {
        self.pattern = pattern
    }
    
    public func alter(value: Date) -> String {
        formatter.string(from: value)
    }
    
    public func alterBack(value: String) -> Date {
        formatter.date(from: value) ?? .distantPast
    }
    
}

public struct Base64DataAlterer: TypeAlterer {
    public typealias Value = Data
    public typealias AlteredValue = String
    
    public init() { }
    
    public func alter(value: Data) -> String {
        value.base64EncodedString()
    }
    
    public func alterBack(value: String) -> Data {
        Data(base64Encoded: value) ?? .init()
    }
}

public struct Base64ImageAlterer: TypeAlterer {
    public typealias Value = UIImage
    public typealias AlteredValue = String
    
    public enum Format {
        case jpeg(quality: CGFloat)
        case png
    }
    
    var format: Format
    
    var base64DataAlterer: Base64DataAlterer = .init()
    
    public init(format: Format = .jpeg(quality: 1)) {
        self.format = format
    }
    
    public func alter(value: UIImage) -> String {
        let data: Data
        switch format {
        case .jpeg(let quality):
            data = value.jpegData(compressionQuality: quality) ?? .init()
        case .png:
            data = value.pngData() ?? .init()
        }
        return base64DataAlterer.alter(value: data)
    }
    
    public func alterBack(value: String) -> UIImage {
        UIImage(data: base64DataAlterer.alterBack(value: value)) ?? .init()
    }
}

public struct OptionalAlterer<Alterer: TypeAlterer>: TypeAlterer {
    public typealias Value = Alterer.Value?
    public typealias AlteredValue = Alterer.AlteredValue?
    
    var alterer: Alterer
    
    public init(alterer: Alterer) {
        self.alterer = alterer
    }
    
    public func alter(value: Value) -> AlteredValue {
        guard let value: Alterer.Value = value else { return nil }
        return alterer.alter(value: value)
    }
    
    public func alterBack(value: AlteredValue) -> Value {
        guard let realValue: Alterer.AlteredValue = value else { return nil }
        return alterer.alterBack(value: realValue)
    }
}

public struct ArrayAlterer<Alterer: TypeAlterer>: TypeAlterer {
    public typealias Value = [Alterer.Value]
    public typealias AlteredValue = [Alterer.AlteredValue]
    
    var alterer: Alterer
    
    public init(alterer: Alterer) {
        self.alterer = alterer
    }
    
    public func alter(value: Value) -> AlteredValue {
        var result: AlteredValue = []
        for element in value {
            result.append(alterer.alter(value: element))
        }
        return result
    }
    
    public func alterBack(value: AlteredValue) -> Value {
        var result: Value = []
        for element in value {
            result.append(alterer.alterBack(value: element))
        }
        return result
    }
}
