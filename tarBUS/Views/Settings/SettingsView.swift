//
//  SettingsView.swift
//  tarBUS
//
//  Created by Kuba Florek on 21/05/2021.
//

import SwiftUI
import StoreKit

struct SettingsView: View {
    @ObservedObject var databaseHelper = DataBaseHelper()
    
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
                
                Section(header: Text("Polityka prywatności")) {
                    NavigationLink(destination: PrivacyPolicyView(), label: {
                        VStack {
                            Text("Polityka prywatności")
                        }
                    })
                    .buttonStyle(PlainButtonStyle())
                }
                
                Section(header: Text("Informacje o aplikacji tarBUS")) {
                    HStack {
                        Text("Wersja aplikacji")
                        
                        Spacer()
                        
                        Text(appVersionString)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .listStyle(GroupedListStyle())
            .navigationTitle("Ustawienia")
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
