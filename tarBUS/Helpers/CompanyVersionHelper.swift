//
//  CarrierVersionHelper.swift
//  tarBUS
//
//  Created by Jakub Florek on 29/10/2021.
//

import Foundation

class CompanyVersionHelper: ObservableObject {
    static var url = URL(string: "https://api.tarbus.pl/static/config/available-versions.json")!
    var session = URLSession.shared
    
    @Published var companies: Companies?
    
    init() {
        fetchCompanies()
    }
    
    func fetchCompanies() {
        let request = URLRequest(url: Self.url)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                
                DispatchQueue.main.async {
                    self.companies = try? decoder.decode(Companies.self, from: data)
                }
                return
            }
            print("Fetch failed: \(error?.localizedDescription ?? "Unknown error")")
        }.resume()
    }
}
