//
//  BusStopView.swift
//  tarBUS
//
//  Created by Kuba Florek on 29/01/2021.
//

import SwiftUI

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
    
    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $currentView) {
                NextDeparturesView(filteredBusLines: filteredBusLines, currentView: $currentView, busStop: busStop)
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
            }
        }
        .sheet(isPresented: $isShowingAddView, onDismiss: favouriteBusStopsViewModel.fetch) {
            BusStopConfirmationView(busStop: busStop)
        }
        .navigationTitle(busStop.name)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func actionSheet() {
        guard let urlShare = URL(string: "https://app.tarbus.pl/store?directFrom=schedule&busStopId=\(busStop.id)") else { return }
        let activityVC = UIActivityViewController(activityItems: [urlShare], applicationActivities: nil)
        UIApplication.shared.windows.first?.rootViewController?.present(activityVC, animated: true, completion: nil)
    }
}
