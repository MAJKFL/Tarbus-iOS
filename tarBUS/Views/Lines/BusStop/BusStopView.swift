//
//  BusStopView.swift
//  tarBUS
//
//  Created by Kuba Florek on 29/01/2021.
//

import SwiftUI
import Intents

struct BusStopView: View {
    enum CurrentBusStopView: Int, Identifiable, CaseIterable {
        case departures = 1
        case plan = 2
        
        var id: Int {
            self.rawValue
        }
        
        var title: String {
            if self == .departures {
                return "Najbliższe"
            } else {
                return "Wszystkie"
            }
        }
    }
    @ObservedObject var favouriteBusStopsViewModel = FavouriteBusStopsViewModel()
    @State private var isShowingAddView = false
    @State private var currentView = 1
    
    let busStop: BusStop
    let filteredBusLines: [BusLine]
    
    init(busStop: BusStop, filteredBusLines: [BusLine]) {
        self.busStop = busStop
        self.filteredBusLines = filteredBusLines
    }
    
    init(deeplink: Deeplink) {
        self.busStop = deeplink.busStop
        self.filteredBusLines = deeplink.filteredBusLines
    }
    
    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $currentView) {
                NextDeparturesView(filteredBusLines: filteredBusLines, busStop: busStop)
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
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button(action: {
                    if favouriteBusStopsViewModel.busStops.contains(where: { $0.id == busStop.id }) {
                        favouriteBusStopsViewModel.remove(id: busStop.id)
                    } else {
                        isShowingAddView = true
                    }
                }, label: {
                    Image(systemName: favouriteBusStopsViewModel.busStops.contains(where: { $0.id == busStop.id }) ? "heart.fill" : "heart")
                })
                
                Button(action: actionSheet, label: {
                    Image(systemName: "square.and.arrow.up")
                })
            }
            
            ToolbarItemGroup(placement: .principal) {
                Picker("", selection: $currentView.animation(.spring())) {
                    ForEach(CurrentBusStopView.allCases) {
                        Text($0.title)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .frame(width: 180)
            }
        }
        .sheet(isPresented: $isShowingAddView, onDismiss: favouriteBusStopsViewModel.fetch) {
            BusStopConfirmationView(busStop: busStop)
        }
        .navigationTitle(busStop.name)
        .navigationBarTitleDisplayMode(.inline)
//        .onAppear {
//            let intent = SelectBusStopIntent()
//            intent.busStop = BusStopParam(busStop: busStop)
//            
//            let interaction = INInteraction(intent: intent, response: nil)
//            interaction.donate { error in
//                if let error = error {
//                    print(error.localizedDescription)
//                }
//            }
//        }
    }
    
    func actionSheet() {
        guard let urlShare = URL(string: "https://app.tarbus.pl/store?directFrom=schedule&busStopId=\(busStop.id)") else { return }
        let activityVC = UIActivityViewController(activityItems: [urlShare], applicationActivities: nil)
        UIApplication.shared.windows.first?.rootViewController?.present(activityVC, animated: true, completion: nil)
    }
}
