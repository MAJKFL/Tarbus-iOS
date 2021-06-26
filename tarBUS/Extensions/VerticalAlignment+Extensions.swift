//
//  VerticalAlignment+Extensions.swift
//  tarBUS
//
//  Created by Kuba Florek on 26/06/2021.
//

import SwiftUI

extension VerticalAlignment {
    enum MidFilteredBusesAndButton: AlignmentID {
        static func defaultValue(in d: ViewDimensions) -> CGFloat {
            d[.top]
        }
    }

    static let midFilteredBusesAndButton = VerticalAlignment(MidFilteredBusesAndButton.self)
}
