//
//  DevMenuView.swift
//  tarBUS
//
//  Created by Kuba Florek on 25/05/2021.
//

import SwiftUI

struct DevMenuView: View {
    @ObservedObject var databaseHelper = DataBaseHelper()
    
    var body: some View {
        Section(header: Text("Debug Menu")) {
            NavigationLink("Run statement", destination: DevQueryView())
            Button("Fetch data", action: databaseHelper.fetchData)
            Button("Delete all data", action: databaseHelper.deleteAllData)
            Button("Reset defaults", action: resetDefaults)
        }
        .foregroundColor(Color("DebugPink"))
    }
    
    func resetDefaults() {
        let defaults = UserDefaults.standard
        let dictionary = defaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            defaults.removeObject(forKey: key)
        }
    }
}

struct DevQueryView: View {
    private struct StatementResult: Identifiable {
        var id: Date {
            date
        }
        
        let date: Date
        let stringResult: String
        let statement: String
        
        var formattedDate: String {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
            return formatter.string(from: date)
        }
    }
    
    @ObservedObject var databaseHelper = DataBaseHelper()
    
    @State private var statement: String = ""
    @State private var statementResults = [StatementResult]()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                TextEditor(text: $statement)
                    .frame(width: UIScreen.main.bounds.width - 50, height: 200)
                    .padding()
                    .border(Color.secondary)
                
                ForEach(statementResults.reversed()) { statementResult in
                    Divider()
                        .padding()
                    
                    Text(statementResult.formattedDate)
                        .font(.headline)
                    
                    Button(action: {
                        UIPasteboard.general.string = statementResult.stringResult
                    }, label: {
                        Label("Copy", systemImage: "doc.on.doc")
                    })
                    .foregroundColor(Color("DebugPink"))
                    
                    Text(statementResult.stringResult)
                    
                    Text(statementResult.statement)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
        }
        .navigationTitle("Run statement")
        .navigationBarItems(trailing: Button(action: executeQuery) {
            Image(systemName: "play.fill")
                .font(.title)
        }.foregroundColor(Color("DebugPink"))
        )
    }
    
    func executeQuery() {
        withAnimation(.easeIn) {
            do {
                if !(try databaseHelper.runStatement(statement)).isEmpty {
                    let statementResult = StatementResult(date: Date(), stringResult: try databaseHelper.runStatement(statement), statement: statement)
                    statementResults.append(statementResult)
                }
            } catch {
                let statementResult = StatementResult(date: Date(), stringResult: error.localizedDescription, statement: statement)
                statementResults.append(statementResult)
            }
        }
    }
}
