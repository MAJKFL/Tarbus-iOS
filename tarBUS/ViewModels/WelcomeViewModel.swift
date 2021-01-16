//
//  WelcomeViewModel.swift
//  tarBUS
//
//  Created by Kuba Florek on 13/01/2021.
//

import Foundation
import Combine

class WelcomeViewModel: ObservableObject {
    @Published var message: Message?
    @Published var lastUpdate: LastUpdate?
    
    func fetchMessage() {
        let url = URL(string: "https://dpajak99.github.io/tarbus-api/message.json")!
        let request = URLRequest(url: url)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                if let decodedResponse = try? JSONDecoder().decode(Message.self, from: data) {
                    DispatchQueue.main.async {
                        self.message = decodedResponse
                    }
                    return
                }
            }
            print("Fetch failed: \(error?.localizedDescription ?? "Unknown error")")
        }.resume()
    }
    
    func fetchLastUpdate() {
        let url = URL(string: "https://dpajak99.github.io/tarbus-api/last-update2.json")!
        let request = URLRequest(url: url)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                if let decodedResponse = try? JSONDecoder().decode(LastUpdate.self, from: data) {
                    DispatchQueue.main.async {
                        self.lastUpdate = decodedResponse
                    }
                    return
                }
            }
            print("Fetch failed: \(error?.localizedDescription ?? "Unknown error")")
        }.resume()
    }
}
