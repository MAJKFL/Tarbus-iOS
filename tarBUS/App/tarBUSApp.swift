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
    @State private var showWelcomeScreen = true
    
    @State private var showDeeplink = false
    @State private var deeplinkURL: URL?
    
    var body: some View {
        NavigationView {
            ZStack {
                NavigationLink("", isActive: $showDeeplink) {
                    if let deeplinkURL = deeplinkURL {
                        if let deeplink = handleDeepLink(deeplinkURL) {
                            BusStopView(deeplink: deeplink)
                                .ignoresSafeArea(.all)
                        }
                    }
                }
                
                UIKitTabView([
                    UIKitTabView.Tab(view: StartView(), barItem: UITabBarItem(title: "Start", image: UIImage(systemName: "house.fill"), selectedImage: UIImage(systemName: "house.fill"))),
                    UIKitTabView.Tab(view: LineListView(), barItem: UITabBarItem(title: "Linie", image: UIImage(systemName: "point.fill.topleft.down.curvedto.point.fill.bottomright.up"), selectedImage: UIImage(systemName: "point.fill.topleft.down.curvedto.point.fill.bottomright.up"))),
                    UIKitTabView.Tab(view: MainMapView(), barItem: UITabBarItem(title: "Mapa", image: UIImage(systemName: "map"), selectedImage: UIImage(systemName: "map"))),
                    UIKitTabView.Tab(view: SearchView(), barItem: UITabBarItem(title: "Szukaj", image: UIImage(systemName: "magnifyingglass"), selectedImage: UIImage(systemName: "magnifyingglass"))),
                    UIKitTabView.Tab(view: SettingsView(), barItem: UITabBarItem(title: "Ustawienia", image: UIImage(systemName: "gear"), selectedImage: UIImage(systemName: "gear")))
                ])
            }
                .navigationBarHidden(true)
        }
        .fullScreenCover(isPresented: $showWelcomeScreen) {
            WelcomeView()
        }
        .onContinueUserActivity(NSUserActivityTypeBrowsingWeb) { userActivity in
            guard let url = userActivity.webpageURL else { return }
            deeplinkURL = url
            showDeeplink = true
        }
        .onOpenURL(perform: { url in
            deeplinkURL = url
            showDeeplink = true
        })
    }
    
    func handleDeepLink(_ url: URL) -> Deeplink? {
        let databaseHelper = DataBaseHelper()
        
        guard let str = url.valueOf("busStopId") else { return nil }
        guard let busStopId = Int(str) else { return nil }
        guard let busStop = databaseHelper.getBusStopBy(id: busStopId) else { return nil }
        
        var deeplink = Deeplink(busStop: busStop)
        
        if let busLineIdStr = url.valueOf("busLineId") {
            if let busLineId = Int(busLineIdStr) {
                if let busLine = databaseHelper.getBusLine(busLineId: busLineId) {
                    deeplink.filteredBusLines.append(busLine)
                }
            }
        }
        
        return deeplink
    }
}
