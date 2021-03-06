//
//  DatabaseHelper.swift
//  tarBUS
//
//  Created by Kuba Florek on 23/01/2021.
//

import SQLite
import Foundation
import WidgetKit

enum InternetConnectivityError: Error {
    case noInternetConnection
}

class DataBaseHelper: ObservableObject {
    static let tableNames = ["BusStop", "Departure", "BusLine", "Calendar", "Destinations", "Track", "AlertHistory", "RouteConnections", "LastUpdated", "BusStopConnection", "LastUpdated", "Route"]
    static let databaseFileName = "tarbus.db"
    static let groupName = "group.florekjakub.tarBUSapp"
    
    func fetchData() {
        let url = URL(string: "https://dpajak99.github.io/tarbus-api/v2-1-3/database.json")!
        let request = URLRequest(url: url)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                self.deleteAllData()
                do {
                    if let anyObject = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions()) as? [AnyObject] {
                        let fileManager = FileManager.default
                        let documentsUrl = fileManager.containerURL(forSecurityApplicationGroupIdentifier: Self.groupName)!
                        let url = documentsUrl.appendingPathComponent(Self.databaseFileName)
                        let db = try! Connection(url.absoluteString)
                        for object in anyObject {
                            if (object["type"] as? String) ?? "" == "table" {
                                let array = object["data"] as! [AnyObject]
                                if array.count == 0 { continue }
                                let allKeys = array[0].allKeys as! [String]
                                var keys = ""
                                for key in allKeys {
                                    keys += "\(key), "
                                }
                                keys.removeLast(2)
                                var sqlStatement = "INSERT INTO \(object["name"] as! String) (\(keys)) VALUES "
                                for element in array {
                                    var string = "("
                                    for key in allKeys {
                                        let value = (element[key] as? String) ?? "NULL"
                                        if let value = Int(value) {
                                            string += "\(value), "
                                        } else {
                                            string += "'\(value)', "
                                        }
                                    }
                                    string.removeLast(2)
                                    string += "),"
                                    sqlStatement += string
                                }
                                sqlStatement.removeLast()
                                sqlStatement += ";"
                                do {
                                    let statement = try db.prepare(sqlStatement)
                                    let _ = try statement.run()
                                } catch {
                                    print(error.localizedDescription)
                                }
                                WidgetCenter.shared.reloadAllTimelines()
                            }
                        }
                    }
                } catch {
                    print(error.localizedDescription)
                }
            }
        }.resume()
    }
    
    func deleteAllData() {
        let fileManager = FileManager.default
        let documentsUrl = fileManager.containerURL(forSecurityApplicationGroupIdentifier: Self.groupName)!
        let url = documentsUrl.appendingPathComponent(Self.databaseFileName)
        let db = try! Connection(url.absoluteString)
        
        for tableName in Self.tableNames {
            do {
                let statement = try db.prepare("DELETE FROM \(tableName)")
                let _ = try statement.run()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func copyDatabaseIfNeeded() {
        // Move database file from bundle to documents folder
        
        let fileManager = FileManager.default
        
        let documentsUrl = fileManager.containerURL(forSecurityApplicationGroupIdentifier: Self.groupName)!
        
        let finalDatabaseURL = documentsUrl.appendingPathComponent(Self.databaseFileName)
    
        if !( (try? finalDatabaseURL.checkResourceIsReachable()) ?? false){
            print("DB does not exist in documents folder")
            
            let fileURLs = try? FileManager.default.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            
            for fileURL in fileURLs ?? [] {
                let stringPath = Bundle.main.path(forResource: "tarbus", ofType: "db")!
                if fileManager.contentsEqual(atPath: fileURL.absoluteString, andPath: stringPath) {
                    return
                } else {
                    try? fileManager.removeItem(atPath: fileURL.absoluteString)
                }
            }
            
            let documentsURL = Bundle.main.resourceURL?.appendingPathComponent(Self.databaseFileName)
            
            do {
                  try fileManager.copyItem(atPath: (documentsURL?.path)!, toPath: finalDatabaseURL.path)
                  } catch let error as NSError {
                    print("Couldn't copy file to final location! Error:\(error.description)")
            }

        } else {
            print("Database file found at path: \(finalDatabaseURL.path)")
        }
    
    }
    
    func getBusLines() -> [BusLine] {
        var busLines = [BusLine]()
        
        let fileManager = FileManager.default
        let documentsUrl = fileManager.containerURL(forSecurityApplicationGroupIdentifier: Self.groupName)!
        let url = documentsUrl.appendingPathComponent(Self.databaseFileName)
        let db = try! Connection(url.absoluteString)
        
        do {
            for row in try db.prepare("SELECT * FROM BusLine;") {
                let id: Int64 = Optional(row[0]) as! Int64
                let name: String = Optional(row[1]) as! String
                let newBusLine = BusLine(id: Int(id), name: name)
                busLines.append(newBusLine)
            }
        } catch {
            print(error.localizedDescription)
        }
        
        return busLines
    }
    
    func getRoutes(busLineId: Int) -> [Route] {
        var routes = [Route]()
        
        let fileManager = FileManager.default
        let documentsUrl = fileManager.containerURL(forSecurityApplicationGroupIdentifier: Self.groupName)!
        let url = documentsUrl.appendingPathComponent(Self.databaseFileName)
        let db = try! Connection(url.absoluteString)
        
        do {
            for row in try db.prepare("SELECT * FROM Route WHERE Route.r_bus_line_id = \(busLineId)") {
                let id: Int64 = Optional(row[0]) as! Int64
                let name: String = Optional(row[1]) as! String
                let busLineId = Optional(row[2]) as! Int64
                let description = Optional(row[3]) as! String
                let newRoute = Route(id: Int(id), destinationName: name, busLineId: Int(busLineId), description: description)
                routes.append(newRoute)
            }
        } catch {
            print(error.localizedDescription)
        }
        
        return routes
    }
    
    func getBusStops(routeId: Int) -> [BusStop] {
        var busStops = [BusStop]()
        
        let fileManager = FileManager.default
        let documentsUrl = fileManager.containerURL(forSecurityApplicationGroupIdentifier: Self.groupName)!
        let url = documentsUrl.appendingPathComponent(Self.databaseFileName)
        let db = try! Connection(url.absoluteString)
        
        do {
            for row in try db.prepare("SELECT * FROM RouteConnections JOIN BusStop ON BusStop.bs_id = RouteConnections.rc_bus_stop_id WHERE RouteConnections.rc_route_id = \(routeId) ORDER BY rc_lp") {
                let id = Optional(row[5]) as! Int64
                let searchName = Optional(row[6]) as! String
                let name = Optional(row[7]) as! String
                let longitude = Optional(row[8]) as! Double
                let latitutde = Optional(row[9]) as! Double
                let destinations = Optional(row[10]) as! String
                let newBusStop = BusStop(id: Int(id), name: name, searchName: searchName, longitude: longitude, latitude: latitutde, destination: destinations)
                busStops.append(newBusStop)
            }
        } catch {
            print(error)
        }
        
        return busStops
    }
    
    func getNextDepartures(busStopId: Int, dayTypes: String, startFromTime: Int) -> [NextDeparture] {
        var departures = [NextDeparture]()
        
        let fileManager = FileManager.default
        let documentsUrl = fileManager.containerURL(forSecurityApplicationGroupIdentifier: Self.groupName)!
        let url = documentsUrl.appendingPathComponent(Self.databaseFileName)
        let db = try! Connection(url.absoluteString)
        
        let strArray = dayTypes.components(separatedBy: " ")
        
        var dayTypesQuery = ""
        
        for element in strArray {
            dayTypesQuery += "instr(Track.t_day_types, '\(element)') OR "
        }
        
        dayTypesQuery.removeLast(4)
        
        do {
            for row in try db.prepare("""
                SELECT * FROM Departure
                    JOIN BusStop ON BusStop.bs_id = Departure.d_bus_stop_id
                    JOIN Track ON Departure.d_track_id = Track.t_id
                    JOIN BusLine ON BusLine.bl_id = Departure.d_bus_line_id
                    JOIN Route ON Track.t_route_id = Route.r_id
                    JOIN Destinations ON Departure.d_symbols = Destinations.ds_symbol AND Destinations.ds_route_id = Route.r_id
                    WHERE Departure.d_bus_stop_id = \(busStopId)
                    AND (\(dayTypesQuery))
                    AND Departure.d_time_in_min > \(startFromTime)
                    ORDER BY d_time_in_min
                """) {
                let id = Optional(row[0]) as! Int64
                let trackId = Optional(row[2]) as! String
                let timeString = Optional(row[6]) as! String
                let timeInt = Optional(row[5]) as! Int64
                let busLineId = Optional(row[19]) as! Int64
                let busLineName = Optional(row[20]) as! String
                let boardName = Optional(row[28]) as! String
                
                let newBusLine = BusLine(id: Int(busLineId), name: busLineName)
                
                let newDeparture = NextDeparture(id: Int(id), trackId: trackId, timeString: timeString, timeInt: Int(timeInt), boardName: boardName, busLine: newBusLine)
                departures.append(newDeparture)
            }
        } catch {
            print(error)
        }
        
        return departures
    }
    
    func getDeparturesByRouteAndDay(dayTypesQuery: String, routeId: Int, busStopId: Int) -> [BoardDeparture] {
        var departures = [BoardDeparture]()
        
        let fileManager = FileManager.default
        let documentsUrl = fileManager.containerURL(forSecurityApplicationGroupIdentifier: Self.groupName)!
        let url = documentsUrl.appendingPathComponent(Self.databaseFileName)
        let db = try! Connection(url.absoluteString)
        
        do {
            for row in try db.prepare("""
                SELECT * FROM Departure
                JOIN BusStop ON BusStop.bs_id = Departure.d_bus_stop_id
                JOIN Track ON Departure.d_track_id = Track.t_id
                JOIN BusLine ON BusLine.bl_id = Departure.d_bus_line_id
                JOIN Route ON Track.t_route_id = Route.r_id
                JOIN Destinations ON Departure.d_symbols = Destinations.ds_symbol AND Destinations.ds_route_id = Route.r_id
                WHERE Departure.d_bus_stop_id = \(busStopId)
                AND (\(dayTypesQuery))
                AND Route.r_id = \(routeId)
                ORDER BY d_time_in_min
                """) {
                let id = Optional(row[0]) as! Int64
                let timeString = Optional(row[6]) as! String
                let symbols = Optional(row[7]) as! String
                let legend = Optional(row[29]) as! String
                let newDeparture = BoardDeparture(id: Int(id), legend: legend, symbols: symbols, timeString: timeString)
                departures.append(newDeparture)
            }
        } catch {
            print(error)
        }
        
        return departures
    }
    
    func getDestinations(busStopId: Int) -> [Route] {
        var routes = [Route]()
        
        let fileManager = FileManager.default
        let documentsUrl = fileManager.containerURL(forSecurityApplicationGroupIdentifier: Self.groupName)!
        let url = documentsUrl.appendingPathComponent(Self.databaseFileName)
        let db = try! Connection(url.absoluteString)
        
        do {
            for row in try db.prepare("SELECT * FROM Route WHERE Route.r_id IN (SELECT DISTINCT t_route_id FROM Departure JOIN Track ON Departure.d_track_id = Track.t_id WHERE d_bus_stop_id = \(busStopId))") {
                let id = Optional(row[0]) as! Int64
                let destinationName = Optional(row[1]) as! String
                let busLineId = Optional(row[2]) as! Int64
                let description = Optional(row[3]) as! String
                let newRoute = Route(id: Int(id), destinationName: destinationName, busLineId: Int(busLineId), description: description)
                routes.append(newRoute)
            }
        } catch {
            print(error)
        }
        
        return routes
    }
    
    func getBusLine(busLineId: Int) -> BusLine {
        var busLines = [BusLine]()
        
        let fileManager = FileManager.default
        let documentsUrl = fileManager.containerURL(forSecurityApplicationGroupIdentifier: Self.groupName)!
        let url = documentsUrl.appendingPathComponent(Self.databaseFileName)
        let db = try! Connection(url.absoluteString)
        
        do {
            for row in try db.prepare("SELECT * FROM BusLine WHERE BusLine.bl_id = \(busLineId)") {
                let id: Int64 = Optional(row[0]) as! Int64
                let name: String = Optional(row[1]) as! String
                let newBusLine = BusLine(id: Int(id), name: name)
                busLines.append(newBusLine)
            }
        } catch {
            print(error.localizedDescription)
        }
        
        return busLines[0]
    }
    
    func searchBusStops(text: String) -> [BusStop] {
        var busStops = [BusStop]()
        
        let fileManager = FileManager.default
        let documentsUrl = fileManager.containerURL(forSecurityApplicationGroupIdentifier: Self.groupName)!
        let url = documentsUrl.appendingPathComponent(Self.databaseFileName)
        let db = try! Connection(url.absoluteString)
        
        let searchText = text.lowercased().folding(options: .diacriticInsensitive, locale: .current).replacingOccurrences(of: "ł", with: "l")
        
        let words = searchText.components(separatedBy: " ")
        
        var queryFragment = ""
        
        for word in words {
            queryFragment += "BusStop.bs_search_name LIKE '%\(word)%' AND "
        }
        
        queryFragment.removeLast(5)
        
        print(queryFragment)
        
        do {
            for row in try db.prepare("""
                SELECT * FROM BusStop
                WHERE \(queryFragment)
                LIMIT 25
                """) {
                let id = Optional(row[0]) as! Int64
                let searchName = Optional(row[1]) as! String
                let name = Optional(row[2]) as! String
                let longitude = Optional(row[3]) as! Double
                let latitutde = Optional(row[4]) as! Double
                let destinations = Optional(row[5]) as! String
                let newBusStop = BusStop(id: Int(id), name: name, searchName: searchName, longitude: longitude, latitude: latitutde, destination: destinations)
                busStops.append(newBusStop)
            }
        } catch {
            print(error)
        }
        
        return busStops
    }
    
    func searchBusLines(text: String) -> [BusLine] {
        var busLines = [BusLine]()
        
        let fileManager = FileManager.default
        let documentsUrl = fileManager.containerURL(forSecurityApplicationGroupIdentifier: Self.groupName)!
        let url = documentsUrl.appendingPathComponent(Self.databaseFileName)
        let db = try! Connection(url.absoluteString)
        
        let searchText = text.lowercased().folding(options: .diacriticInsensitive, locale: .current).replacingOccurrences(of: "ł", with: "l")
        
        let words = searchText.components(separatedBy: " ")
        
        var queryFragment = ""
        
        for word in words {
            queryFragment += "BusLine.bl_name LIKE '%\(word)%' AND "
        }
        
        queryFragment.removeLast(5)
        
        print(queryFragment)
        
        do {
            for row in try db.prepare("""
                SELECT * FROM BusLine
                WHERE \(queryFragment)
                LIMIT 25
                """) {
                let id: Int64 = Optional(row[0]) as! Int64
                let name: String = Optional(row[1]) as! String
                let newBusLine = BusLine(id: Int(id), name: name)
                busLines.append(newBusLine)
            }
        } catch {
            print(error.localizedDescription)
        }
        
        return busLines
    }
    
    func getDeparturesFromTrack(trackId: String) -> [ListDeparture] {
        var departures = [ListDeparture]()
        
        let fileManager = FileManager.default
        let documentsUrl = fileManager.containerURL(forSecurityApplicationGroupIdentifier: Self.groupName)!
        let url = documentsUrl.appendingPathComponent(Self.databaseFileName)
        let db = try! Connection(url.absoluteString)
        
        do {
            for row in try db.prepare("""
                SELECT * FROM Departure
                JOIN BusStop ON BusStop.bs_id = Departure.d_bus_stop_id
                WHERE Departure.d_track_id = '\(trackId)'
                ORDER BY Departure.d_time_in_min
                """) {
                let id = Optional(row[0]) as! Int64
                let timeString = Optional(row[6]) as! String
                
                let busStopid = Optional(row[8]) as! Int64
                let searchName = Optional(row[9]) as! String
                let name = Optional(row[10]) as! String
                let longitude = Optional(row[11]) as! Double
                let latitutde = Optional(row[12]) as! Double
                let destinations = Optional(row[13]) as! String
                let newDeparture = ListDeparture(id: Int(id), timeString: timeString, busStop: BusStop(id: Int(busStopid), name: name, searchName: searchName, longitude: longitude, latitude: latitutde, destination: destinations))
                departures.append(newDeparture)
            }
        } catch {
            print(error)
        }
        
        return departures
    }
    
    func getCurrentDayType(currentDateString: String) -> String {
        var string = ""
        
        let fileManager = FileManager.default
        let documentsUrl = fileManager.containerURL(forSecurityApplicationGroupIdentifier: Self.groupName)!
        let url = documentsUrl.appendingPathComponent(Self.databaseFileName)
        let db = try! Connection(url.absoluteString)
        
        do {
            for row in try db.prepare("SELECT c_day_types FROM Calendar WHERE c_date = '\(currentDateString)'") {
                string = row[0] as! String
            }
        } catch {
            print(error)
        }
        
        return string
    }
    
    func getAllBusStops() -> [BusStop] {
        var busStops = [BusStop]()
        
        let fileManager = FileManager.default
        let documentsUrl = fileManager.containerURL(forSecurityApplicationGroupIdentifier: Self.groupName)!
        let url = documentsUrl.appendingPathComponent(Self.databaseFileName)
        let db = try! Connection(url.absoluteString)
        
        do {
            for row in try db.prepare("SELECT * FROM BusStop") {
                let id = Optional(row[0]) as! Int64
                let searchName = Optional(row[1]) as! String
                let name = Optional(row[2]) as! String
                let longitude = Optional(row[3]) as! Double
                let latitutde = Optional(row[4]) as! Double
                let destinations = Optional(row[5]) as! String
                let newBusStop = BusStop(id: Int(id), name: name, searchName: searchName, longitude: longitude, latitude: latitutde, destination: destinations)
                busStops.append(newBusStop)
            }
        } catch {
            print(error)
        }
        
        return busStops
    }
    
    func getBusStopConnections(fromId: Int, toId: Int) -> [BusStopConnection] {
        var busStopConnections = [BusStopConnection]()
        
        let fileManager = FileManager.default
        let documentsUrl = fileManager.containerURL(forSecurityApplicationGroupIdentifier: Self.groupName)!
        let url = documentsUrl.appendingPathComponent(Self.databaseFileName)
        let db = try! Connection(url.absoluteString)
        
        do {
            for row in try db.prepare("SELECT * FROM BusStopConnection WHERE bsc_from_bus_stop_id = \(fromId) AND bsc_to_bus_stop_id = \(toId)") {
                let fromBusStopId = Optional(row[0]) as! Int64
                let toBusStopId = Optional(row[1]) as! Int64
                let distance = Optional(row[2]) as! String
                let coordsList = Optional(row[3]) as! String
                let newBusStopConnection = BusStopConnection(fromBusStopId: Int(fromBusStopId), toBusStopId: Int(toBusStopId), distance: distance, coordsList: coordsList)
                busStopConnections.append(newBusStopConnection)
            }
        } catch {
            print(error)
        }
        
        return busStopConnections
    }
    
    func getBusStopBy(id: Int) -> BusStop? {
        getAllBusStops().first(where: { $0.id == id })
    }
    
    func saveLastUpdateToUserDefaults() {
        let url = URL(string: "https://dpajak99.github.io/tarbus-api/v2-1-1/last-update.json")!
        let request = URLRequest(url: url)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                if let decodedResponse = try? JSONDecoder().decode(LastUpdate.self, from: data) {
                    let defaults = UserDefaults.standard
                    DispatchQueue.main.async {
                        defaults.set(decodedResponse.formatted, forKey: "LastUpdate")
                    }
                    return
                }
            }
            print("Fetch failed: \(error?.localizedDescription ?? "Unknown error")")
        }.resume()
    }
}
