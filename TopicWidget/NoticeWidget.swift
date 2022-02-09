//
// NoticeWidget.swift
//  Msea
//
//  Created by tzqiang on 2022/2/9.
//  Copyright © 2022 eternal.just. All rights reserved.
//

import WidgetKit
import SwiftUI
import Kanna

struct NoticeProvider: IntentTimelineProvider {
    typealias Entry = NoticeEntry
    typealias Intent = NoticeIntent

    func placeholder(in context: Context) -> NoticeEntry {
        NoticeEntry(date: .now, configuration: NoticeIntent(), Notice: NoticeModel())
    }

    func getSnapshot(for configuration: NoticeIntent, in context: Context, completion: @escaping (NoticeEntry) -> Void) {
        Task {
            let entry = try await NoticeEntry(date: .now, configuration: configuration, Notice: getNotice(for: configuration))
            completion(entry)
        }
    }

    func getTimeline(for configuration: NoticeIntent, in context: Context, completion: @escaping (Timeline<NoticeEntry>) -> Void) {
        Task {
            let entry = try await NoticeEntry(date: .now, configuration: configuration, Notice: getNotice(for: configuration))
            let timeline = Timeline(entries: [entry], policy: .after(.now.advanced(by:  5 * 60)))
            completion(timeline)
        }
    }

    private func getNotice(for configuration: NoticeIntent) async throws -> NoticeModel {
        let notice = NoticeModel()
        return notice
    }
}

struct NoticeEntry: TimelineEntry {
    var date: Date
    let configuration: NoticeIntent
    let Notice: NoticeModel
}

struct NoticeWidgetEntryView : View {
    var entry: NoticeProvider.Entry

    var body: some View {
        VStack {
            Text("暂无消息提醒")
        }
    }
}

struct NoticeModel {
    var uid = ""
}

struct NoticeWidget: Widget {
    let kind: String = "NoticeWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: NoticeIntent.self, provider: NoticeProvider()) { entry in
            NoticeWidgetEntryView(entry: entry)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(light: .white, dark: .widgetBlack))
        }
        .configurationDisplayName("新消息提醒")
        .description("收到消息本地推送通知")
        .supportedFamilies([.systemSmall])
    }
}

struct NoticeWidget_Previews: PreviewProvider {
    static var previews: some View {
        NoticeWidgetEntryView(entry: NoticeEntry(date: .now, configuration: NoticeIntent(), Notice: NoticeModel()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
