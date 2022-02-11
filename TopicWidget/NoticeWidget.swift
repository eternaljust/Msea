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
    private static let widgetGroup: UserDefaults? = UserDefaults(suiteName: "group.com.eternaljust.Msea.Topic.Widget")

    typealias Entry = NoticeEntry
    typealias Intent = NoticeIntent

    func placeholder(in context: Context) -> NoticeEntry {
        NoticeEntry(date: .now, configuration: NoticeIntent(), notice: NoticeModel())
    }

    func getSnapshot(for configuration: NoticeIntent, in context: Context, completion: @escaping (NoticeEntry) -> Void) {
        Task {
            let entry = try await NoticeEntry(date: .now, configuration: configuration, notice: getNotice(for: configuration))
            completion(entry)
        }
    }

    func getTimeline(for configuration: NoticeIntent, in context: Context, completion: @escaping (Timeline<NoticeEntry>) -> Void) {
        Task {
            let entry = try await NoticeEntry(date: .now, configuration: configuration, notice: getNotice(for: configuration))
            let timeline = Timeline(entries: [entry], policy: .after(.now.advanced(by: configuration.time?.doubleValue ?? 5 * 60)))
            completion(timeline)
        }
    }

    private func getNotice(for configuration: NoticeIntent) async throws -> NoticeModel {
        let groupHeaderFields = NoticeProvider.widgetGroup?.data(forKey: "groupHTTPHeaderFieldsKey")
        let headers = try? JSONDecoder().decode([String : String].self, from: groupHeaderFields ?? Data())
        // swiftlint:disable force_unwrapping
        let url = URL(string: "https://www.chongbuluo.com")!
        // swiftlint:enble force_unwrapping
        var requset = URLRequest(url: url)
        requset.allHTTPHeaderFields = headers

        let (data, _) = try await URLSession.shared.data(for: requset)
        var noticeNumber = ""
        if let html = try? HTML(html: data, encoding: .utf8) {
            if let notice = html.at_xpath("//a[@id='myprompt']", namespaces: nil)?.text, notice.contains("(") {
                noticeNumber = notice
            }
        }
        var notice = NoticeModel()
        notice.number = noticeNumber
        return notice
    }
}

struct NoticeEntry: TimelineEntry {
    var date: Date
    let configuration: NoticeIntent
    let notice: NoticeModel
}

struct NoticeWidgetEntryView : View {
    var entry: NoticeProvider.Entry

    var body: some View {
        VStack {
            if entry.notice.number.isEmpty {
                Text("暂无消息提醒")
            } else {
                Text("您有通知\(entry.notice.number)")
            }
        }
    }
}

struct NoticeModel {
    var number = ""
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
        NoticeWidgetEntryView(entry: NoticeEntry(date: .now, configuration: NoticeIntent(), notice: NoticeModel()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}

/*
 Cookie": "1aG4_2132_saltkey=xsfz1ZZr; 1aG4_2132_lastvisit=1644558349; 1aG4_2132_lastact=1644567320%09forum.php%09; 1aG4_2132_ulastactivity=1644567224%7C0; 1aG4_2132_lastcheckfeed=17719%7C1644563386; 1aG4_2132_sid=0; acw_tc=707c9fc316445657099871022e01dc5f1c873ab3d574df3c3da8b56a16cac5; 1aG4_2132_auth=4c88zAH2JR2VV18T3tyrT0rU88RCQPGJxayif1KCGH6Wv5n6wNJI%2FfheUFD39xDesL8uz3TOGt4PWwATg8sE4NWqOw;", "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 12_0_1) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.1 Safari/605.1.15
 */
/*
 "Cookie": "1aG4_2132_saltkey=xsfz1ZZr; 1aG4_2132_lastvisit=1644558349; 1aG4_2132_lastact=1644567517%09forum.php%09; 1aG4_2132_ulastactivity=1644567224%7C0; 1aG4_2132_lastcheckfeed=17719%7C1644563386; 1aG4_2132_sid=0; acw_tc=707c9fc416445675171021899e5f4b0fecaa44061820c44a991e8cd8317362; 1aG4_2132_auth=4c88zAH2JR2VV18T3tyrT0rU88RCQPGJxayif1KCGH6Wv5n6wNJI%2FfheUFD39xDesL8uz3TOGt4PWwATg8sE4NWqOw;", "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 12_0_1) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.1 Safari/605.1.15"
 */
