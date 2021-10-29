//
//  ChooseCarriersView.swift
//  tarBUS
//
//  Created by Jakub Florek on 29/10/2021.
//

import SwiftUI

struct ChooseCompaniesView: View {
    @State private var companies = [Int]()
    
    var body: some View {
        VStack(spacing: 40) {
            Text("Wybierz przewoźnika")
                .font(.largeTitle)
            
            Text("Możesz później zmienić tą opcję w ustawieniach aplikacji")
                .font(.headline)
                .multilineTextAlignment(.center)
            
            List {
                ForEach(1..<3, id: \.self) { company in
                    HStack {
                        Button {
                            if companies.contains(company) {
                                companies.removeAll(where: { $0 == company })
                            } else {
                                companies.append(company)
                            }
                        } label: {
                            Image(systemName: companies.contains(company) ? "checkmark.square" : "square")
                        }
                        .buttonStyle(.plain)
                        .foregroundColor(.secondary)

                        
                        Image("michalus")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                        
                        VStack(alignment: .leading) {
                            Text("Michalus")
                            
                            Text("Jakiś opis")
                                .font(.subheadline)
                                .lineLimit(1)
                        }
                        
                        Spacer()
                        
                        Button {
                        } label: {
                            Image(systemName: "info.circle")
                        }
                    }
                    .font(.headline)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 30))
        }
        .padding([.horizontal, .top])
    }
}

struct ChooseCarriersView_Previews: PreviewProvider {
    static var previews: some View {
        ChooseCompaniesView()
    }
}
