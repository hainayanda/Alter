//
//  AlterableThing.swift
//  Alter_Tests
//
//  Created by Nayanda Haberty on 17/12/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import Alter

protocol AlterableThing: MutableAlterable {
    var id: Int { get set }
    var userName: String { get set }
    var firstName: String { get set }
    var lastName: String? { get set }
    var birthDate: Date? { get set }
    var lastAccessedTime: Date { get set }
    var trackedAccessedTime: [Date] { get set }
    var relatedData: Data { get set }
    var address: String { get set }
    var item: NestedAlterableItem? { get set }
}

extension AlterableThing where Self: Equatable {
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        guard lhs.id == rhs.id && lhs.userName == rhs.userName
                && lhs.firstName == rhs.firstName && lhs.lastName == rhs.lastName
                // maximum error is should be less than a milisecond
                // since lastAccessedTime is in milisecond unit
                && abs(lhs.lastAccessedTime.timeIntervalSince1970 - rhs.lastAccessedTime.timeIntervalSince1970) < 0.001
                && lhs.address == rhs.address && lhs.relatedData == rhs.relatedData
                && lhs.item == rhs.item else {
            return false
        }
        guard lhs.trackedAccessedTime.count == rhs.trackedAccessedTime.count else {
            return false
        }
        for lhsTime in lhs.trackedAccessedTime.enumerated() {
            // maximum error is should be less than a second
            // since lastAccessedTime is in second unit
            guard abs(lhsTime.element.timeIntervalSince1970 - rhs.trackedAccessedTime[lhsTime.offset].timeIntervalSince1970) < 1 else {
                return false
            }
        }
        guard let lhsBirthDate = lhs.birthDate, let rhsBirthDate = rhs.birthDate else {
            return lhs.birthDate == rhs.birthDate
        }
        // maximum error is should be less than a day
        // since the birth date is in string format which smallest time unit is day
        return abs(lhsBirthDate.timeIntervalSince1970 - rhsBirthDate.timeIntervalSince1970) < 86400
    }
}

extension AlterableThing {
    static func randomize() -> Self {
        var random = Self.init()
        random.id = .random(in: 100000000..<999999999)
        random.userName = .random()
        random.firstName = .random(componentsOf: .alphabet)
        random.lastName = .random(componentsOf: .alphabet)
        random.birthDate = .random(from: .init(timeIntervalSince1970: 315576000), to: .init(timeIntervalSince1970: 946728000))
        random.lastAccessedTime = .init()
        random.relatedData = .random()
        random.trackedAccessedTime = [random.lastAccessedTime] + .random(maxCount: 20, from: .init(timeIntervalSince1970: 1606780800), to: .init())
        random.address = .random(componentsOf: .commonSentencesCharacters, length: .random(in: 100..<1000))
        random.item = .random()
        return random
    }
}

// MARK: JSON

class NestedAlterableItem: Alterable, Equatable {
    @Mapped
    var itemId: Int = -1
    
    @Mapped
    var itemName: String = ""
    
    @Mapped
    var itemPrice: Double = -1
    
    required init() { }
    
    static func == (lhs: NestedAlterableItem, rhs: NestedAlterableItem) -> Bool {
        rhs.itemId == lhs.itemId && rhs.itemName == lhs.itemName && rhs.itemPrice == lhs.itemPrice
    }
    
    static func random() -> NestedAlterableItem {
        let random = NestedAlterableItem()
        random.itemId = .random(in: 100000000..<999999999)
        random.itemName = .random()
        random.itemPrice = round(Double.random(in: 100000000..<999999999))
        return random
    }
}

struct ManualKeyedAlterable: AlterableThing, Equatable {
    
    var decodeStrategy: DecodeStrategy { .throwErrorOnUnknownKey }
    
    @Mapped(key: "identifier")
    var id: Int = -1
    
    @Mapped(key: "user_name")
    var userName: String = ""
    
    @Mapped(key: "first_name")
    var firstName: String = ""
    
    @Mapped(key: "last_name")
    var lastName: String? = nil
    
    @AlterMapped(key: "birth_date", alterer: StringDateAlterer(pattern: "yyyy-MMM-dd").optionally)
    var birthDate: Date? = nil
    
    @AlterMapped(key: "last_accessed_time", alterer: UnixLongDateAlterer(unit: .milisecond))
    var lastAccessedTime: Date = .init()
    
    @AlterMapped(key: "related_data", alterer: Base64DataAlterer())
    var relatedData: Data = .init()
    
    @AlterMapped(key: "tracked_accessed_time", alterer: UnixLongDateAlterer().forArray)
    var trackedAccessedTime: [Date] = []
    
    var item: NestedAlterableItem? = nil
    
    var address: String = ""
    
    init() { }
    
    init(from decoder: Decoder) throws {
        self.init()
        let container = try decodeMappedProperties(from: decoder)
        address = try container.decode(forKey: "address")
        item = try container.decode(forKey: "item")
    }
    
    func encode(to encoder: Encoder) throws {
        var container = try encodeMappedProperties(to: encoder)
        try container.encode(value: address, forKey: "address")
        try container.encode(value: item, forKey: "item")
    }
}

struct AutoKeyedAlterable: AlterableThing, Equatable {
    
    var decodeStrategy: DecodeStrategy { .throwErrorOnUnknownKey }
    
    @Mapped(key: "identifier")
    var id: Int = -1
    
    @Mapped(key: "user_name")
    var userName: String = ""
    
    @Mapped(key: "first_name")
    var firstName: String = ""
    
    @Mapped(key: "last_name")
    var lastName: String? = nil
    
    @AlterMapped(key: "birth_date", alterer: StringDateAlterer(pattern: "yyyy-MMM-dd").optionally)
    var birthDate: Date? = nil
    
    @AlterMapped(key: "last_accessed_time", alterer: UnixLongDateAlterer(unit: .milisecond))
    var lastAccessedTime: Date = .init()
    
    @AlterMapped(key: "related_data", alterer: Base64DataAlterer())
    var relatedData: Data = .init()
    
    @AlterMapped(key: "tracked_accessed_time", alterer: UnixLongDateAlterer().forArray)
    var trackedAccessedTime: [Date] = []
    
    @Mapped
    var address: String = ""
    
    @Mapped
    var item: NestedAlterableItem? = nil
}

struct AutoAlterable: AlterableThing, Equatable {
    
    var decodeStrategy: DecodeStrategy { .throwErrorOnUnknownKey }
    
    @Mapped
    var id: Int = -1
    
    @Mapped
    var userName: String = ""
    
    @Mapped
    var firstName: String = ""
    
    @Mapped
    var lastName: String? = nil
    
    @AlterMapped(alterer: StringDateAlterer(pattern: "yyyy-MMM-dd").optionally)
    var birthDate: Date? = nil
    
    @AlterMapped(alterer: UnixLongDateAlterer(unit: .milisecond))
    var lastAccessedTime: Date = .init()
    
    @AlterMapped(alterer: Base64DataAlterer())
    var relatedData: Data = .init()
    
    @AlterMapped(alterer: UnixLongDateAlterer().forArray)
    var trackedAccessedTime: [Date] = []
    
    @Mapped
    var address: String = ""
    
    @Mapped
    var item: NestedAlterableItem? = nil
}
