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
    @State private var showAlert = false
    @State private var busStop: BusStop?
    
    var body: some Scene {
        WindowGroup {
            UIKitTabView([
                UIKitTabView.Tab(view: StartView(), barItem: UITabBarItem(title: "Start", image: UIImage(systemName: "house.fill"), selectedImage: UIImage(systemName: "house.fill"))),
                UIKitTabView.Tab(view: LineListView(), barItem: UITabBarItem(title: "Linie", image: UIImage(systemName: "point.fill.topleft.down.curvedto.point.fill.bottomright.up"), selectedImage: UIImage(systemName: "point.fill.topleft.down.curvedto.point.fill.bottomright.up"))),
                UIKitTabView.Tab(view: BusStopMapView(), barItem: UITabBarItem(title: "Mapa", image: UIImage(systemName: "map"), selectedImage: UIImage(systemName: "map"))),
                UIKitTabView.Tab(view: SearchPickerView(), barItem: UITabBarItem(title: "Szukaj", image: UIImage(systemName: "magnifyingglass"), selectedImage: UIImage(systemName: "magnifyingglass")))
            ])
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Brak połączenia z internetem"), message: Text("Nie możemy sprawdzić czy rozkład jazdy jest aktualny! Możesz kontynuować w trybie offline lub spróbować ponownie"), primaryButton: .default(Text("Sprawdź ponownie"), action: databaseInit), secondaryButton: .cancel(Text("OK")))
            }
            .sheet(item: $busStop) { busStop in
                NavigationView {
                    BusStopView(busStop: busStop, filteredBusLines: [])
                        .ignoresSafeArea(.all)
                }
            }
            .onAppear(perform: databaseInit)
            .onOpenURL(perform: { url in
                if let str = url.valueOf("busStopId") {
                    if let busStopId = Int(str) {
                        busStop = dataBaseHelper.getBusStopBy(id: busStopId)
                    }
                }
            })
        }
    }
    
    func databaseInit() {
        dataBaseHelper.copyDatabaseIfNeeded()
        if ReachabilityTest.isConnectedToNetwork() {
            dataBaseHelper.saveLastUpdateToUserDefaults()
            dataBaseHelper.fetchData()
        } else{
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(100)) {
                showAlert = true
            }
        }
    }
}
