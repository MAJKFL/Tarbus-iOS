//
//  tarBUSApp.swift
//  tarBUS
//
//  Created by Kuba Florek on 13/01/2021.
//

import SwiftUI
import CoreData

@main
struct tarBUSApp: App {
    let context = PersistentCloudKitContainer.persistentContainer.newBackgroundContext()
    
    var body: some Scene {
        WindowGroup {
            WelcomeView().environment(\.managedObjectContext, context)
                .onAppear {
                    fetchData()
                }
        }
    }
    
    func fetchData() {
        let url = URL(string: "https://dpajak99.github.io/tarbus-api/tarbus2.json")!
        let request = URLRequest(url: url)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                do {
                    if let anyObject = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions()) as? [AnyObject] {
                        let dispatchQueue = DispatchQueue(label: "QueueIdentification", qos: .background)
                        
                        dispatchQueue.async {
                        for object in anyObject {
                            let array = object["data"] as? [AnyObject]
                            
                            switch object["name"] as? String {
                                case "BusLine":
                                    clearDeepObjectEntity("BusLine")
                                    for element in array! {
                                        let newBusLine = BusLine(context: context)
                                        newBusLine.busLineId = Int16(element["bus_line_id"] as? String ?? "") ?? 0
                                        newBusLine.busLineName = element["bus_line_name"] as? String ?? ""
                                        try? context.save()
                                    }
                                case "BusStop":
                                    clearDeepObjectEntity("BusStop")
                                    for element in array! {
                                        let newBusStop = BusStop(context: context)
                                        newBusStop.busStopNumber = Int16(element["bus_stop_number"] as? String ?? "") ?? 0
                                        newBusStop.busStopName = element["bus_stop_name"] as? String ?? ""
                                        newBusStop.busStopSearchName = element["bus_stop_search_name"] as? String ?? ""
                                        newBusStop.busStopType = element["bus_stop_type"] as? String ?? ""
                                        newBusStop.isCity = (Int(element["is_city"] as? String ?? "") ?? 0).boolValue
                                        try? context.save()
                                    }
                                case "DayType":
                                    clearDeepObjectEntity("DayType")
                                    for element in array! {
                                        let newDayType = DayType(context: context)
                                        newDayType.idDayType = Int16(element["id_day_type"] as? String ?? "") ?? 0
                                        newDayType.name = element["name"] as? String ?? ""
                                        try? context.save()
                                    }
                                case "Departure":
                                    clearDeepObjectEntity("Departure")
                                    for element in array! {
                                        let newDeparture = Departure(context: context)
                                        newDeparture.departureId = Int16(element["departure_id"] as? String ?? "") ?? 0
                                        newDeparture.departureBusStopNumber = Int16(element["departure_bus_stop_number"] as? String ?? "") ?? 0
                                        newDeparture.departureTrackId = element["departure_track_id"] as? String ?? ""
                                        newDeparture.departureBusLineId = Int16(element["departure_bus_line_id"] as? String ?? "") ?? 0
                                        newDeparture.timeInSec = Int16(element["time_in_sec"] as? String ?? "") ?? 0
                                        try? context.save()
                                    }
                                case "Destination":
                                    clearDeepObjectEntity("Destination")
                                    for element in array! {
                                        let newDestination = Destination(context: context)
                                        newDestination.destinationId = Int16(element["destination_id"] as? String ?? "") ?? 0
                                        newDestination.destinationName = element["destination_name"] as? String ?? ""
                                        newDestination.destinationShortcut = element["destination_shortcut"] as? String ?? ""
                                        newDestination.descriptionShort = element["desctiption"] as? String ?? ""
                                        newDestination.descriptionLong = element["description_long"] as? String ?? ""
                                        newDestination.destinationBusLineId = Int16(element["destination_bus_line_id"] as? String ?? "") ?? 0
                                        newDestination.lastBusStopNumber = Int16(element["last_bus_stop_number"] as? String ?? "") ?? 0
                                        try? context.save()
                                    }
                                case "IgnoredDestinations":
                                    clearDeepObjectEntity("IgnoredDestinations")
                                    for element in array! {
                                        let newIgnoredDestination = IgnoredDestinations(context: context)
                                        newIgnoredDestination.ignoredDestinationId = Int16(element["ignored_destination_id"] as? String ?? "") ?? 0
                                        newIgnoredDestination.parentDestinationId = Int16(element["parent_destination_id"] as? String ?? "") ?? 0
                                        try? context.save()
                                    }
                                case "Track":
                                    clearDeepObjectEntity("Track")
                                    for element in array! {
                                        let newTrack = Track(context: context)
                                        newTrack.trackId = element["track_id"] as? String ?? ""
                                        newTrack.trackTypes = element["track_types"] as? String ?? ""
                                        newTrack.dayType = Int16(element["day_type"] as? String ?? "") ?? 0
                                        newTrack.destinationStatus = (Int(element["destination_status"] as? String ?? "") ?? 0).boolValue
                                        newTrack.trackDestinationId = Int16(element["track_destination_id"] as? String ?? "") ?? 0
                                        try? context.save()
                                    }
                                default:
                                    print("")
                                }
                            }
                        }
                    }
                } catch {
                    print(error.localizedDescription)
                }
            }
        }.resume()
    }
    
    private func clearDeepObjectEntity(_ entity: String) {
        let context = self.context

        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)

        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            print ("There was an error")
        }
    }
}

extension Int {
    var boolValue: Bool { return self != 0 }
}
