//
//  BusStopView.swift
//  tarBUS
//
//  Created by Kuba Florek on 29/01/2021.
//

import SwiftUI

struct BusStopView: View {
    let busStop: BusStop
    let filteredBusLines: [BusLine]
    @State private var isShowingAddView = false
    @State private var currentView = 1
    @ObservedObject var favouriteBusStopsViewModel = FavouriteBusStopsViewModel()
    
    var body: some View {
        TabView(selection: $currentView) {
            NextDeparturesView(busStop: busStop, filteredBusLines: filteredBusLines, currentView: $currentView)
            .tabItem {
                Image(systemName: "bus.fill")
            }
            .tag(1)
            
            PlanView(busStop: busStop)
            .tabItem {
                Image(systemName: "note.text")
            }
            .tag(2)
        }
        .tabViewStyle(PageTabViewStyle())
        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
        .navigationBarItems(trailing: Button(action: {
            if favouriteBusStopsViewModel.busStops.contains(where: { $0.id == busStop.id }) {
                favouriteBusStopsViewModel.remove(id: busStop.id)
            } else {
                isShowingAddView = true
            }
        }, label: {
            Image(systemName: favouriteBusStopsViewModel.busStops.contains(where: { $0.id == busStop.id }) ? "heart.fill" : "heart")
        }))
        .navigationTitle(busStop.name)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $isShowingAddView, onDismiss: favouriteBusStopsViewModel.fetch, content: {
            BusStopConfirmationView(busStop: busStop)
        })
    }
}
