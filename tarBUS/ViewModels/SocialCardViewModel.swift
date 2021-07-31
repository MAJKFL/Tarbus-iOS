//
//  SocialCardViewModel.swift
//  tarBUS
//
//  Created by Kuba Florek on 31/07/2021.
//

import Foundation

struct SocialCardViewModel: Identifiable {
    let id = UUID()
    let imageName: String
    let title: String
    let text: String
    let urlString: String
    
    var url: URL? {
        URL(string: urlString)
    }
}
