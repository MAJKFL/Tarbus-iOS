//
//  ContentView.swift
//  tarBUS
//
//  Created by Kuba Florek on 13/01/2021.
//

import SwiftUI

struct StartView: View {
    @Environment(\.openURL) var openURL
    
    init() {
        UITableView.appearance().showsVerticalScrollIndicator = false
    }
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Ulubione linie autobusowe")) {
                    FavouriteBusLinesListView()
                }
                
                Section(header: Text("Ulubione przystanki")) {
                    FavouriteBusStopsListView()
                }
                
                Section(header: Text("Społeczność")) {
                    SocialsView()
                }
                
                Section(header: Text("Inne")) {
                    NavigationLink("O aplikacji", destination: AboutView())
                    NavigationLink("Ustawienia", destination: SettingsView())
                }
            }
            .listStyle(GroupedListStyle())
            .navigationTitle("tarBUS")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                EditButton()
            }
        }
    }
}
