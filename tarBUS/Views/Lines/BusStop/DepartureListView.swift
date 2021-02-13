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
    let mainDeparture: NextDeparture
    
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
                            
                            Text(departures[index].busStopName)
                                .font(departures[index].id == mainDeparture.id ? .headline : .subheadline)
                                .lineLimit(2)
                            
                            Spacer()
                            
                            Text(departures[index].timeString)
                                .font(.headline)
                        }
                        .padding(.horizontal)
                        .id(departures[index].id)
                    }
                }
                .onAppear {
                    departures = databaseHelper.getDeparturesFromTrack(trackId: mainDeparture.trackId)
                    
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(400)) {
                        withAnimation(.spring()) {
                            reader.scrollTo(mainDeparture.id, anchor: .center)
                        }
                    }
                }
            }
            .navigationTitle("Trasa \(mainDeparture.busLineName)")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}
