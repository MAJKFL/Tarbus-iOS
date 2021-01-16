//
//  RouteListViewModel.swift
//  tarBUS
//
//  Created by Kuba Florek on 13/01/2021.
//

import Foundation

class RouteListViewModel: ObservableObject {
    
    func fetchBusLineTable() {
        let url = URL(string: "https://dpajak99.github.io/tarbus-api/tarbus2.json")!
        let request = URLRequest(url: url)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                do {
                    if let anyObject = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions()) as? [AnyObject] {
                        for object in anyObject {
                            let array = object["data"] as? [AnyObject]
                            
                            switch object["name"] as? String {
                            case "BusLine":
                                for element in array! {
                                    print(Int(element["bus_line_id"] as? String ?? "") ?? 0)
                                    print(element["bus_line_name"] as? String ?? "")
                                }
                            case "BusStop":
                                for element in array! {
                                    print(Int(element["bus_stop_number"] as? String ?? "") ?? 0)
                                    print(element["bus_stop_name"] as? String ?? "")
                                    print(element["bus_stop_search_name"] as? String ?? "")
                                    print(element["bus_stop_type"] as? String ?? "")
                                    print(element["is_city"] as? String ?? "") // Konwertuj na bool
                                }
                            case "DayType":
                                for element in array! {
                                    print(Int(element["id_day_type"] as? String ?? "") ?? 0)
                                    print(element["name"] as? String ?? "")
                                }
                            case "Departure":
                                for element in array! {
                                    print(Int(element["departure_id"] as? String ?? "") ?? 0)
                                    print(Int(element["departure_bus_stop_number"] as? String ?? "") ?? 0)
                                    print(element["departure_track_id"] as? String ?? "") // Przekonwertuj na range
                                    print(Int(element["departure_bus_line_id"] as? String ?? "") ?? 0)
                                    print(Int(element["time_in_sec"] as? String ?? "") ?? 0)
                                }
                            case "Destination":
                                for element in array! {
                                    print(Int(element["destination_id"] as? String ?? "") ?? 0)
                                    print(element["destination_name"] as? String ?? "")
                                    print(element["destination_shortcut"] as? String ?? "")
                                    print(element["desctiption"] as? String ?? "")
                                    print(element["description_long"] as? String ?? "")
                                    print(Int(element["destination_bus_line_id"] as? String ?? "") ?? 0)
                                    print(Int(element["last_bus_stop_number"] as? String ?? "") ?? 0)
                                }
                            case "IgnoredDestinations":
                                for element in array! {
                                    print(Int(element["ignored_destination_id"] as? String ?? "") ?? 0)
                                    print(Int(element["parent_destination_id"] as? String ?? "") ?? 0)
                                }
                            case "Track":
                                for element in array! {
                                    print(element["track_id"] as? String ?? "") // Przekonwertuj na range
                                    print(element["track_types"] as? String ?? "")
                                    print(Int(element["day_type"] as? String ?? "") ?? 0)
                                    print(element["destination_status"] as? String ?? "") // Konwertuj na bool
                                    print(Int(element["track_destination_id"] as? String ?? "") ?? 0)
                                }
                            default:
                                print("")
                            }
                        }
                    }
                } catch {
                    print(error.localizedDescription)
                }
            }
        }.resume()
    }
}

extension Int {
    var boolValue: Bool { return self != 0 }
}
