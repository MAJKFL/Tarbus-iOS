//
//  SearchBusStopsView.swift
//  tarBUS
//
//  Created by Kuba Florek on 08/02/2021.
//

import SwiftUI

struct SearchBusStopsView: View {
    @ObservedObject var databaseHelper = DataBaseHelper()
    @State private var busStops = [BusStop]()
    @State private var searchText = ""
    
    var body: some View {
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
                        NavigationLink(destination: BusStopView(busStop: busStop, filteredBusLines: []), label: {
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
        busStops = databaseHelper.searchBusStops(text: searchText)
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
