//
//  WelcomeView.swift
//  tarBUS
//
//  Created by Jakub Florek on 04/11/2021.
//

import SwiftUI

struct WelcomeView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @StateObject var databaseRepository = DatabaseRepository()
    
    @AppStorage("IsFirstLaunch") var isFirstLaunch = true
    @State private var showAlert = false
    @State private var fetchFailed = false
    
    var body: some View {
        if isFirstLaunch {
            SelectCompanyVersionsView(isFirstLaunch: $isFirstLaunch)
        } else {
            VStack {
                Image("logoHorizontal")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 100)
                
                Button("URUCHOM W TRYBIE OFFLINE") {
                    print(databaseRepository.status)
                }
                .font(.subheadline)
                
                if fetchFailed {
                    Image(systemName: "exclamationmark.circle")
                        .foregroundColor(.red)
                    
                    Text("Błąd aktualizacji rozkladu jazdy")
                        .font(.subheadline)
                        .foregroundColor(.red)
                } else {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                    
                    Text("Trwa aktualizowanie rozkładu jazdy")
                        .font(.subheadline)
                }
            }
            .onChange(of: databaseRepository.status, perform: { newValue in
                switch newValue {
                case .success: presentationMode.wrappedValue.dismiss()
                case .faliure: fetchFailed = true
                default: fetchFailed = false
                }
            })
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(1200)) {
                    databaseInit()
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Brak połączenia z internetem"), message: Text("Nie możemy sprawdzić czy rozkład jazdy jest aktualny! Możesz kontynuować w trybie offline lub spróbować ponownie"), primaryButton: .default(Text("Sprawdź ponownie"), action: databaseInit), secondaryButton: .cancel(Text("OK")))
            }
        }
    }
    
    func databaseInit() {
        databaseRepository.copyDatabaseIfNeeded()
        if ReachabilityTest.isConnectedToNetwork() {
            databaseRepository.fetch()
        } else {
            showAlert = true
        }
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}
