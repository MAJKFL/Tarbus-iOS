//
//  SKStoreReviewController+extensions.swift
//  tarBUS
//
//  Created by Kuba Florek on 24/05/2021.
//

import Foundation
import StoreKit

extension SKStoreReviewController {
    public static func requestReviewInCurrentScene() {
        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            requestReview(in: scene)
        }
    }
}
