//
//  SettingsView.swift
//  tarBUS
//
//  Created by Kuba Florek on 09/02/2021.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var databaseHelper = DataBaseHelper()
    @AppStorage("LastUpdate") var lastUpdate = ""
    
    let appVersionString: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    
    var body: some View {
        List {
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
                    
                    Text(appVersionString)
                        .foregroundColor(.secondary)
                }
            }
        }
        .listStyle(GroupedListStyle())
        .navigationTitle("Ustawienia")
    }
}
