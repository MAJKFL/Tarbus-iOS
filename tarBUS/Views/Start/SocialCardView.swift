//
//  SocialCardView.swift
//  tarBUS
//
//  Created by Kuba Florek on 31/07/2021.
//

import SwiftUI

struct SocialsCardView: View {
    @Environment(\.openURL) var openURL
    
    let socialCardViewModel: SocialCardViewModel
    
    var body: some View {
        VStack {
            Image(socialCardViewModel.imageName)
                .resizable()
                .scaledToFit()
                .frame(width: UIScreen.main.bounds.width / 1.5)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(socialCardViewModel.title)
                    .font(.headline.weight(.bold))
                
                Text(socialCardViewModel.text)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal)
            
            Spacer()
            
            if let url = socialCardViewModel.url {
                HStack {
                    Spacer()
                    
                    Button(action: {
                        openURL(url)
                    }, label: {
                        Text("Przejdź")
                            .bold()
                            .foregroundColor(.white)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 20)
                            .background(Color.accentColor)
                            .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
                    })
                }
                .padding([.horizontal, .bottom])
            }
        }
        .frame(width: UIScreen.main.bounds.width / 1.5)
        .background(Color("BackgroundBlue"))
        .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
        .shadow(radius: 2, x: 2, y: 2)
        .padding()
    }
}
