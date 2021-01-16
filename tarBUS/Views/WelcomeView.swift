//
//  ContentView.swift
//  tarBUS
//
//  Created by Kuba Florek on 13/01/2021.
//

import SwiftUI
import CoreData

struct WelcomeView: View {
    @StateObject var welcomeVM = WelcomeViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                Image("logoHorizontal")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 150)
                
                Text(welcomeVM.message?.message ?? "")
                    .font(.body)
                    .padding(.horizontal)
                
                VStack(alignment: .leading) {
                    Divider()
                    
                    NavigationLink(destination: LineListView(), label: {
                        HStack(spacing: 20) {
                            Image(systemName: "bus.fill")
                            
                            Text("Linie autobusowe")
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                    })
                    
                    Divider()
                    
                    NavigationLink(destination: Text("Szukaj przystanku"), label: {
                        HStack(spacing: 20) {
                            Image(systemName: "magnifyingglass")
                            
                            Text("Szukaj przystanku")
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                    })
                    
                    Divider()
                    
                    NavigationLink(destination: InfoView(), label: {
                        HStack(spacing: 20) {
                            Image(systemName: "info.circle.fill")
                            
                            Text("Informacje o aplikacji")
                        }
                        
                        Spacer()
                    })
                    .padding(.horizontal)
                    
                    Divider()
                }
                
                Text("Data ostatniej aktualizacji: \(welcomeVM.lastUpdate?.formatted ?? "")")
                    .font(.footnote)
                
                Spacer()
            }
            .font(.title)
            .onAppear {
                welcomeVM.fetchMessage()
                welcomeVM.fetchLastUpdate()
            }
            .navigationTitle("Rozkład jazdy GKP")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
