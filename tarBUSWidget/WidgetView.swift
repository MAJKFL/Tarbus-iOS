//
//  tarBUSWidget.swift
//  tarBUSWidget
//
//  Created by Kuba Florek on 01/03/2021.
//

import WidgetKit
import SwiftUI

struct WidgetView: View {
    var data: DataProvider.Entry
    let textGradient = LinearGradient(gradient: Gradient(colors: [.clear, .clear, .clear, Color("GradientColor")]), startPoint: .top, endPoint: .bottom)
    let badgeGradient = LinearGradient(gradient: Gradient(colors: [Color("MainColor"), Color("MainColorGradient")]), startPoint: .topLeading, endPoint: .bottomTrailing)
    
    var body: some View {
        if data.busStopId != nil {
            VStack(alignment: .leading) {
                Text(data.busStopName)
                    .font(Font.footnote.bold())
                    .lineLimit(2)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding([.horizontal, .top], 10)
                    .padding(.bottom, 5)
                    .background(badgeGradient)
                
                Spacer(minLength: 5)
                
                VStack(spacing: 0) {
                    ForEach(data.departures) { departure in
                        HStack(spacing: 0) {
                            Text(departure.busLine.name)
                                .font(.headline)
                                .foregroundColor(Color("MainColor"))
                            
                            Spacer()
                            
                            Text(departure.timeString)
                                .font(.subheadline)
                            
                            if departure.isTomorrow {
                                Image(systemName: "calendar.badge.clock")
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                                    .padding(.leading, 2)
                            }
                        }
                        .lineLimit(1)
                        .padding(.horizontal, 10)
                        
                        Divider()
                    }
                    
                    Spacer()
                }
                .overlay(textGradient)
            }
        } else {
            VStack {
                Image("icon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .clipShape(ContainerRelativeShape())
                
                Text("Wybierz przystanek")
                    .multilineTextAlignment(.center)
            }
        }
    }
}
