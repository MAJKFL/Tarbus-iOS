//
//  DatabaseHelper.swift
//  tarBUS
//
//  Created by Kuba Florek on 23/01/2021.
//

import SQLite
import Foundation

class DataBaseHelper: ObservableObject {
    static let tableNames = ["BusStop", "Departure", "BusLine", "DayType", "Destinations", "Track", "AlertHistory", "RouteConnections", "LastUpdated", "BusStopConnection", "LastUpdated", "Route"]
    
    func fetchData() {
        let url = URL(string: "https://dpajak99.github.io/tarbus-api/v2-0-1/database.json")!
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
    
    func getDepartures(busStopId: Int) -> [Departure] {
        var departures = [Departure]()
        
        let fileManager = FileManager.default
        let documentsUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let url = documentsUrl.first!.appendingPathComponent("tarbus.db")
        let db = try! Connection(url.absoluteString)
        
        do {
            for row in try db.prepare("SELECT * FROM Departure JOIN BusStop ON BusStop.bs_id = Departure.d_bus_stop_id JOIN Track ON Departure.d_track_id = Track.t_id JOIN BusLine ON BusLine.bl_id = Departure.d_bus_line_id JOIN Destinations ON Departure.d_symbols = Destinations.ds_symbol JOIN Route ON Track.t_route_id = Route.r_id WHERE Departure.d_bus_stop_id = \(busStopId)") {
                let id = Optional(row[0]) as! Int64
                let busStopId = Optional(row[1]) as! Int64
                let trackId = Optional(row[2]) as! String
                let busLineId = Optional(row[3]) as! Int64
                let busStopLp = Optional(row[4]) as! Int64
                let timeInMin = Optional(row[5]) as! Int64
                let timeString = Optional(row[6]) as! String
                let symbols = Optional(row[7]) as! String
                let newDeparture = Departure(id: Int(id), busStopId: Int(busStopId), trackId: trackId, busLineId: Int(busLineId), busStopLp: Int(busStopLp), timeInMin: Int(timeInMin), timeString: timeString, symbols: symbols, routeId: 0, legend: "", busLineName: "")
                departures.append(newDeparture)
            }
        } catch {
            print(error)
        }
        
        return departures
    }
    
    func getDepartures(busStopId: Int, dayType: String) -> [Departure] {
        var departures = [Departure]()
        
        let fileManager = FileManager.default
        let documentsUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let url = documentsUrl.first!.appendingPathComponent("tarbus.db")
        let db = try! Connection(url.absoluteString)
        
        do {
            for row in try db.prepare("SELECT * FROM Departure JOIN BusStop ON BusStop.bs_id = Departure.d_bus_stop_id JOIN Track ON Departure.d_track_id = Track.t_id JOIN BusLine ON BusLine.bl_id = Departure.d_bus_line_id JOIN Destinations ON Departure.d_symbols = Destinations.ds_symbol AND Destinations.ds_route_id = Route.r_id JOIN Route ON Track.t_route_id = Route.r_id WHERE Departure.d_bus_stop_id = \(busStopId) AND Track.t_day_id IN (\(dayType)) ORDER BY Departure.d_time_in_min") {
                let id = Optional(row[0]) as! Int64
                let busStopId = Optional(row[1]) as! Int64
                let trackId = Optional(row[2]) as! String
                let busLineId = Optional(row[3]) as! Int64
                let busStopLp = Optional(row[4]) as! Int64
                let timeInMin = Optional(row[5]) as! Int64
                let timeString = Optional(row[6]) as! String
                let symbols = Optional(row[7]) as! String
                let legend = Optional(row[25]) as! String
                let routeId = Optional(row[26]) as! Int64
                let busLineName = Optional(row[20]) as! String
                let newDeparture = Departure(id: Int(id), busStopId: Int(busStopId), trackId: trackId, busLineId: Int(busLineId), busStopLp: Int(busStopLp), timeInMin: Int(timeInMin), timeString: timeString, symbols: symbols, routeId: Int(routeId), legend: legend, busLineName: busLineName)
                departures.append(newDeparture)
            }
        } catch {
            print(error)
        }
        
        return departures.removeDuplicates()
    }
    
    func getDestinations(busStopId: Int) -> [Route] {
        var routes = [Route]()
        
        let fileManager = FileManager.default
        let documentsUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let url = documentsUrl.first!.appendingPathComponent("tarbus.db")
        let db = try! Connection(url.absoluteString)
        
        do {
            for row in try db.prepare("SELECT * FROM Route WHERE Route.r_id IN (SELECT DISTINCT t_route_id FROM Departure JOIN Track ON Departure.d_track_id = Track.t_id WHERE d_bus_stop_id = \(busStopId))") {
                print("destinations")
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
                print("busline")
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
