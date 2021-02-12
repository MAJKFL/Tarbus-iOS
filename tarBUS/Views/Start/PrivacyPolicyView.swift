//
//  PrivacyPolicyView.swift
//  tarBUS
//
//  Created by Kuba Florek on 09/02/2021.
//

import SwiftUI

struct PrivacyPolicyView: View {
    @Environment(\.openURL) var openURL
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 10) {
                    Image("logoHorizontal")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 75)
                    
                    Text("1. Licencja")
                        .font(.title)
                    
                    Text("1.1. Używanie aplikacji tarBUS jest bezpłatne")
                    
                    VStack(alignment: .leading, spacing: 0) {
                        Text("1.2. Zabrania się wykorzystywanie aplikacji do celów komercyjnych bez wiedzy i pisemnej zgody")
                        
                        Button("osoby zarządzającej projektem", action: {
                            openURL(URL(string: "https://www.facebook.com/dpajak99")!)
                        })
                    }
                    
                    VStack(alignment: .leading, spacing: 0) {
                        Text("1.3. Zabrania się wykorzystywania bazy danych oraz API aplikacji do celów innych niż wyświelanie jej zawartości w aplikacji tarBUS, bez wiedzy i pisemnej zgody")
                        
                        Button("osoby zarządzającej projektem", action: {
                            openURL(URL(string: "https://www.facebook.com/dpajak99")!)
                        })
                    }
                    
                    Text("1.3. Twórcy aplikacji tarBUS dołożyli wszelkich starań aby działała ona prawidłowo. Autorzy nie ponoszą jednak w żadnym przypadku jakiejkolwiek odpowiedzialności za szkody pośrednie lub bezpośrednie, poniesione przez użytkownika, bądź osoby trzecie, wynikłe  z użytkowania, lub braku możliwości użytkowania oprogramowania, niezależnie od tego, w jaki sposób te szkody powstały i czego dotyczą.")
                    
                    Text("1.4. Kod źródłowy aplikacji dostępny jest na platformie GitHub,  gdzie użytkownicy mogą nieodpłatnie wspomóc rozwój aplikacji.")
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("2. Zbieranie i wykorzystywanie informacji")
                        .font(.title)
                    
                    Text("2.1.  Aplikacja korzysta z usług stron trzecich, które mogą zbierać  informacje używane do identyfikacji użytkownika. \nLinki do polityki prywatności dostawców usług zewnętrznych  używanych przez aplikację:")
                    
                    Button(" - Usługi App Store", action: {
                        openURL(URL(string: "https://www.apple.com/pl/")!)
                    })
                }
            }
            .padding([.horizontal, .bottom])
        }
        .navigationTitle("Polityka prywatności")
        .navigationBarTitleDisplayMode(.large)
    }
}
