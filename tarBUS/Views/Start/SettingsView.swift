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
                Text("Ostatnia aktualizacja: \(lastUpdate)")
            }
            
            Section(header: Text("Informacje o aplikacji tarBUS")) {
                Text("Wersja 2.1.1")
            }
        }
        .onAppear {
            databaseHelper.saveLastUpdateToUserDefaults()
        }
        .listStyle(GroupedListStyle())
        .navigationTitle("Ustawienia")
    }
}
