//
//  SelectCompaniesView.swift
//  tarBUS
//
//  Created by Jakub Florek on 29/10/2021.
//

import SwiftUI
import SDWebImageSwiftUI

struct SelectCompaniesView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var companyVersionHelper = CompanyVersionHelper()
    @ObservedObject var viewModel = SelectedCompaniesViewModel()
    
    var body: some View {
        VStack(spacing: 40) {
            Text("Wybierz przewoźnika")
                .font(.largeTitle)
            
            Text("Możesz później zmienić tą opcję w ustawieniach aplikacji")
                .font(.headline)
                .multilineTextAlignment(.center)
            
            List {
                ForEach(companyVersionHelper.companies?.versions ?? []) { company in
                    Button {
                        if viewModel.companies.contains(where: { $0.subscribeCode == company.subscribeCode }) {
                            withAnimation(.easeInOut) {
                                viewModel.remove(id: company.id)
                            }
                        } else {
                            withAnimation(.easeInOut) {
                                viewModel.add(company)
                            }
                        }
                    } label: {
                        HStack {
                            Image(systemName: viewModel.companies.contains(where: { $0.subscribeCode == company.subscribeCode }) ? "checkmark.square.fill" : "square")
                                .foregroundColor(.secondary)
                            
                            WebImage(url: company.imgURL)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                            
                            VStack(alignment: .leading) {
                                Text(company.companyName)
                                
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
                    .buttonStyle(.plain)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 30))
            
            Button {
                presentationMode.wrappedValue.dismiss()
            } label: {
                Text("Potwierdź")
                    .buttonStyle(.plain)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(Color.accentColor)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .disabled(viewModel.companies.isEmpty)
        }
        .padding([.horizontal, .top])
    }
}

struct ChooseCarriersView_Previews: PreviewProvider {
    static var previews: some View {
        SelectCompaniesView()
    }
}
