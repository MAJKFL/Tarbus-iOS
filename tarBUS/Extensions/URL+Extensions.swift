//
//  URL+Extensions.swift
//  tarBUS
//
//  Created by Jakub Florek on 12/11/2021.
//

import Foundation

extension URL {
    func valueOf(_ queryParamaterName: String) -> String? {
        guard let url = URLComponents(string: self.absoluteString) else { return nil }
        return url.queryItems?.first(where: { $0.name == queryParamaterName })?.value
    }
}

extension URL: Identifiable {
    public var id: String {
        self.absoluteString
    }
}
