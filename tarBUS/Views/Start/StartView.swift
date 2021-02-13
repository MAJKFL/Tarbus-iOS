//
//  ContentView.swift
//  tarBUS
//
//  Created by Kuba Florek on 13/01/2021.
//

import SwiftUI

struct StartView: View {
    @Environment(\.openURL) var openURL
    
    init() {
        UITableView.appearance().showsVerticalScrollIndicator = false
    }
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Ulubione linie autobusowe")) {
                    FavouriteBusLinesListView()
                }
                
                Section(header: Text("Ulubione przystanki")) {
                    FavouriteBusStopsListView()
                }
                
                Section(header: Text("Społeczność")) {
                    HStack {
                        Image("facebookCircle")
                            .resizable()
                            .scaledToFit()
                            .clipShape(Circle())
                            .frame(width: 50, height: 50)
                        
                        VStack(alignment: .leading) {
                            Text("Jesteśmy na Facebooku")
                                .font(.subheadline)
                            
                            Text("Dołącz do nas!")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            openURL(URL(string: "https://www.facebook.com/tarbus2021")!)
                        }, label: {
                            Text("PRZEJDŹ")
                                .foregroundColor(.white)
                                .bold()
                                .frame(width: 100, height: 40)
                                .background(Color("MainColor"))
                                .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
                        })
                        .buttonStyle(PlainButtonStyle())
                        .padding(.vertical, 5)
                    }
                }
                
                Section(header: Text("Inne")) {
                    NavigationLink("O aplikacji", destination: AboutView())
                    NavigationLink("Ustawienia", destination: SettingsView())
                }
            }
            .listStyle(GroupedListStyle())
            .navigationTitle("tarBUS")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                EditButton()
            }
        }
    }
}
