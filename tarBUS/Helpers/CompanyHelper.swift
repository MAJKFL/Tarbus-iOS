//
//  CarrierVersionHelper.swift
//  tarBUS
//
//  Created by Jakub Florek on 29/10/2021.
//

import Foundation

class CompanyHelper: ObservableObject {
    static var companyURL = URL(string: "https://api.tarbus.pl/static/config/available-versions.json")!
    static var subscribeCodeURL = URL(string: "https://api.tarbus.pl/static/config/database-info.json")!
    
    @Published var companies: Companies?
    
    init() {
        fetchCompanies()
        fetchSubscribeCodes()
    }
    
    func fetchCompanies() {
        let request = URLRequest(url: Self.companyURL)

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
    
    func fetchSubscribeCodes() {
        let request = URLRequest(url: Self.subscribeCodeURL)
        
        let userDefaults = UserDefaults(suiteName: DataBaseHelper.groupName)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                DispatchQueue.main.async {
                    guard let dictionary = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Int] else {
                        return
                    }
                    
                    userDefaults?.set(dictionary, forKey: "SubscribeCodes")
                }
                return
            }
            print("Fetch failed: \(error?.localizedDescription ?? "Unknown error")")
        }.resume()
    }
}
