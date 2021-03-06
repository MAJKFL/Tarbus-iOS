//
//  IntentHandler.swift
//  tarBusIntentExtension
//
//  Created by Kuba Florek on 06/03/2021.
//

import Intents

class IntentHandler: INExtension, SelectBusStopIntentHandling {
    func provideBusStopOptionsCollection(for intent: SelectBusStopIntent, with completion: @escaping (INObjectCollection<BusStopParam>?, Error?) -> Void) {
        let databaseHelper = DataBaseHelper()
        
        let busStops = databaseHelper.getAllBusStops()
        let busStopParams = busStops.map { busStop in
            BusStopParam(busStop: busStop)
        }
        
        completion(INObjectCollection(items: busStopParams), nil)
    }
    
    override func handler(for intent: INIntent) -> Any {
        // This is the default implementation.  If you want different objects to handle different intents,
        // you can override this and return the handler you want for that particular intent.
        
        return self
    }
    
}

extension BusStopParam {
    convenience init(busStop: BusStop) {
        self.init(identifier: "\(busStop.id)", display: busStop.name)
        self.name = busStop.name
        self.number = NSNumber(value: busStop.id)
    }
}
