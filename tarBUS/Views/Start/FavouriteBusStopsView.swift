//
//  FavouriteBusStopsView.swift
//  tarBUS
//
//  Created by Kuba Florek on 10/02/2021.
//

import SwiftUI
import Combine

struct FavouriteBusStopsListView: View {
    @ObservedObject var favouriteBusStopsViewModel = FavouriteBusStopsViewModel()
    @State private var isShowingAddView = false
    
    var body: some View {
        ForEach(favouriteBusStopsViewModel.busStops) { busStop in
            NavigationLink(
                destination: BusStopView(busStop: busStop),
                label: {
                    HStack {
                        Image("busStop")
                        
                        VStack(alignment: .leading) {
                            Text(busStop.userName ?? busStop.name)
                            
                            if busStop.userName != nil {
                                Text(busStop.name)
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(5)
                })
                .buttonStyle(PlainButtonStyle())
        }
        .onDelete(perform: favouriteBusStopsViewModel.remove)
        .onMove(perform: favouriteBusStopsViewModel.move)
        
        Button(action: {
            isShowingAddView.toggle()
        }, label: {
            HStack {
                Image(systemName: "plus")
                
                Text("Dodaj")
            }
        })
        .sheet(isPresented: $isShowingAddView, content: {
            BusStopAddView()
        })
    }
}

struct BusStopAddView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var databaseHelper = DataBaseHelper()
    @ObservedObject var favouriteBusStopsViewModel = FavouriteBusStopsViewModel()
    @State private var searchText = ""
    @State private var busStops = [BusStop]()
    @State private var pickedBusStop: BusStop?
    
    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $searchText, placeholder: "Szukaj", onCommit: search)
                    .padding(.horizontal, 5)
                
                if searchText.isEmpty {
                    VStack {
                        Image(systemName: "magnifyingglass")
                            .font(.largeTitle)
                        Text("Wyszukaj przystanek autobusowy")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                } else {
                    List {
                        ForEach(busStops) { busStop in
                            Button(action: {
                                if favouriteBusStopsViewModel.busStops.contains(where: { $0.id == busStop.id }) {
                                    favouriteBusStopsViewModel.remove(id: busStop.id)
                                } else {
                                    pickedBusStop = busStop
                                }
                            }, label: {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(busStop.name)
                                            .font(.headline)
                                            .lineLimit(1)
                                        
                                        HStack {
                                            Image(systemName: "arrow.right")
                                            
                                            Text(busStop.destination)
                                        }
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: favouriteBusStopsViewModel.busStops.contains(where: { $0.id == busStop.id }) ? "heart.fill" : "heart")
                                }
                            })
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .listStyle(InsetListStyle())
                }
                
                Spacer()
            }
            .navigationTitle("Szukaj przystanku")
            .navigationBarItems(trailing: Button("Gotowe", action: {
                presentationMode.wrappedValue.dismiss()
            }))
        }
        .ignoresSafeArea(edges: .all)
        .sheet(item: $pickedBusStop) { item in
            BusStopConfirmationView(busStop: item)
        }
        .onChange(of: searchText) { newValue in
            search()
        }
    }
    
    func search() {
        busStops = databaseHelper.searchBusStops(text: searchText)
    }
}


struct BusStopConfirmationView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var favouriteBusStopsViewModel = FavouriteBusStopsViewModel()
    @State private var userName = ""
    let busStop: BusStop
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                Text(busStop.name)
                    .font(.headline)
                
                Text("Kierunki: \(busStop.destination)")
                
                Text("Lokalizacja: \(busStop.longitude), \(busStop.latitude)")
                
                TextField("Twoja nazwa dla przystanku", text: $userName, onCommit: addNewBusStop)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                if userName.count >= 20 {
                    HStack(spacing: 0) {
                        Image(systemName: "exclamationmark.circle")
                        
                        Text("Osiągnąłeś limit znaków")
                    }
                    .font(.footnote)
                    .foregroundColor(.red)
                }
                
                Spacer()
            }
            .padding(.horizontal)
            .onReceive(Just(userName)) { _ in limitText(20) }
            .navigationTitle("Dodaj nazwę")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarItems(trailing: Button("Zapisz", action: addNewBusStop))
        }
    }
    
    func addNewBusStop() {
        var newBusStop = busStop
        if userName == "" {
            newBusStop.userName = nil
        } else {
            newBusStop.userName = userName
        }
        favouriteBusStopsViewModel.add(newBusStop)
        presentationMode.wrappedValue.dismiss()
    }
    
    func limitText(_ upper: Int) {
        if userName.count > upper {
            userName = String(userName.prefix(upper))
        }
    }
}
