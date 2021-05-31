//
//  tarBUSWidget.swift
//  tarBUSWidget
//
//  Created by Kuba Florek on 01/03/2021.
//

import WidgetKit
import SwiftUI

struct WidgetView: View {
    @Environment(\.widgetFamily) var family
    
    var data: DataProvider.Entry
    
    let textGradient = LinearGradient(gradient: Gradient(colors: [.clear, .clear, .clear, Color("GradientColor")]), startPoint: .top, endPoint: .bottom)
    let badgeGradient = LinearGradient(gradient: Gradient(colors: [Color("MainColor"), Color("MainColorGradient")]), startPoint: .topLeading, endPoint: .bottomTrailing)
    
    var url: URL? {
        guard let busStopId = data.busStopId else { return nil }
        return URL(string: "tarbus://widget.com?busStopId=\(busStopId)")
    }
    
    var body: some View {
        GeometryReader { geo in
            VStack(alignment: .center) {
                if data.busStopId == nil {
                    HStack {
                        Spacer()
                        
                        VStack(alignment: .center) {
                            Spacer()
                            
                            Text("🚏")
                            
                            Text("Wybierz przystanek")
                                .font(.subheadline)
                                .multilineTextAlignment(.center)
                            
                            Text("Przytrzymaj dłużej widget i naciśnij \"Edycja widżetu\"")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                            
                            Spacer()
                        }
                        
                        Spacer()
                    }
                } else {
                    Text(data.busStopName)
                        .font(Font.footnote.bold())
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, minHeight: geo.size.height / 4)
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
                                
                                if family == .systemMedium {
                                    Text(departure.boardName)
                                        .padding(.leading, 5)
                                }
                                
                                Spacer()
                                
                                Text(departure.timeString)
                                    .font(.headline)
                                
                                if departure.isTomorrow {
                                    Image(systemName: "calendar.badge.clock")
                                        .font(.footnote)
                                        .foregroundColor(.secondary)
                                        .padding(.leading, 2)
                                }
                            }
                            .lineLimit(1)
                            .padding(.horizontal, 10)
                        }
                        
                        Spacer()
                    }
                    .overlay(textGradient)
                }
            }
            .widgetURL(url)
        }
    }
}
