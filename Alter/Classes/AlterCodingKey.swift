//
//  AlterCodingKey.swift
//  Alter
//
//  Created by Nayanda Haberty on 24/11/20.
//

import Foundation

public struct AlterCodingKey: CodingKey {
    
    public var stringValue: String
    
    public var intValue: Int?
    
    public init(stringValue: String) {
        self.stringValue = stringValue
    }
    
    public init(intValue: Int) {
        self.stringValue = "\(intValue)"
        self.intValue = intValue
    }
}
