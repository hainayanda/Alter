//
//  AlterError.swift
//  Alter
//
//  Created by Nayanda Haberty on 09/12/20.
//

import Foundation

struct AlterError: LocalizedError {
    let errorDescription: String?
    let failureReason: String?
    
    init(errorDescription: String, failureReason: String? = nil) {
        self.errorDescription = errorDescription
        self.failureReason = failureReason
    }
}

extension AlterError {
    static func whenEncode<Decoded>(type: Decoded.Type, reason: String? = nil) -> AlterError {
        .init(
            errorDescription: "Alter Error: fail when encode \(String(describing: type))",
            failureReason: reason
        )
    }
    
    static func whenDecode<Encoded>(type: Encoded.Type, reason: String? = nil) -> AlterError {
        .init(
            errorDescription: "Alter Error: fail when decode \(String(describing: type))",
            failureReason: reason
        )
    }
    
    static func whenAltering<Origin, Destination>(from type: Origin.Type, into destination: Destination.Type, reason: String? = nil) -> AlterError {
        .init(
            errorDescription: "Alter Error: fail when altering \(String(describing: type)) into \(String(describing: destination))",
            failureReason: reason
        )
    }
    
    static func whenSet<Property>(into type: Property.Type, reason: String? = nil) -> AlterError {
        .init(
            errorDescription: "Alter Error: fail when try set value with type \(String(describing: type))",
            failureReason: reason
        )
    }
}
