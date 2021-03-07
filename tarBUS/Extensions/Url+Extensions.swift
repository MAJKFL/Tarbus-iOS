//
//  Url+Extensions.swift
//  tarBUS
//
//  Created by Kuba Florek on 07/03/2021.
//

import Foundation

extension URL {
    func valueOf(_ queryParamaterName: String) -> String? {
        guard let url = URLComponents(string: self.absoluteString) else { return nil }
        return url.queryItems?.first(where: { $0.name == queryParamaterName })?.value
    }
}
