//
//  ContentView.swift
//  tarBUS
//
//  Created by Kuba Florek on 13/01/2021.
//

import SwiftUI
import StoreKit

struct StartView: View {
    @Environment(\.openURL) var openURL
    @AppStorage("ButtonPressCounter") var buttonPressCounter = 0
    @AppStorage("IsAppRated") var isAppRated = false
    
    init() {
        UITableView.appearance().showsVerticalScrollIndicator = false
        UITableView.appearance().backgroundColor = UIColor(named: "BackgroundBlue")
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
                
                if buttonPressCounter > 10 && !isAppRated {
                    Section(header: Text("Pomóż rozwijać tarBUSa!")) {
                        Button("Oceń aplikację") {
                            SKStoreReviewController.requestReviewInCurrentScene()
                            withAnimation { isAppRated = true }
                        }
                    }
                }
                
                Section(header: Text("Społeczność")) {
                    SocialsView()
                }
                
//                Section(header: Text("Inne")) {
//                    NavigationLink("O aplikacji", destination: AboutView())
//                    NavigationLink("Ustawienia", destination: SettingsView())
//                }
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
