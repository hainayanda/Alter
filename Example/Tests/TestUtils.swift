//
//  TestUtils.swift
//  Alter_Tests
//
//  Created by Nayanda Haberty on 04/12/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation

extension Date {
    static func random(from: Date = .distantPast, to date: Date = .distantFuture) -> Date {
        let interval = date.timeIntervalSince(from)
        let randomInterval: TimeInterval = .random(in: 0..<interval)
        return .init(timeInterval: randomInterval, since: from)
    }
}

extension Array where Element == Date {
    static func random(maxCount: Int = 10, from: Date = .distantPast, to date: Date = .distantFuture) -> [Date] {
        let count = Int.random(in: 1..<maxCount)
        var array: [Date] = []
        for _ in 0..<count {
            array.append(.random(from: from, to: date))
        }
        return array
    }
}

extension Data {
    static func random(maxSize: Int = 1024) -> Data {
        let count = Int.random(in: 0..<maxSize)
        var array: [UInt8] = []
        for _ in 0..<count {
            array.append(.random(in: 0..<255))
        }
        return .init(bytes: array)
    }
}

extension Array where Element == Int64 {
    func stringify() -> String {
        var string = "["
        for element in self {
            string = "\(string)\(element),"
        }
        return string.replacingOccurrences(of: ",$", with: "", options: .regularExpression, range: nil) + "]"
    }
}

extension String {
    static var commonSentencesCharacters: String {
        "\(alphaNumeric)\(space)\(punctuation)"
    }
    static var alphaNumeric: String {
        "\(alphabet)\(number)"
    }
    static var alphabet: String {
        "\(lowerCaseAlphabet)\(upperCaseAlphabet)"
    }
    static var upperCaseAlphabet: String {
        "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    }
    static var lowerCaseAlphabet: String {
        "abcdefghijklmnopqrstuvwxyz"
    }
    static var number: String {
        "0123456789"
    }
    static var space: String {
        " "
    }
    static var punctuation: String {
        ".,!?"
    }
    static func random(componentsOf letters: String = .alphaNumeric, length: Int = 10) -> String {
        .init((0..<length).map{ _ in letters.randomElement()! })
    }
}
