//
//  BusStopView.swift
//  tarBUS
//
//  Created by Kuba Florek on 29/01/2021.
//

import SwiftUI

struct BusStopView: View {
    let busStop: BusStop
    
    var body: some View {
        TabView {
            ScrollView {
                Text("Lorem ipsum")
            }
            
            PlanView(busStop: busStop)
        }
        .tabViewStyle(PageTabViewStyle())
        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
        .navigationBarItems(trailing:Menu(content: {
            Button(action: {
            }, label: {
                Label("Dodaj do ulubionych", systemImage: "heart")
            })
            
            Button(action: {
            }, label: {
                Label("Więcej informacji", systemImage: "info.circle")
            })
        }, label: {
            Image(systemName: "ellipsis.circle")
        }))
        .navigationTitle(busStop.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}
