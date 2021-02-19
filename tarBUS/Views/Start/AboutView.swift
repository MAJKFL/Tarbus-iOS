//
//  InfoView.swift
//  tarBUS
//
//  Created by Kuba Florek on 13/01/2021.
//

import SwiftUI
import MessageUI

struct AboutView: View {
    enum Mail: String, Identifiable {
        case developer = "kubaflor23@gmail.com"
        case tarbus = "dominik00801@gmail.com"
        
        var id: String {
            self.rawValue
        }
    }
    
    @Environment(\.openURL) var openURL
    @State private var mail: Mail?
    @State var result: Result<MFMailComposeResult, Error>? = nil
    
    static let contactsToDeveloper = ["facebook", "linkedin", "mail", "github"]
    static let linksToDeveloper = ["linkedin": "https://www.linkedin.com/in/jakub-florek-ba9378207/", "github": "https://github.com/MAJKFL", "facebook": "https://www.facebook.com/jakub.florek.98"]
    
    static let contactsToApp = ["facebook", "mail", "github"]
    static let linksToApp = ["github": "https://github.com/MAJKFL/Tarbus-iOS", "facebook": "https://www.facebook.com/tarbus2021"]
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 15) {
                VStack(alignment: .leading) {
                    Text("Rozkład jazdy dla nowych linii autobusowych wyjeżdżających poza granice Tarnowa. Aplikacja została stworzona została z myślą o tych mieszkańcach okolic Tarnowa, co na co dzień przyzwyczajeni byli do dosyć nowoczesnych rozwiązań oferowanych przez linie miejskie, a przez zmianę na prywatnego przewoźnika - całkowicie stracili do nich dostęp.")
                        .font(.subheadline)
                }
                
                VStack(alignment: .leading, spacing: 5) {
                    Text("O autorach")
                        .font(.headline)
                    
                    Text("Jesteśmy małą grupką uczniów i studentów z tarnowskich szkół. Chcemy pomóc mieszkańcom naszych miejscowości w codziennym życiu. Naszym pierwszym projektem jest aplikacja tarBUS, która  wspomaga i upraszcza podróże komunikacją zbiorową na terenie miasta i gmin ościennych. Nasza idea przewodnia: Razem możemy uczynić nasze miasto lepszym miejscem!  ")
                        .font(.subheadline)
                }
                
                VStack(alignment: .leading, spacing: 5) {
                    Text("Kontakt z deweloperem")
                        .font(.headline)
                    
                    Text("Znalazłeś błąd? Masz pytania odnośnie działania aplikacji? Za dział iOS odpowiada Jakub Florek.")
                        .font(.subheadline)
                    
                    HStack {
                        Spacer()
                        
                        ForEach(Self.contactsToDeveloper, id: \.self) { contact in
                            Button(action: {
                                if contact == "mail" {
                                    mail = .developer
                                } else {
                                    openURL(URL(string: (Self.linksToDeveloper[contact]?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!)!)
                                }
                            }, label: {
                                Image(contact)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: UIScreen.main.bounds.width / 6, height: UIScreen.main.bounds.width / 6)
                                    .clipShape(RoundedRectangle(cornerRadius: 15))
                            })
                            .buttonStyle(PlainButtonStyle())
                            .contextMenu {
                                Button(action: {
                                    if contact == "mail" {
                                        UIPasteboard.general.string = Mail.developer.rawValue
                                    } else {
                                        UIPasteboard.general.string = Self.linksToDeveloper[contact]!
                                    }
                                }, label: {
                                    Label("Skopiuj do schowka", systemImage: "doc.on.doc")
                                })
                            }
                            
                            Spacer()
                        }
                    }
                    .padding(.vertical)
                }
                
                VStack(alignment: .leading, spacing: 5) {
                    Text("Współpraca")
                        .font(.headline)
                    
                    Text("Chciałbyś wspomóc rozwój aplikacji? Zapraszamy do kontaktu!")
                        .font(.subheadline)
                    
                    HStack {
                        Spacer()
                        
                        ForEach(Self.contactsToApp, id: \.self) { contact in
                            Button(action: {
                                if contact == "mail" {
                                    mail = .tarbus
                                } else {
                                    openURL(URL(string: (Self.linksToApp[contact]?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!)!)
                                }
                            }, label: {
                                Image(contact)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: UIScreen.main.bounds.width / 6, height: UIScreen.main.bounds.width / 6)
                                    .clipShape(RoundedRectangle(cornerRadius: 15))
                            })
                            .buttonStyle(PlainButtonStyle())
                            .contextMenu {
                                Button(action: {
                                    if contact == "mail" {
                                        UIPasteboard.general.string = Mail.tarbus.rawValue
                                    } else {
                                        UIPasteboard.general.string = Self.linksToApp[contact]!
                                    }
                                }, label: {
                                    Label("Skopiuj do schowka", systemImage: "doc.on.doc")
                                })
                            }
                            
                            Spacer()
                        }
                    }
                    .padding(.vertical)
                }
            }
            .padding(.horizontal)
            .sheet(item: $mail) { mail in
                MailView(result: self.$result, mail: mail.rawValue)
            }
            .listStyle(PlainListStyle())
            .navigationTitle("O aplikacji")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}
