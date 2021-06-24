//
//  SocialsView.swift
//  tarBUS
//
//  Created by Kuba Florek on 21/05/2021.
//

import SwiftUI

struct SocialsView: View {
    let cards: [SocialCardViewModel] = [
        SocialCardViewModel(imageName: "BuyMeACoffeHeader", title: "Kup nam kawę", text: "tarBUS powstał, aby ułatwić nam codzienne przejazdy komunikacją publiczną. Jeżeli podoba Ci się nasza praca, możesz nas wesprzeć poprzez symboliczną wpłatę", urlString: "https://www.buymeacoffee.com/tarbus"),
        SocialCardViewModel(imageName: "FacebookHeader", title: "Jesteśmy na Facebooku", text: "Polub nas, aby być na bieżąco z informacjami na temat aplikacji, aktualizacji i zmian", urlString: "https://www.facebook.com/tarbus2021/")
    ]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(cards) { socialCardViewModel in
                    SocialsCardView(socialCardViewModel: socialCardViewModel)
                }
            }
        }
        .listRowInsets(EdgeInsets())
    }
}

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

struct SocialCardViewModel: Identifiable {
    let id = UUID()
    let imageName: String
    let title: String
    let text: String
    let urlString: String
    
    var url: URL? {
        URL(string: urlString)
    }
}
