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
