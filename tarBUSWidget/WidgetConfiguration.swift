//
//  WidgetConfiguration.swift
//  tarBUSWidgetExtension
//
//  Created by Kuba Florek on 06/03/2021.
//

import SwiftUI
import WidgetKit

@main
struct Config: Widget {
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: "TarBUSWidget", intent: SelectBusStopIntent.self, provider: DataProvider()) {
            WidgetView(data: $0)
        }
        .supportedFamilies([.systemSmall])
        .description(Text("Wyświetla następne odjazdy dla wybranego przystanku"))
        .configurationDisplayName(Text("Następne odjazdy"))
    }
}
