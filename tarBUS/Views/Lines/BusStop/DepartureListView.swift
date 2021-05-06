//
//  BusStopListViewWithDepartures.swift
//  tarBUS
//
//  Created by Kuba Florek on 07/02/2021.
//

import SwiftUI

struct DepartureListView: View {
    @StateObject var databaseHelper = DataBaseHelper()
    @State private var departures = [ListDeparture]()
    @State private var isActive = false
    let mainDeparture: NextDeparture
    let busStop: BusStop
    
    var connections: [BusStopConnection] {
        var connections = [BusStopConnection]()
        for index in departures.indices {
            if index + 1 != departures.count {
                connections += databaseHelper.getBusStopConnections(fromId: departures[index].busStop.id, toId: departures[index + 1].busStop.id)
            }
        }
        return connections
    }
    
    var busStops: [BusStop] {
        departures.map { $0.busStop }
    }
    
    var body: some View {
        ScrollView {
            ScrollViewReader { reader in
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(departures.indices, id: \.self) { index in
                        HStack {
                            switch(index) {
                            case 0:
                                Image("firstBusStop\(departures[index].id == mainDeparture.id ? "" : "G")")
                                    .busStopLabel()
                            case departures.count - 1:
                                Image("lastBusStop\(departures[index].id == mainDeparture.id ? "" : "G")")
                                    .busStopLabel()
                            default:
                                Image("nextBusStop\(departures[index].id == mainDeparture.id ? "" : "G")")
                                    .busStopLabel()
                            }
                            
                            Text(departures[index].busStop.name)
                                .font(departures[index].id == mainDeparture.id ? .headline : .subheadline)
                                .lineLimit(2)
                            
                            Spacer()
                            
                            Text(departures[index].timeString)
                                .font(.headline)
                        }
                        .frame(maxHeight: 50)
                        .padding(.horizontal)
                        .id(departures[index].id)
                    }
                    
                    NavigationLink("", destination: TrackMapView(connections: connections, busStops: busStops, busStop: busStop), isActive: $isActive).hidden()
                }
                .onAppear {
                    departures = databaseHelper.getDeparturesFromTrack(trackId: mainDeparture.trackId)
                    
//                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(400)) {
//                        withAnimation(.spring()) {
//                            reader.scrollTo(mainDeparture.id, anchor: .center)
//                        }
//                    }
                }
            }
            .navigationTitle("Trasa \(mainDeparture.busLine.name)")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarItems(trailing: Button(action: {
                isActive.toggle()
            }, label: {
                Image(systemName: "map")
            }))
        }
    }
}
