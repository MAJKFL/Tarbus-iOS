//
//  tarBUSApp.swift
//  tarBUS
//
//  Created by Kuba Florek on 13/01/2021.
//

import SwiftUI

@main
struct tarBUSApp: App {
    var body: some Scene {
        WindowGroup {
            MainView()
        }
    }
}

struct MainView: View {
    private struct deeplinkModel: Identifiable {
        var id = UUID()
        var busStop: BusStop?
        var busLine: BusLine?
        
        var filteredBusLines: [BusLine] {
            if let busLine = busLine {
                return [busLine]
            }
            return []
        }
    }
    
    @ObservedObject var dataBaseHelper = DataBaseHelper()
    @State private var deeplink: deeplinkModel?
    @State private var showAlert = false
    
    var body: some View {
        UIKitTabView([
            UIKitTabView.Tab(view: StartView(), barItem: UITabBarItem(title: "Start", image: UIImage(systemName: "house.fill"), selectedImage: UIImage(systemName: "house.fill"))),
            UIKitTabView.Tab(view: LineListView(), barItem: UITabBarItem(title: "Linie", image: UIImage(systemName: "point.fill.topleft.down.curvedto.point.fill.bottomright.up"), selectedImage: UIImage(systemName: "point.fill.topleft.down.curvedto.point.fill.bottomright.up"))),
            UIKitTabView.Tab(view: MainMapView(), barItem: UITabBarItem(title: "Mapa", image: UIImage(systemName: "map"), selectedImage: UIImage(systemName: "map"))),
            UIKitTabView.Tab(view: SearchView(), barItem: UITabBarItem(title: "Szukaj", image: UIImage(systemName: "magnifyingglass"), selectedImage: UIImage(systemName: "magnifyingglass"))),
            UIKitTabView.Tab(view: SettingsView(), barItem: UITabBarItem(title: "Ustawienia", image: UIImage(systemName: "gear"), selectedImage: UIImage(systemName: "gear")))
        ])
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Brak połączenia z internetem"), message: Text("Nie możemy sprawdzić czy rozkład jazdy jest aktualny! Możesz kontynuować w trybie offline lub spróbować ponownie"), primaryButton: .default(Text("Sprawdź ponownie"), action: databaseInit), secondaryButton: .cancel(Text("OK")))
        }
        .sheet(item: $deeplink) { deeplink in
            NavigationView {
                BusStopView(busStop: deeplink.busStop!, filteredBusLines: deeplink.filteredBusLines)
                    .ignoresSafeArea(.all)
            }
        }
        .onContinueUserActivity(NSUserActivityTypeBrowsingWeb) { userActivity in
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(200)) {
                guard let url = userActivity.webpageURL else { return }
                handleDeepLink(url)
            }
        }
        .onOpenURL(perform: { url in
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(200)) {
                handleDeepLink(url)
            }
        })
        .onAppear(perform: databaseInit)
    }
    
    func databaseInit() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(300)) {
            if deeplink == nil {
                dataBaseHelper.copyDatabaseIfNeeded()
                if ReachabilityTest.isConnectedToNetwork() {
                    dataBaseHelper.saveLastUpdateToUserDefaults()
                    dataBaseHelper.fetchData()
                } else {
                    showAlert = true
                }
            }
        }
    }
    
    func handleDeepLink(_ url: URL) {
        if let str = url.valueOf("busStopId") {
            var deeplinkData = deeplinkModel()
            
            if let busStopId = Int(str) {
                deeplinkData.busStop = dataBaseHelper.getBusStopBy(id: busStopId)
            }
            
            if let busLineIdStr = url.valueOf("busLineId") {
                if let busLineId = Int(busLineIdStr) {
                    deeplinkData.busLine = dataBaseHelper.getBusLine(busLineId: busLineId)
                }
            }
            
            deeplink = deeplinkData
        }
    }
}
