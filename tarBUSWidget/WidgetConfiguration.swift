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
        .supportedFamilies([.systemSmall, .systemMedium])
        .description(Text("Wyświetla najbliższe odjazdy dla wybranego przystanku."))
        .configurationDisplayName(Text("Najbliższe odjazdy"))
    }
}
