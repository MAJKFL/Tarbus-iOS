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
    @ObservedObject var companyHelper = CompanyHelper()
    @State private var deeplink: deeplinkModel?
    @State private var showBusStopFromDeeplink = false
    @State private var showWelcomeScreen = true
    
    var body: some View {
        UIKitTabView([
            UIKitTabView.Tab(view: StartView(), barItem: UITabBarItem(title: "Start", image: UIImage(systemName: "house.fill"), selectedImage: UIImage(systemName: "house.fill"))),
            UIKitTabView.Tab(view: LineListView(), barItem: UITabBarItem(title: "Linie", image: UIImage(systemName: "point.fill.topleft.down.curvedto.point.fill.bottomright.up"), selectedImage: UIImage(systemName: "point.fill.topleft.down.curvedto.point.fill.bottomright.up"))),
            UIKitTabView.Tab(view: MainMapView(), barItem: UITabBarItem(title: "Mapa", image: UIImage(systemName: "map"), selectedImage: UIImage(systemName: "map"))),
            UIKitTabView.Tab(view: SearchView(), barItem: UITabBarItem(title: "Szukaj", image: UIImage(systemName: "magnifyingglass"), selectedImage: UIImage(systemName: "magnifyingglass"))),
            UIKitTabView.Tab(view: SettingsView(), barItem: UITabBarItem(title: "Ustawienia", image: UIImage(systemName: "gear"), selectedImage: UIImage(systemName: "gear")))
        ])
        .fullScreenCover(isPresented: $showWelcomeScreen, onDismiss: showDeeplink) {
            WelcomeView()
        }
        .sheet(isPresented: $showBusStopFromDeeplink) {
            NavigationView {
                BusStopView(busStop: deeplink!.busStop!, filteredBusLines: deeplink?.filteredBusLines ?? [])
                    .ignoresSafeArea(.all)
            }
        }
        .onContinueUserActivity(NSUserActivityTypeBrowsingWeb) { userActivity in
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(1000)) {
                guard let url = userActivity.webpageURL else { return }
                handleDeepLink(url)
            }
        }
        .onOpenURL(perform: { url in
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(1000)) {
                handleDeepLink(url)
            }
        })
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
    
    func showDeeplink() {
        if deeplink != nil {
            showBusStopFromDeeplink = true
        }
    }
}
