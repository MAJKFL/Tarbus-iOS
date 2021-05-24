//
//  RouteListView.swift
//  tarBUS
//
//  Created by Kuba Florek on 13/01/2021.
//

import SwiftUI

struct LineListView: View {
    @AppStorage("ButtonPressCounter") var buttonPressCounter = 0
    @ObservedObject var dataBaseHelper = DataBaseHelper()
    @State private var busLines = [BusLine]()
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 15) {
                    HStack {
                        Image("michalus")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                            .padding(.leading, 3)
                        
                        Text("Michalus")
                            .font(.largeTitle)
                        
                        Spacer()
                    }
                    .padding(2)
                    .background(Color("lightGray"))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .shadow(radius: 3, x: 3, y: 3)
                    
                    LazyVGrid(columns: columns, spacing: 10) {
                        ForEach(busLines) { line in
                            NavigationLink(destination: RouteListView(busLine: line)) {
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
                            }
                            .simultaneousGesture(TapGesture().onEnded {
                                buttonPressCounter += 1
                            })
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Linie")
        }
        .onAppear {
            busLines = dataBaseHelper.getBusLines()
        }
    }
}
