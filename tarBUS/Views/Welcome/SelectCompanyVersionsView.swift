//
//  SelectCompaniesView.swift
//  tarBUS
//
//  Created by Jakub Florek on 29/10/2021.
//

import SwiftUI
import SDWebImageSwiftUI

struct SelectCompanyVersionsView: View {
    @Binding var isFirstLaunch: Bool
    @ObservedObject var companyVersionHelper = CompanyHelper()
    @ObservedObject var viewModel = SelectedCompaniesViewModel()
    
    var body: some View {
        VStack(spacing: 40) {
            Text("Wybierz przewoźnika")
                .font(.largeTitle)
            
            Text("Możesz później zmienić tą opcję w ustawieniach aplikacji")
                .font(.headline)
                .multilineTextAlignment(.center)
            
            List {
                ForEach(companyVersionHelper.companies?.versions ?? []) { version in
                    Button {
                        if viewModel.versions.contains(where: { $0.subscribeCode == version.subscribeCode }) {
                            withAnimation(.easeInOut) {
                                viewModel.remove(id: version.id)
                            }
                        } else {
                            withAnimation(.easeInOut) {
                                viewModel.add(version)
                            }
                        }
                    } label: {
                        HStack {
                            Image(systemName: viewModel.versions.contains(where: { $0.subscribeCode == version.subscribeCode }) ? "checkmark.square.fill" : "square")
                                .foregroundColor(.secondary)
                            
                            WebImage(url: version.imgURL)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                            
                            VStack(alignment: .leading) {
                                Text(version.companyName)
                                
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
                isFirstLaunch = false
            } label: {
                Text("Potwierdź")
                    .buttonStyle(.plain)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(Color.accentColor)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .disabled(viewModel.versions.isEmpty)
        }
        .padding([.horizontal, .top])
    }
}
