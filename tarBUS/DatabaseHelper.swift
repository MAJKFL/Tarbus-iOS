//
//  DatabaseHelper.swift
//  tarBUS
//
//  Created by Kuba Florek on 23/01/2021.
//

import SQLite
import Foundation

class DataBaseHelper: ObservableObject {
    static let tableNames = ["BusStop", "Departure", "BusLine", "Calendar", "Destinations", "Track", "AlertHistory", "RouteConnections", "LastUpdated", "BusStopConnection", "LastUpdated", "Route"]
    
    func fetchData() {
        let url = URL(string: "https://dpajak99.github.io/tarbus-api/v2-1-1/database.json")!
        let request = URLRequest(url: url)
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                self.deleteAllData()
                do {
                    if let anyObject = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions()) as? [AnyObject] {
                        let fileManager = FileManager.default
                        let documentsUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
                        let url = documentsUrl.first!.appendingPathComponent("tarbus.db")
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
                                let statement = try! db.prepare(sqlStatement)
                                let _ = try? statement.run()
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
        let documentsUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let url = documentsUrl.first!.appendingPathComponent("tarbus.db")
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
            
            let documentsUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
            
            guard documentsUrl.count != 0 else {
                return // Could not find documents URL
            }
            
            let finalDatabaseURL = documentsUrl.first!.appendingPathComponent("tarbus.db")
        
            if !( (try? finalDatabaseURL.checkResourceIsReachable()) ?? false) {
                print("DB does not exist in documents folder")
                
                let documentsURL = Bundle.main.resourceURL?.appendingPathComponent("tarbus.db")
                
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
        let documentsUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let url = documentsUrl.first!.appendingPathComponent("tarbus.db")
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
        let documentsUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let url = documentsUrl.first!.appendingPathComponent("tarbus.db")
        let db = try! Connection(url.absoluteString)
        
        do {
            for row in try db.prepare("SELECT * FROM Route WHERE Route.r_bus_line_id = \(busLineId)") {
                let id: Int64 = Optional(row[0]) as! Int64
                let name: String = Optional(row[1]) as! String
                let busLineId = Optional(row[2]) as! Int64
                let newRoute = Route(id: Int(id), destinationName: name, busLineId: Int(busLineId))
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
        let documentsUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let url = documentsUrl.first!.appendingPathComponent("tarbus.db")
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
    
    func getNextDepartures(busStopId: Int, dayTypes: String, startFromTime: Int) -> [Departure] {
        var departures = [Departure]()
        
        let fileManager = FileManager.default
        let documentsUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let url = documentsUrl.first!.appendingPathComponent("tarbus.db")
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
                let busStopId = Optional(row[1]) as! Int64
                let trackId = Optional(row[2]) as! String
                let busLineId = Optional(row[3]) as! Int64
                let busStopLp = Optional(row[4]) as! Int64
                let timeInMin = Optional(row[5]) as! Int64
                let timeString = Optional(row[6]) as! String
                let symbols = Optional(row[7]) as! String
                let legend = Optional(row[26]) as! String
                let routeId = Optional(row[25]) as! Int64
                let busLineName = Optional(row[20]) as! String
                let boardName = Optional(row[27]) as! String
                
                let newDeparture = Departure(id: Int(id), busStopId: Int(busStopId), trackId: trackId, busLineId: Int(busLineId), busStopLp: Int(busStopLp), timeInMin: Int(timeInMin), timeString: timeString, symbols: symbols, routeId: Int(routeId), legend: legend, busLineName: busLineName, dayId: 0, boardName: boardName, route: nil)
                departures.append(newDeparture)
            }
        } catch {
            print(error)
        }
        
        return departures
    }
    
    func getDeparturesByRouteAndDay(dayTypesQuery: String, routeId: Int, busStopId: Int) -> [Departure] {
        var departures = [Departure]()
        
        let fileManager = FileManager.default
        let documentsUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let url = documentsUrl.first!.appendingPathComponent("tarbus.db")
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
                let busStopId = Optional(row[1]) as! Int64
                let trackId = Optional(row[2]) as! String
                let busLineId = Optional(row[3]) as! Int64
                let busStopLp = Optional(row[4]) as! Int64
                let timeInMin = Optional(row[5]) as! Int64
                let timeString = Optional(row[6]) as! String
                let symbols = Optional(row[7]) as! String
                let legend = Optional(row[28]) as! String
                let routeId = Optional(row[25]) as! Int64
                let busLineName = Optional(row[20]) as! String
                let newDeparture = Departure(id: Int(id), busStopId: Int(busStopId), trackId: trackId, busLineId: Int(busLineId), busStopLp: Int(busStopLp), timeInMin: Int(timeInMin), timeString: timeString, symbols: symbols, routeId: Int(routeId), legend: legend, busLineName: busLineName, dayId: 0, boardName: nil, route: nil)
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
        let documentsUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let url = documentsUrl.first!.appendingPathComponent("tarbus.db")
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
    
    func getDestinations(busStopId: Int) -> [Route] {
        var routes = [Route]()
        
        let fileManager = FileManager.default
        let documentsUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let url = documentsUrl.first!.appendingPathComponent("tarbus.db")
        let db = try! Connection(url.absoluteString)
        
        do {
            for row in try db.prepare("SELECT * FROM Route WHERE Route.r_id IN (SELECT DISTINCT t_route_id FROM Departure JOIN Track ON Departure.d_track_id = Track.t_id WHERE d_bus_stop_id = \(busStopId))") {
                let id = Optional(row[0]) as! Int64
                let destinationName = Optional(row[1]) as! String
                let busLineId = Optional(row[2]) as! Int64
                let newRoute = Route(id: Int(id), destinationName: destinationName, busLineId: Int(busLineId))
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
        let documentsUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let url = documentsUrl.first!.appendingPathComponent("tarbus.db")
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
        let documentsUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let url = documentsUrl.first!.appendingPathComponent("tarbus.db")
        let db = try! Connection(url.absoluteString)
        
        let searchText = text.lowercased().folding(options: .diacriticInsensitive, locale: .current)
        
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
        let documentsUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let url = documentsUrl.first!.appendingPathComponent("tarbus.db")
        let db = try! Connection(url.absoluteString)
        
        let searchText = text.lowercased().folding(options: .diacriticInsensitive, locale: .current)
        
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
}

extension Array where Element:Equatable {
    func removeDuplicates() -> [Element] {
        var result = [Element]()

        for value in self {
            if result.contains(value) == false {
                result.append(value)
            }
        }

        return result
    }
}
