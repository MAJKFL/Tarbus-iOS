//
//  SearchBusLinesView.swift
//  tarBUS
//
//  Created by Kuba Florek on 08/02/2021.
//

import SwiftUI

struct SearchBusLinesView: View {
    @ObservedObject var databaseHeplper = DataBaseHelper()
    @State private var busLines = [BusLine]()
    @State private var searchText = ""
    
    var body: some View {
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
        busLines = databaseHeplper.searchBusLines(text: searchText)
    }
}
