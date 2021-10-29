//
//  DatabaseHelper.swift
//  tarBUS
//
//  Created by Kuba Florek on 23/01/2021.
//

import GRDB
import Foundation
import WidgetKit

class DataBaseHelper: ObservableObject {
    static let tableNames = ["BusStop", "Departure", "BusLine", "Calendar", "Destinations", "Track", "AlertHistory", "RouteConnections", "LastUpdated", "BusStopConnection", "LastUpdated", "Route"]
    static let databaseFileName = "tarbus.db"
    static let groupName = "group.florekjakub.tarBUSapp"
    
    func getDBQueue() -> DatabaseQueue? {
        let fileManager = FileManager.default
        let groupURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: Self.groupName)!
        let databaseURL = groupURL.appendingPathComponent(Self.databaseFileName)
        
        return try? DatabaseQueue(path: databaseURL.absoluteString)
    }
    
    func copyDatabaseIfNeeded() {
        let fileManager = FileManager.default
        let documentsUrl = fileManager.containerURL(forSecurityApplicationGroupIdentifier: Self.groupName)!
        let finalDatabaseURL = documentsUrl.appendingPathComponent(Self.databaseFileName)
        let fileURLs = try? fileManager.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
        let documentsURL = Bundle.main.resourceURL?.appendingPathComponent(Self.databaseFileName)
        
        for fileURL in fileURLs ?? [] {
            if (fileURL.absoluteString as NSString).lastPathComponent == Self.databaseFileName {
                let stringPath = Bundle.main.path(forResource: "tarbus", ofType: "db")!
                if fileManager.contentsEqual(atPath: fileURL.absoluteString, andPath: stringPath) {
                    return
                } else {
                    print(fileURL)
                    do {
                        try fileManager.removeItem(at: fileURL)
                        try fileManager.copyItem(atPath: (documentsURL?.path)!, toPath: finalDatabaseURL.path)
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
        }
    
        if !( (try? finalDatabaseURL.checkResourceIsReachable()) ?? false){
            print("DB does not exist in documents folder")
            do {
                try fileManager.copyItem(atPath: (documentsURL?.path)!, toPath: finalDatabaseURL.path)
              } catch let error as NSError {
                  print("Couldn't copy file to final location! Error:\(error.description)")
              }
        } else {
            print("Database file found at path: \(finalDatabaseURL.path)")
        }
    }
    
    func fetchData() {
        let url = URL(string: "https://dpajak99.github.io/tarbus-api/v2-1-3/database.json")!
        let request = URLRequest(url: url)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                self.deleteAllData()
                do {
                    if let anyObject = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions()) as? [AnyObject] {
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
                                
                                let dbQueue = self.getDBQueue()
                                try? dbQueue?.write { db in
                                    try? db.execute(sql: sqlStatement)
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
    
    func fetchSelectedCompanies() -> [Company] {
        let defaults = UserDefaults(suiteName: Self.groupName)
        
        if let data = defaults?.data(forKey: SelectedCompaniesViewModel.saveKey) {
            if let decoded = try? JSONDecoder().decode([Company].self, from: data) {
                return decoded
            }
        }

        return []
    }
    
    func deleteAllData() {
        let dbQueue = getDBQueue()
        
        try? dbQueue?.write { db in
            for tableName in Self.tableNames {
                try? db.execute(sql: "DELETE FROM \(tableName)")
            }
        }
    }
    
    func getBusLines() -> [BusLine] {
        let dbQueue = getDBQueue()
        var busLines = [BusLine]()
        
        try? dbQueue?.read { db in
            if let rows = try? Row.fetchCursor(db, sql: """
                SELECT * FROM BusLine
                """) {
                while let row = try? rows.next() {
                    let id: Int? = row["bl_id"]
                    let name: String? = row["bl_name"]
                    busLines.append(BusLine(id: id ?? 0, name: name ?? ""))
                }
            }
        }
        
        return busLines
    }
    
    func getRoutes(busLineId: Int) -> [Route] {
        let dbQueue = getDBQueue()
        var routes = [Route]()
        
        try? dbQueue?.read { db in
            if let rows = try? Row.fetchCursor(db, sql: """
                SELECT *
                FROM Route
                WHERE Route.r_bus_line_id = \(busLineId)
                """) {
                while let row = try? rows.next() {
                    let id: Int? = row["r_id"]
                    let destinationName: String? = row["r_destination_name"]
                    let busLineId: Int? = row["r_bus_line_id"]
                    let description: String? = row["r_destination_desc"]
                    routes.append(Route(id: id ?? 0, destinationName: destinationName ?? "", busLineId: busLineId ?? 0, description: description ?? ""))
                }
            }
        }
        
        return routes
    }
    
    func getBusStops(routeId: Int) -> [BusStop] {
        let dbQueue = getDBQueue()
        var busStops = [BusStop]()
        
        try? dbQueue?.read { db in
            if let rows = try? Row.fetchCursor(db, sql: """
               SELECT *
               FROM RouteConnections
               JOIN BusStop ON BusStop.bs_id = RouteConnections.rc_bus_stop_id
               WHERE RouteConnections.rc_route_id = \(routeId)
               ORDER BY rc_lp
               """) {
                while let row = try? rows.next() {
                    let id: Int? = row["bs_id"]
                    let name: String? = row["bs_name"]
                    let searchName: String? = row["bs_search_name"]
                    let longitude: Double? = row["bs_lng"]
                    let latitude: Double? = row["bs_lat"]
                    let destinations: String? = row["bs_destinations"]
                    busStops.append(BusStop(id: id ?? 0, name: name ?? "", searchName: searchName ?? "", longitude: longitude ?? 0, latitude: latitude ?? 0, destination: destinations ?? ""))
                }
            }
        }
        
        return busStops
    }
    
    func getNextDepartures(busStopId: Int, dayTypes: String, startFromTime: Int) -> [NextDeparture] {
        let dbQueue = getDBQueue()
        var departures = [NextDeparture]()
        
        let strArray = dayTypes.components(separatedBy: " ")
        var dayTypesQuery = ""
        for element in strArray { dayTypesQuery += "instr(Track.t_day_types, '\(element)') OR " }
        dayTypesQuery.removeLast(4)
        
        try? dbQueue?.read { db in
            if let rows = try? Row.fetchCursor(db, sql: """
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
                while let row = try? rows.next() {
                    let id: Int? = row["d_id"]
                    let trackId: String? = row["d_track_id"]
                    let timeString: String? = row["d_time_string"]
                    let timeInt: Int? = row["d_time_in_min"]
                    let boardName: String? = row["ds_direction_board_name"]
                    let busLine: BusLine = BusLine(id: row["bl_id"], name: row["bl_name"])
                    departures.append(NextDeparture(id: id ?? 0, trackId: trackId ?? "", timeString: timeString ?? "", timeInt: timeInt ?? 0, boardName: boardName ?? "", busLine: busLine))
                }
            }
        }
        
        return departures
    }
    
    func getDeparturesByRouteAndDay(dayTypesQuery: String, routeId: Int, busStopId: Int) -> [BoardDeparture] {
        let dbQueue = getDBQueue()
        var departures = [BoardDeparture]()
        
        try? dbQueue?.read { db in
            if let rows = try? Row.fetchCursor(db, sql: """
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
                while let row = try? rows.next() {
                    let id: Int? = row["d_id"]
                    let timeString: String? = row["d_time_string"]
                    let symbols: String? = row["d_symbols"]
                    let legend: String? = row["ds_shedule_name"]
                    departures.append(BoardDeparture(id: id ?? 0, legend: legend ?? "", symbols: symbols ?? "", timeString: timeString ?? ""))
                }
            }
        }
        
        return departures
    }
    
    func getDestinations(busStopId: Int) -> [Route] {
        let dbQueue = getDBQueue()
        var routes = [Route]()
        
        try? dbQueue?.read { db in
            if let rows = try? Row.fetchCursor(db, sql: """
               SELECT *
               FROM Route
               WHERE Route.r_id IN (SELECT DISTINCT t_route_id
               FROM Departure
               JOIN Track ON Departure.d_track_id = Track.t_id
               WHERE d_bus_stop_id = \(busStopId))
               """) {
                while let row = try? rows.next() {
                    let id: Int? = row["r_id"]
                    let destinationName: String? = row["r_destination_name"]
                    let busLineId: Int? = row["r_bus_line_id"]
                    let description: String? = row["r_destination_desc"]
                    routes.append(Route(id: id ?? 0, destinationName: destinationName ?? "", busLineId: busLineId ?? 0, description: description ?? ""))
                }
            }
        }
        
        return routes
    }
    
    func getBusLine(busLineId: Int) -> BusLine? {
        let dbQueue = getDBQueue()
        var busLine: BusLine?
        
        try? dbQueue?.read { db in
            if let row = try Row.fetchOne(db, sql: """
                SELECT *
                FROM BusLine
                WHERE BusLine.bl_id = \(busLineId)
                """) {
                let id: Int? = row["bl_id"]
                let name: String? = row["bl_name"]
                busLine = BusLine(id: id ?? 0, name: name ?? "")
            }
        }
        
        return busLine
    }
    
    func searchBusStops(text: String) -> [BusStop] {
        let dbQueue = getDBQueue()
        var busStops = [BusStop]()
        
        let searchText = text.lowercased().folding(options: .diacriticInsensitive, locale: .current).replacingOccurrences(of: "ł", with: "l")
        let words = searchText.components(separatedBy: " ")
        var queryFragment = ""
        for word in words { queryFragment += "BusStop.bs_search_name LIKE '%\(word)%' AND " }
        queryFragment.removeLast(5)
        
        try? dbQueue?.read { db in
            if let rows = try? Row.fetchCursor(db, sql: """
                SELECT * FROM BusStop
                WHERE \(queryFragment)
                LIMIT 25
                """) {
                while let row = try? rows.next() {
                    let id: Int? = row["bs_id"]
                    let name: String? = row["bs_name"]
                    let searchName: String? = row["bs_search_name"]
                    let longitude: Double? = row["bs_lng"]
                    let latitude: Double? = row["bs_lat"]
                    let destinations: String? = row["bs_destinations"]
                    busStops.append(BusStop(id: id ?? 0, name: name ?? "", searchName: searchName ?? "", longitude: longitude ?? 0, latitude: latitude ?? 0, destination: destinations ?? ""))
                }
            }
        }
        
        return busStops
    }
    
    func searchBusLines(text: String) -> [BusLine] {
        let dbQueue = getDBQueue()
        var busLines = [BusLine]()
        
        let searchText = text.lowercased().folding(options: .diacriticInsensitive, locale: .current).replacingOccurrences(of: "ł", with: "l")
        let words = searchText.components(separatedBy: " ")
        var queryFragment = ""
        for word in words { queryFragment += "BusLine.bl_name LIKE '%\(word)%' AND " }
        queryFragment.removeLast(5)
        
        try? dbQueue?.read { db in
            if let rows = try? Row.fetchCursor(db, sql: """
                SELECT * FROM BusLine
                WHERE \(queryFragment)
                LIMIT 25
                """) {
                while let row = try? rows.next() {
                    let id: Int? = row["bl_id"]
                    let name: String? = row["bl_name"]
                    busLines.append(BusLine(id: id ?? 0, name: name ?? ""))
                }
            }
        }
        
        return busLines
    }
    
    func getDeparturesFromTrack(trackId: String) -> [ListDeparture] {
        let dbQueue = getDBQueue()
        var departures = [ListDeparture]()
        
        try? dbQueue?.read { db in
            if let rows = try? Row.fetchCursor(db, sql: """
                SELECT * FROM Departure
                JOIN BusStop ON BusStop.bs_id = Departure.d_bus_stop_id
                WHERE Departure.d_track_id = '\(trackId)'
                ORDER BY Departure.d_time_in_min
                """) {
                while let row = try? rows.next() {
                    let id: Int? = row["d_id"]
                    let timeString: String? = row["d_time_string"]
                    
                    let busStopId: Int? = row["bs_id"]
                    let name: String? = row["bs_name"]
                    let searchName: String? = row["bs_search_name"]
                    let longitude: Double? = row["bs_lng"]
                    let latitude: Double? = row["bs_lat"]
                    let destinations: String? = row["bs_destinations"]
                    
                    let busStop = BusStop(id: busStopId ?? 0, name: name ?? "", searchName: searchName ?? "", longitude: longitude ?? 0, latitude: latitude ?? 0, destination: destinations ?? "")
                    
                    departures.append(ListDeparture(id: id ?? 0, timeString: timeString ?? "", busStop: busStop))
                }
            }
        }
        
        return departures
    }
    
    func getCurrentDayType(currentDateString: String) -> String {
        let dbQueue = getDBQueue()
        var string = ""
        
        try? dbQueue?.read { db in
            if let row = try Row.fetchOne(db, sql: "SELECT c_day_types FROM Calendar WHERE c_date = '\(currentDateString)'") {
                string = row["c_day_types"]
            }
        }
        
        return string
    }
    
    func getAllBusStops() -> [BusStop] {
        let dbQueue = getDBQueue()
        var busStops = [BusStop]()
        
        try? dbQueue?.read { db in
            if let rows = try? Row.fetchCursor(db, sql: """
               SELECT *
               FROM BusStop
               """) {
                while let row = try? rows.next() {
                    let id: Int? = row["bs_id"]
                    let name: String? = row["bs_name"]
                    let searchName: String? = row["bs_search_name"]
                    let longitude: Double? = row["bs_lng"]
                    let latitude: Double? = row["bs_lat"]
                    let destinations: String? = row["bs_destinations"]
                    busStops.append(BusStop(id: id ?? 0, name: name ?? "", searchName: searchName ?? "", longitude: longitude ?? 0, latitude: latitude ?? 0, destination: destinations ?? ""))
                }
            }
        }
        
        return busStops
    }
    
    func getBusStopConnections(fromId: Int, toId: Int) -> [BusStopConnection] {
        let dbQueue = getDBQueue()
        var busStopConnections = [BusStopConnection]()
        
        try? dbQueue?.read { db in
            if let rows = try? Row.fetchCursor(db, sql: """
                SELECT *
                FROM BusStopConnection
                WHERE bsc_from_bus_stop_id = \(fromId)
                AND bsc_to_bus_stop_id = \(toId)
                """) {
                while let row = try? rows.next() {
                    let fromBusStopId: Int? = row["bsc_from_bus_stop_id"]
                    let toBusStopId: Int? = row["bsc_to_bus_stop_id"]
                    let distance: String? = row["bsc_distance"]
                    let coordsList: String? = row["bsc_coords_list"]
                    busStopConnections.append(BusStopConnection(fromBusStopId: fromBusStopId ?? 0, toBusStopId: toBusStopId ?? 0, distance: distance ?? "", coordsList: coordsList ?? ""))
                }
            }
        }
        
        return busStopConnections
    }
    
    func getNearestBusStops(lat: Double, lng: Double) -> [BusStop] {
        var busStops = getAllBusStops()
        
        busStops.sort(by: {
            let firstDistance = sqrt(pow($0.latitude - lat, 2) + pow($0.longitude - lng, 2))
            let seocondDistance = sqrt(pow($1.latitude - lat, 2) + pow($1.longitude - lng, 2))
            return firstDistance < seocondDistance
        })
        
        return Array(busStops.prefix(6))
    }
    
    func getBusStopBy(id: Int) -> BusStop? {
        getAllBusStops().first(where: { $0.id == id })
    }
}
