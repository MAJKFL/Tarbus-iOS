//
//  CompanyViewModel.swift
//  tarBUS
//
//  Created by Jakub Florek on 29/10/2021.
//

import Foundation

class SelectedCompaniesViewModel: ObservableObject {
    @Published private(set) var versions = [CompanyVersion]()
    
    let defaults = UserDefaults(suiteName: DataBaseHelper.groupName)
    
    static let saveKey = "selectedCompanyVersionsViewModel"

    init() {
        fetch()
    }
    
    func fetch() {
        if let data = defaults?.data(forKey: Self.saveKey) {
            if let decoded = try? JSONDecoder().decode([CompanyVersion].self, from: data) {
                self.versions = decoded
                return
            }
        }

        self.versions = []
    }
    
    func add(_ company: CompanyVersion) {
        versions.removeAll(where: { $0.id == company.id })
        versions.append(company)
        save()
    }
    
    func remove(id: String) {
        versions.removeAll(where: { $0.id == id })
        save()
    }
    
    func move(from source: IndexSet, to destination: Int) {
        versions.move(fromOffsets: source, toOffset: destination)
        save()
    }
    
    private func save() {
        if let encoded = try? JSONEncoder().encode(versions) {
            defaults?.set(encoded, forKey: Self.saveKey)
        }
    }
}
