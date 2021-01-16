//
//  RouteListView.swift
//  tarBUS
//
//  Created by Kuba Florek on 13/01/2021.
//

import SwiftUI
import CoreData

struct LineListView: View {
    @FetchRequest(entity: BusLine.entity(), sortDescriptors: []) var busLines: FetchedResults<BusLine>
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ScrollView {
            VStack {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(busLines, id: \.self) { line in
                        NavigationLink(destination: Text(line.busLineName ?? ""), label: {
                            HStack {
                                Image(systemName: "bus.fill")
                                
                                Text(line.busLineName ?? "")
                            }
                            .font(Font.headline.weight(.bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, minHeight: 50)
                            .background(Color("MainColor"))
                            .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
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
}
