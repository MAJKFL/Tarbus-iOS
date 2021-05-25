//
//  DevMenuView.swift
//  tarBUS
//
//  Created by Kuba Florek on 25/05/2021.
//

import SwiftUI

struct DevMenuView: View {
    @ObservedObject var databaseHelper = DataBaseHelper()
    
    var body: some View {
        Section(header: Text("Debug Menu")) {
            Button("Fetch data", action: databaseHelper.fetchData)
            Button("Delete all data", action: databaseHelper.deleteAllData)
            Button("Reset defaults", action: resetDefaults)
        }
        .foregroundColor(Color("DebugPink"))
    }
    
    func resetDefaults() {
        let defaults = UserDefaults.standard
        let dictionary = defaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            defaults.removeObject(forKey: key)
        }
    }
}
