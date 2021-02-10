//
//  FavouriteBusStopsViewModel.swift
//  tarBUS
//
//  Created by Kuba Florek on 10/02/2021.
//

import Foundation

class FavouriteBusStopsViewModel: ObservableObject {
    @Published private(set) var busStops: [BusStop]
    static let saveKey = "favouriteBusStops"

    init() {
        if let data = UserDefaults.standard.data(forKey: Self.saveKey) {
            if let decoded = try? JSONDecoder().decode([BusStop].self, from: data) {
                self.busStops = decoded
                return
            }
        }

        self.busStops = []
    }
    
    func add(_ busStop: BusStop) {
        busStops.append(busStop)
        save()
    }
    
    func remove(atOffsets: IndexSet) {
        busStops.remove(atOffsets: atOffsets)
        save()
    }
    
    func remove(id: Int) {
        busStops.removeAll(where: { $0.id == id })
        save()
    }
    
    func move(from source: IndexSet, to destination: Int) {
        busStops.move(fromOffsets: source, toOffset: destination)
        save()
    }
    
    func updateBusStopUserName(_ busStop: BusStop, with newName: String) {
        var newBusStops = [BusStop]()
        for bs in busStops {
            if bs.id == busStop.id {
                var newBusStop = bs
                newBusStop.userName = newName
                newBusStops.append(newBusStop)
            }
            newBusStops.append(bs)
        }
        busStops = newBusStops
        save()
    }
    
    private func save() {
        if let encoded = try? JSONEncoder().encode(busStops) {
            UserDefaults.standard.set(encoded, forKey: Self.saveKey)
        }
    }
}

