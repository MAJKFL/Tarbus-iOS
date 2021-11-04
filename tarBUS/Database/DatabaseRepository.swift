//
//  DatabaseRepository.swift
//  tarBUS
//
//  Created by Jakub Florek on 04/11/2021.
//

import Foundation
import GRDB
import WidgetKit

class DatabaseRepository: ObservableObject {
    func copyDatabaseIfNeeded() {
        let fileManager = FileManager.default
        let documentsUrl = fileManager.containerURL(forSecurityApplicationGroupIdentifier: DataBaseHelper.groupName)!
        let finalDatabaseURL = documentsUrl.appendingPathComponent(DataBaseHelper.databaseFileName)
        let fileURLs = try? fileManager.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
        let documentsURL = Bundle.main.resourceURL?.appendingPathComponent(DataBaseHelper.databaseFileName)
        
        for fileURL in fileURLs ?? [] {
            if (fileURL.absoluteString as NSString).lastPathComponent == DataBaseHelper.databaseFileName {
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
    
    func testFetchData(subscribeCode: String) {
        let url = URL(string: "https://api.tarbus.pl/static/database/template2-\(subscribeCode).json")!
        let request = URLRequest(url: url)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                self.deleteCompany(subscribeCode: subscribeCode)
                do {
                    if let anyObject = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions()) as? [AnyObject] {
                        var objectsToIterate = anyObject
                        
                        repeat {
                            objectsToIterate = self.saveToDatabase(objectsToIterate)
                        } while !objectsToIterate.isEmpty
                    }
                } catch {
                    print(error.localizedDescription)
                }
            }
        }.resume()
    }
    
    func saveToDatabase(_ anyObject: [AnyObject]) -> [AnyObject] {
        var objectsToReiterate = [AnyObject]()
        
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
                var sqlStatement = "INSERT OR IGNORE INTO \(object["name"] as! String) (\(keys)) VALUES "
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
                
                let dbQueue = DataBaseHelper.getDBQueue()
                do {
                    try dbQueue?.write { db in
                        try db.execute(sql: sqlStatement)
                    }
                } catch {
                    objectsToReiterate.append(object)
//                    print(error.localizedDescription)
                }
                
                WidgetCenter.shared.reloadAllTimelines()
                
            }
        }
        
        return objectsToReiterate
    }
    
    func getCompanyVersions() -> [CompanyVersion] {
        let defaults = UserDefaults(suiteName: DataBaseHelper.groupName)
        
        if let data = defaults?.data(forKey: SelectedCompaniesViewModel.saveKey) {
            if let decoded = try? JSONDecoder().decode([CompanyVersion].self, from: data) {
                return decoded
            }
        }

        return []
    }
    
    func fetch() {
        let request = URLRequest(url: DataBaseHelper.subscribeCodeURL)
        
        let userDefaults = UserDefaults(suiteName: DataBaseHelper.groupName)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                DispatchQueue.main.async {
                    guard let newSubscribeCodes = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Int] else { return }
                    
                    let oldSubscribeCodes = userDefaults?.object(forKey: "SubscribeCodes") as? [String: Int] ?? [:]
                    
                    let companyVersions = self.getCompanyVersions()
                    
                    for companyVersion in companyVersions {
//                        if oldSubscribeCodes[companyVersion.subscribeCode] != newSubscribeCodes[companyVersion.subscribeCode] {
                            self.testFetchData(subscribeCode: companyVersion.subscribeCode)
//                        }
                    }
                    
                    userDefaults?.set(newSubscribeCodes, forKey: "SubscribeCodes")
                }
                return
            }
            print("Fetch failed: \(error?.localizedDescription ?? "Unknown error")")
        }.resume()
    }
    
    func deleteCompany(subscribeCode: String) {
        let dbQueue = DataBaseHelper.getDBQueue()
        
        try? dbQueue?.write { db in
            try? db.execute(sql: "DELETE FROM Versions WHERE v_subscribe_code = '\(subscribeCode)'")
        }
    }
}
