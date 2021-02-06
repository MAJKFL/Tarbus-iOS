//
//  SearchView.swift
//  tarBUS
//
//  Created by Kuba Florek on 06/02/2021.
//

import SwiftUI

struct SearchPickerView: View {
    var body: some View {
        NavigationView {
            VStack {
                List {
                    NavigationLink(destination: SearchBusLinesView(), label: {
                        HStack {
                            Image(systemName: "magnifyingglass")
                            
                            VStack(alignment: .leading) {
                                Text("Wyszukaj linie autobusowe")
                                
                                Text("Kliknij aby wyszukać")
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 5)
                    })
                    
                    NavigationLink(destination: SearchBusStopsView(), label: {
                        HStack {
                            Image(systemName: "magnifyingglass")
                            
                            VStack(alignment: .leading) {
                                Text("Wyszukaj przystanki")
                                
                                Text("Kliknij aby wyszukać")
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 5)
                    })
                }
                .listStyle(InsetListStyle())
            }
            .navigationTitle("Wyszukaj")
        }
    }
}

struct SearchBusStopsView: View {
    @ObservedObject var databaseHeplper = DataBaseHelper()
    @State private var busStops = [BusStop]()
    @State private var searchText = ""
    
    var body: some View {
        VStack {
            SearchBar(text: $searchText, placeholder: "Szukaj", onCommit: search)
            
            if searchText.isEmpty {
                Image(systemName: "magnifyingglass")
                    .font(.largeTitle)
                Text("Wyszukaj przystanek autobusowy")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            } else {
                List {
                    ForEach(busStops) { busStop in
                        NavigationLink(destination: BusStopView(busStop: busStop), label: {
                            HStack {
                                Image("busStop")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .blending(color: Color("MainColor"))
                                    .frame(width: 25)
                                
                                Text(busStop.name)
                                    .font(.headline)
                                    .lineLimit(1)
                            }
                        })
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            
            Spacer()
        }
        .onChange(of: searchText) { newValue in
            search()
        }
        .navigationTitle("Szukaj przystanku")
    }
    
    func search() {
        withAnimation(.easeIn) { busStops = databaseHeplper.searchBusStops(text: searchText) }
    }
}

struct SearchBusLinesView: View {
    @ObservedObject var databaseHeplper = DataBaseHelper()
    @State private var busLines = [BusLine]()
    @State private var searchText = ""
    
    var body: some View {
        VStack {
            SearchBar(text: $searchText, placeholder: "Szukaj", onCommit: search)
            
            if searchText.isEmpty {
                Image(systemName: "magnifyingglass")
                    .font(.largeTitle)
                Text("Wyszukaj linię autobusową")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            } else {
                List {
                    ForEach(busLines) { busLine in
                        NavigationLink(destination: RouteListView(busLine: busLine), label: {
                            HStack {
                                Image(systemName: "bus.fill")
                                    .foregroundColor(Color("MainColor"))
                                    .font(Font.body.weight(.black))
                                
                                Text(busLine.name)
                                    .font(.headline)
                                    .lineLimit(1)
                            }
                        })
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            
            Spacer()
        }
        .onChange(of: searchText) { newValue in
            search()
        }
        .navigationTitle("Szukaj linię")
    }
    
    func search() {
        withAnimation(.easeIn) { busLines = databaseHeplper.searchBusLines(text: searchText) }
    }
}

public struct ColorBlended: ViewModifier {
    fileprivate var color: Color
  
    public func body(content: Content) -> some View {
    VStack {
        ZStack {
            content
            color.blendMode(.sourceAtop)
        }
        .drawingGroup(opaque: false)
        }
    }
}

extension View {
    public func blending(color: Color) -> some View {
        modifier(ColorBlended(color: color))
    }
}
