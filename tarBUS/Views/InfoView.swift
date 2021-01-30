//
//  InfoView.swift
//  tarBUS
//
//  Created by Kuba Florek on 13/01/2021.
//

import SwiftUI
import MessageUI

struct InfoView: View {
    @Environment(\.openURL) var openURL
    @State private var isShowingMailView = false
    @State var result: Result<MFMailComposeResult, Error>? = nil
    
    static let contacts = ["mail", "twitter", "github", "facebook"]
    static let links = ["twitter": "https://twitter.com/MAJKFL", "github": "https://github.com/MAJKFL", "facebook": "https://www.facebook.com/jakub.florek.98"]
    
    init() {
        UITableView.appearance().showsVerticalScrollIndicator = false
    }
    
    var body: some View {
        VStack {
            List {
                HStack {
                    Spacer()
                    
                    Image("logoVertical")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 250)
                    
                    Spacer()
                }
                
                VStack(alignment: .leading) {
                    Text("Informacje o aplikacji:")
                        .font(.headline)
                    
                    Text("Aplikacja tarBUS to mobilny rozkład jazdy dla nowych, pozamiejskich linii autobusowych. Stworzona z myślą o tych mieszkańcach okolic Tarnowa, co na co dzień przyzwyczajenie byli do dosyć nowoczesnych rozwiązań oferowanych nam przez linie miejskie, a przez zmianę na prywatnego przewoźnika - całkowicie stracili do nich dostęp")
                }
                
                VStack(alignment: .leading) {
                    Text("O nas:")
                        .font(.headline)
                    
                    Text("Jesteśny małą grupą głównie uczniów, studentów z Tarnowskich szkół. Chcemy pomóc mieszkańcom naszych miejscowości korzystającym z komunikacji publicznej w codziennych dojazdach zarówno do miasta jak i z miasta, dlatego też wspólnie stworzyliśmy narzędzie znacznie upraszczające na chociażby sprawdzenie godzin odjazdu autobusu. Idea przewodnika: Razem możemy sprawić nasze miasto lepszym miejscem!")
                }
                
                VStack(alignment: .leading) {
                    Text("Kontakt:")
                        .font(.headline)
                    
                    Text("Znalazłeś błąd? Chcesz podzielić się opinią, pomysłem na rozwój lub współpracę? Napisz do nas!")
                    
                    HStack {
                        Spacer()
                        
                        ForEach(Self.contacts, id: \.self) { contact in
                            Button(action: {
                                if contact == "mail" {
                                    isShowingMailView = true
                                } else {
                                    openURL(URL(string: (Self.links[contact]?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!)!)
                                }
                            }, label: {
                                Image(contact)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: UIScreen.main.bounds.width / 6, height: UIScreen.main.bounds.width / 6)
                                    .clipShape(RoundedRectangle(cornerRadius: 15))
                            })
                            .buttonStyle(PlainButtonStyle())
                            
                            Spacer()
                        }
                    }
                    .padding(.vertical)
                }
                
                Text("Wersja aplikacji: 1.0.0")
            }
            .sheet(isPresented: $isShowingMailView) {
                MailView(result: self.$result)
            }
            .listStyle(InsetListStyle())
            .navigationTitle("Informacje o aplikacji")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
