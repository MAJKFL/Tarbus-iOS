//
//  tarBUSApp.swift
//  tarBUS
//
//  Created by Kuba Florek on 13/01/2021.
//

import SwiftUI

@main
struct tarBUSApp: App {
    @ObservedObject var dataBaseHelper = DataBaseHelper()
    
    var body: some Scene {
        WindowGroup {
            TabView {
                WelcomeView()
                    .tabItem {
                        Label("Start", systemImage: "house.fill")
                    }
                Text("Linie")
                    .tabItem {
                        Label("Linie", systemImage: "point.fill.topleft.down.curvedto.point.fill.bottomright.up")
                    }
                Text("Szukaj")
                    .tabItem {
                        Label("Szukaj", systemImage: "magnifyingglass")
                    }
            }
            .onAppear {
                dataBaseHelper.copyDatabaseIfNeeded()
                dataBaseHelper.fetchData()
            }
        }
    }
}
