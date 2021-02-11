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
                }
                .listStyle(InsetListStyle())
            }
            .navigationTitle("Wyszukaj")
        }
    }
}

