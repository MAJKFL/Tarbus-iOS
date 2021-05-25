//
//  SettingsView.swift
//  tarBUS
//
//  Created by Kuba Florek on 21/05/2021.
//

import SwiftUI
import StoreKit

struct SettingsTabView: View {
    @ObservedObject var databaseHelper = DataBaseHelper()
    @AppStorage("LastUpdate") var lastUpdate = ""
    
    let appVersionString: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("O nas")) {
                    NavigationLink("O aplikacji", destination: AboutView())
                }
                
                Section(header: Text("Pomóż rozwijać tarBUSa!")) {
                    Button("Oceń aplikację") {
                        SKStoreReviewController.requestReviewInCurrentScene()
                    }
                }
                
                Section(header: Text("Panel informacyjny")) {
                    NavigationLink("Ustawienia panelu informacyjnego", destination: Text("Ustawienia panelu informacji"))
                }
                
                Section(header: Text("Polityka prywatności")) {
                    NavigationLink(destination: PrivacyPolicyView(), label: {
                        VStack {
                            Text("Polityka prywatności")
                        }
                    })
                    .buttonStyle(PlainButtonStyle())
                }
                
                Section(header: Text("Baza danych")) {
                    HStack {
                        Text("Ostatnia aktualizacja")
                        
                        Spacer()
                        
                        Text(lastUpdate)
                            .foregroundColor(.secondary)
                    }
                }
                
                Section(header: Text("Informacje o aplikacji tarBUS")) {
                    HStack {
                        Text("Wersja aplikacji")
                        
                        Spacer()
                        
                        #if DEBUG
                        Text("\(appVersionString) DEBUG")
                            .foregroundColor(Color("DebugPink"))
                        #else
                        Text(appVersionString)
                            .foregroundColor(.secondary)
                        #endif
                    }
                }
                
                #if DEBUG
                DevMenuView()
                #endif
            }
            .listStyle(GroupedListStyle())
            .navigationTitle("Ustawienia")
        }
    }
}

