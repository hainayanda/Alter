//
//  Mirror+Extensions.swift
//  Alter
//
//  Created by Nayanda Haberty on 19/12/20.
//

import Foundation

extension Mirror {
    var alterableProperties: [AlterableProperty] {
        var properties = children.compactMap { (label, value) -> AlterableProperty?  in
            guard let label = label,
                  let alterableProperty = value as? AlterableProperty else { return nil }
            prepareProperty(alterableProperty, label: label)
            return alterableProperty
        }
        if let superMirror = superclassMirror {
            properties.append(contentsOf: superMirror.alterableProperties)
        }
        return properties
    }

    func prepareProperty(_ alterableProperty: AlterableProperty, label: String) {
        alterableProperty.key = alterableProperty.key ?? label.replacingOccurrences(
            of: "^_",
            with: "",
            options: .regularExpression,
            range: nil
        )
    }
}
