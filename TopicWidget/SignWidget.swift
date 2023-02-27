//
//  SignWidget.swift
//  TopicWidgetExtension
//
//  Created by tzqiang on 2023/2/27.
//  Copyright © 2023 eternal.just. All rights reserved.
//

import SwiftUI
import WidgetKit

struct SignProvider: TimelineProvider {
    typealias Entry = SignEntry

    func placeholder(in context: Context) -> SignEntry {
        SignEntry(date: .now)
    }

    func getSnapshot(in context: Context, completion: @escaping (SignEntry) -> Void) {
        let entry = SignEntry(date: .now)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SignEntry>) -> Void) {
        let entry = SignEntry(date: .now)
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
}

struct SignEntry: TimelineEntry {
    var date: Date
}

@available (iOSApplicationExtension 16, *)
struct SignWidgetEntryView: View {
    var entry: SignEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .accessoryInline:
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        case .accessoryRectangular:
            HStack(alignment: .center, spacing: 0) {
                VStack(alignment: .leading) {
                    Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
                        .font(.headline)
                        .widgetAccentable()

                    Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
                }.frame(maxWidth: .infinity, alignment: .leading)
            }
        case .accessoryCircular:
            ZStack {
                AccessoryWidgetBackground()

                Image(systemName: "leaf.fill")
                    .resizable()
                    .frame(width: 30, height: 30)
            }
            .widgetURL(URL(string: "msea://daysign"))
        default:
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        }
    }
}

@available (iOSApplicationExtension 16, *)
struct SignWidget: Widget {
    private let kind = "SignWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SignProvider()) { entry in
            SignWidgetEntryView(entry: entry)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .configurationDisplayName("签到")
        .description("签到相关的操作")
        .supportedFamilies([.accessoryInline, .accessoryRectangular, .accessoryCircular])
    }
}

@available (iOSApplicationExtension 16, *)
struct SignWidget_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SignWidgetEntryView(entry: SignEntry(date: .now))
                .previewContext(WidgetPreviewContext(family: .accessoryInline))
            SignWidgetEntryView(entry: SignEntry(date: .now))
                .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
            SignWidgetEntryView(entry: SignEntry(date: .now))
                .previewContext(WidgetPreviewContext(family: .accessoryCircular))
        }
    }
}
