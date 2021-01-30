//
//  BusStopView.swift
//  tarBUS
//
//  Created by Kuba Florek on 29/01/2021.
//

import SwiftUI

struct BusStopView: View {
    let busStop: BusStop
    @StateObject var dataBaseHelper = DataBaseHelper()
    @State private var showPlan = false
    
    var body: some View {
        VStack {
            if showPlan {
               PlanView(busStop: busStop)
            } else {
                ScrollView {
                    Text("Lorem ipsum")
                }
                    .transition(AnyTransition.opacity.combined(with: .move(edge: .trailing)))
            }
        }
        .navigationBarItems(trailing: Button(action: {
            withAnimation(.easeIn) { showPlan.toggle() }
        }, label: {
            Image(systemName: "calendar\(showPlan ? ".badge.exclamationmark" : "")")
        }))
        .navigationTitle(busStop.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}
