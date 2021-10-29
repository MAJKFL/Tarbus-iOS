//
//  Companies.swift
//  tarBUS
//
//  Created by Jakub Florek on 29/10/2021.
//

import Foundation

struct Companies: Codable {
    let note: String
    let versions: [Company]
}

struct Company: Codable, Identifiable {
    let companyName: String
    let subscribeCode: String
    let validationDate: Int
    let avatarSrc: String
    
    var id: String { subscribeCode }
    
    var imgURL: URL? { URL(string: avatarSrc) }
}
