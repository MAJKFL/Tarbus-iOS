//
//  Array+extensions.swift
//  tarBUS
//
//  Created by Kuba Florek on 08/02/2021.
//

import Foundation

extension Array where Element: Equatable {
    func removeDuplicates() -> [Element] {
        var result = [Element]()

        for value in self {
            if result.contains(value) == false {
                result.append(value)
            }
        }

        return result
    }
}
