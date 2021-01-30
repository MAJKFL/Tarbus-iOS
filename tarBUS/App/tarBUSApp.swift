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
            WelcomeView()
                .onAppear {
                    dataBaseHelper.copyDatabaseIfNeeded()
                    dataBaseHelper.fetchData()
                }
        }
    }
}
