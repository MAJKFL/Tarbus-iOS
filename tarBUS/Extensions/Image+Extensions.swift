//
//  Image+Extensions.swift
//  tarBUS
//
//  Created by Kuba Florek on 26/06/2021.
//

import SwiftUI

extension Image {
    func busStopLabel() -> some View {
        self
            .resizable()
            .scaledToFit()
            .frame(minWidth: 15)
    }
}
