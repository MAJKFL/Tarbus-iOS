//
//  SearchTileView.swift
//  tarBUS
//
//  Created by Kuba Florek on 01/08/2021.
//

import SwiftUI

struct SearchTileView: View {
    
    let viewModel: SearchTileViewModel
    
    @ObservedObject var favouriteBusStopsViewModel = FavouriteBusStopsViewModel()
    
    @State private var animation = false
    @State private var isShowingAddView = false
    
    var body: some View {
        NavigationLink(destination: viewModel.destination) {
            ZStack {
                Image(viewModel.imageName)
                    .resizable()
                    .scaledToFill()
                
                Color("MainColor")
                    .opacity(viewModel.isRecomendation ? 0.3 : 0.6)
                
                
                VStack {
                    HStack {
                        Spacer()
                        
                        Image(systemName: "location.fill")
                            .font(.headline.weight(.heavy))
                            .opacity(viewModel.isRecomendation ? 1 : 0)
                    }
                    
                    Spacer()
                    
                    HStack {
                        Text(viewModel.title)
                            .lineLimit(2)
                        
                        Spacer()
                    }
                }
                .padding(10)
                .foregroundColor(.white)
                .font(viewModel.isRecomendation ? .footnote.weight(.heavy) : .headline.weight(.heavy))
                
                VStack {
                    HStack {
                        Spacer()
                        
                        Image(systemName: "location.fill")
                            .font(.headline.weight(.heavy))
                            .opacity(viewModel.isRecomendation ? 1 : 0)
                    }
                    
                    Spacer()
                    
                    HStack {
                        Text(viewModel.title)
                            .lineLimit(2)
                        
                        Spacer()
                    }
                }
                .padding(10)
                .foregroundColor(Color("MainColor"))
                .font(viewModel.isRecomendation ? .footnote.weight(.heavy) : .headline.weight(.heavy))
                .mask(
                    Rectangle()
                        .fill(
                            LinearGradient(gradient: .init(colors: [Color.white.opacity(0.4),Color.white.opacity(0.6),Color.white.opacity(0.4)]), startPoint: .top, endPoint: .bottom)
                        )
                        .rotationEffect(.init(degrees: 70))
                        .padding(20)
                        .offset(x: -250)
                        .offset(x: animation ? 500 : 0)
                )
                .onAppear {
                    if viewModel.isRecomendation {
                        withAnimation(Animation.linear(duration: 2).repeatForever(autoreverses: false)){
                            animation.toggle()
                        }
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .contextMenu {
                if viewModel.isRecomendation {
                    Button(action: {
                        if favouriteBusStopsViewModel.busStops.contains(where: { $0.id == viewModel.busStop?.id ?? 0 }) {
                            favouriteBusStopsViewModel.remove(id: viewModel.busStop?.id ?? 0)
                        } else {
                            isShowingAddView = true
                        }
                    }, label: {
                        Label(favouriteBusStopsViewModel.busStops.contains(where: { $0.id == viewModel.busStop?.id }) ? "Usuń z ulubionych" : "Dodaj do ulubionych", systemImage: favouriteBusStopsViewModel.busStops.contains(where: { $0.id == viewModel.busStop?.id }) ? "heart.fill" : "heart")
                    })
                    Button(action: actionSheet, label: { Label("Udostępnij", systemImage: "square.and.arrow.up") })
                }
            }
            .sheet(isPresented: $isShowingAddView, onDismiss: favouriteBusStopsViewModel.fetch) {
                BusStopConfirmationView(busStop: viewModel.busStop!)
            }
            .shadow(radius: 3, x: 3, y: 3)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    func actionSheet() {
        guard let urlShare = URL(string: "https://app.tarbus.pl/store?directFrom=schedule&busStopId=\(viewModel.busStop?.id ?? 0)") else { return }
        let activityVC = UIActivityViewController(activityItems: [urlShare], applicationActivities: nil)
        UIApplication.shared.windows.first?.rootViewController?.present(activityVC, animated: true, completion: nil)
    }
}
