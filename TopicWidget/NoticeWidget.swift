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
import UserNotifications

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
            let timeline = Timeline(entries: [entry], policy: .after(.now.advanced(by: getSpacingTime(configuration.time) * 60)))
            completion(timeline)
        }
    }

    private func getSpacingTime(_ time: SpacingTime) -> Double {
        switch time {
        case .one:
            return 1
        case .three:
            return 3
        case .five:
            return 5
        case .ten:
            return 10
        case .twenty:
            return 20
        case .halfhour:
            return 30
        case .unknown:
            return 5
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
            if let notice = html.at_xpath("//a[@id='myprompt']", namespaces: nil)?.text,
               notice.contains("("),
               notice.contains(")") {
                noticeNumber = notice.components(separatedBy: "(")[1].components(separatedBy: ")")[0]
            }
        }
        var notice = NoticeModel()
        notice.number = noticeNumber
        if !noticeNumber.isEmpty {
            let content = UNMutableNotificationContent()
            content.title = "您有消息提醒(\(noticeNumber))"
            content.body = "点击打开 Msea，立即查看新的消息！"
            content.badge = NSNumber(value: Int(noticeNumber) ?? 1)
            content.sound = .default
            content.userInfo = ["localNotificatonAction": "notice"]

            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            let request = UNNotificationRequest(identifier: "noticeIdentifier", content: content, trigger: trigger)

            try await UNUserNotificationCenter.current().add(request)
            print("LocalNotification notice")
        }
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
                Image(systemName: "bell.fill")
                    .resizable()
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(Color.theme)
                    .frame(width: 40, height: 40)

                Text("暂无提醒")
                    .foregroundColor(.secondaryTheme)
            } else {
                Image(systemName: "bell.badge.fill")
                    .resizable()
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.red, Color.theme)
                    .frame(width: 40, height: 40)

                if let num = Int(entry.notice.number), num > 50 {
                    Text("消息提醒 ")
                    + Text(entry.notice.number)
                        .foregroundColor(.red)
                } else {
                    HStack {
                        Text("消息提醒")

                        Image(systemName: "\(entry.notice.number).circle.fill")
                            .resizable()
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.white, .red)
                            .frame(width: 20, height: 20)
                    }
                }
            }
        }
        .widgetURL(URL(string: "msea://notice"))
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
        .description("收到消息可弹出推送通知")
        .supportedFamilies([.systemSmall])
    }
}

struct NoticeWidget_Previews: PreviewProvider {
    static var previews: some View {
        NoticeWidgetEntryView(entry: NoticeEntry(date: .now, configuration: NoticeIntent(), notice: NoticeModel()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
