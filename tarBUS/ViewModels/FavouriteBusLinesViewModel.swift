//
//  FavouriteBusLinesViewModel.swift
//  tarBUS
//
//  Created by Kuba Florek on 10/02/2021.
//

import Foundation

class FavouriteBusLinesViewModel: ObservableObject {
    @Published private(set) var busLines = [BusLine]()
    static let saveKey = "favouriteBusLines"

    init() {
        fetch()
    }
    
    func fetch() {
        if let data = UserDefaults.standard.data(forKey: Self.saveKey) {
            if let decoded = try? JSONDecoder().decode([BusLine].self, from: data) {
                self.busLines = decoded
                return
            }
        }

        self.busLines = []
    }
    
    func add(_ busLine: BusLine) {
        busLines.append(busLine)
        save()
    }
    
    func remove(atOffsets: IndexSet) {
        busLines.remove(atOffsets: atOffsets)
        save()
    }
    
    func remove(id: Int) {
        busLines.removeAll(where: { $0.id == id })
        save()
    }
    
    func move(from source: IndexSet, to destination: Int) {
        busLines.move(fromOffsets: source, toOffset: destination)
        save()
    }
    
    private func save() {
        if let encoded = try? JSONEncoder().encode(busLines) {
            UserDefaults.standard.set(encoded, forKey: Self.saveKey)
        }
    }
}
