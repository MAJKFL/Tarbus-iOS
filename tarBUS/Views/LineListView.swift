//
//  RouteListView.swift
//  tarBUS
//
//  Created by Kuba Florek on 13/01/2021.
//

import SwiftUI

struct LineListView: View {
    @ObservedObject var dataBaseHelper = DataBaseHelper()
    @State private var busLines = [BusLine]()
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(busLines) { line in
                            NavigationLink(destination: RouteListView(busLine: line), label: {
                                HStack {
                                    Image(systemName: "bus.fill")
                                    
                                    Text(line.name)
                                }
                                .font(Font.headline.weight(.bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, minHeight: 50)
                                .background(Color("MainColor"))
                                .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
                                .shadow(radius: 3, x: 3, y: 3)
                            })
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Linie Autobusowe")
        }
        .onAppear {
            busLines = dataBaseHelper.getBusLines()
        }
    }
}
