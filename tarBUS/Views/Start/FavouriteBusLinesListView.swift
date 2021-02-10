//
//  FavouriteBusLineListView.swift
//  tarBUS
//
//  Created by Kuba Florek on 10/02/2021.
//

import SwiftUI

struct FavouriteBusLinesListView: View {
    @ObservedObject var favouriteBusLinesViewModel = FavouriteBusLinesViewModel()
    @State private var isShowingAddView = false
    
    var body: some View {
        ForEach(favouriteBusLinesViewModel.busLines) { busLine in
            NavigationLink(
                destination: RouteListView(busLine: busLine),
                label: {
                    HStack {
                        Image(systemName: "bus.fill")
                        
                        VStack(alignment: .leading) {
                            Text(busLine.name)
                            
                            Text("Michalus")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(5)
                })
                .buttonStyle(PlainButtonStyle())
        }
        .onDelete(perform: favouriteBusLinesViewModel.remove)
        .onMove(perform: favouriteBusLinesViewModel.move)
        
        Button(action: {
            isShowingAddView.toggle()
        }, label: {
            HStack {
                Image(systemName: "plus")
                
                Text("Dodaj")
            }
        })
        .sheet(isPresented: $isShowingAddView, content: {
            BusLineAddView()
        })
    }
}

struct BusLineAddView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var databaseHelper = DataBaseHelper()
    @ObservedObject var favouriteBusLinesViewModel = FavouriteBusLinesViewModel()
    @State private var searchText = ""
    @State private var busLines = [BusLine]()
    
    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $searchText, placeholder: "Szukaj", onCommit: search)
                    .padding(.horizontal, 5)
                
                if searchText.isEmpty {
                    VStack {
                        Image(systemName: "magnifyingglass")
                            .font(.largeTitle)
                        Text("Wyszukaj linię autobusową")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                } else {
                    List {
                        ForEach(busLines) { busLine in
                            Button(action: {
                                if favouriteBusLinesViewModel.busLines.contains(where: { $0.id == busLine.id }) {
                                    favouriteBusLinesViewModel.remove(id: busLine.id)
                                } else {
                                    favouriteBusLinesViewModel.add(busLine)
                                }
                            }, label: {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(busLine.name)
                                            .font(.headline)
                                            .lineLimit(1)
                                        
                                        Text("Michalus")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: favouriteBusLinesViewModel.busLines.contains(where: { $0.id == busLine.id }) ? "heart.fill" : "heart")
                                }
                            })
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .listStyle(InsetListStyle())
                }
                
                Spacer()
            }
            .navigationTitle("Szukaj linię")
            .navigationBarItems(trailing: Button("Gotowe", action: {
                presentationMode.wrappedValue.dismiss()
            }))
        }
        .ignoresSafeArea(edges: .all)
        .onChange(of: searchText) { newValue in
            search()
        }
    }
    
    func search() {
        busLines = databaseHelper.searchBusLines(text: searchText)
    }
}
