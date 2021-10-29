//
//  CompanyViewModel.swift
//  tarBUS
//
//  Created by Jakub Florek on 29/10/2021.
//

import Foundation

class SelectedCompaniesViewModel: ObservableObject {
    @Published private(set) var companies = [Company]()
    
    let defaults = UserDefaults(suiteName: DataBaseHelper.groupName)
    
    static let saveKey = "selectedCompaniewViewModel"

    init() {
        fetch()
    }
    
    func fetch() {
        if let data = defaults?.data(forKey: Self.saveKey) {
            if let decoded = try? JSONDecoder().decode([Company].self, from: data) {
                self.companies = decoded
                return
            }
        }

        self.companies = []
    }
    
    func add(_ company: Company) {
        companies.removeAll(where: { $0.id == company.id })
        companies.append(company)
        save()
    }
    
    func remove(id: String) {
        companies.removeAll(where: { $0.id == id })
        save()
    }
    
    func move(from source: IndexSet, to destination: Int) {
        companies.move(fromOffsets: source, toOffset: destination)
        save()
    }
    
    private func save() {
        if let encoded = try? JSONEncoder().encode(companies) {
            defaults?.set(encoded, forKey: Self.saveKey)
        }
    }
}
