//
//  SearchTileView.swift
//  tarBUS
//
//  Created by Kuba Florek on 01/08/2021.
//

import SwiftUI

struct SearchTileView: View {
    
    let viewModel: SearchTileViewModel
    
    @State private var animation = false
    
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
            .shadow(radius: 3, x: 3, y: 3)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
