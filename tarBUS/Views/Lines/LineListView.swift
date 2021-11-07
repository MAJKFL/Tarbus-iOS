//
//  RouteListView.swift
//  tarBUS
//
//  Created by Kuba Florek on 13/01/2021.
//

import SwiftUI
import SDWebImageSwiftUI

struct LineListView: View {
    @AppStorage("ButtonPressCounter") var buttonPressCounter = 0
    @ObservedObject var selectedCompaniesViewModel = SelectedCompaniesViewModel()
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
                ForEach(selectedCompaniesViewModel.versions) { company in
                    VStack(spacing: 15) {
                        HStack {
                            WebImage(url: company.imgURL)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                                .padding(.leading, 3)
                            
                            Text(company.companyName)
                                .font(.title)
                            
                            Spacer()
                        }
                        
                        LazyVGrid(columns: columns, spacing: 10) {
                            ForEach(busLines.filter({ $0.versionID == dataBaseHelper.getVersionId(subscribeCode: company.subscribeCode) })) { line in
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
                                    .shadow(radius: 2, x: 2, y: 2)
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
            }
            .navigationTitle("Linie")
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            selectedCompaniesViewModel.fetch()
            busLines = dataBaseHelper.getBusLines()
        }
    }
}
