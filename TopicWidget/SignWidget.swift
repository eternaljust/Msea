//
//  SignWidget.swift
//  TopicWidgetExtension
//
//  Created by tzqiang on 2023/2/27.
//  Copyright © 2023 eternal.just. All rights reserved.
//

import SwiftUI
import WidgetKit
import Kanna

struct SignProvider: TimelineProvider {
    private static let widgetGroup: UserDefaults? = UserDefaults(suiteName: "group.com.eternaljust.Msea.Topic.Widget")

    typealias Entry = SignEntry

    func placeholder(in context: Context) -> SignEntry {
        SignEntry(date: .now, sign: SignModel())
    }

    func getSnapshot(in context: Context, completion: @escaping (SignEntry) -> Void) {
        Task {
            let entry = try await SignEntry(date: .now, sign: getSign())
            completion(entry)
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SignEntry>) -> Void) {
        Task {
            let entry = try await SignEntry(date: .now, sign: getSign())
            let timeline = Timeline(entries: [entry], policy: .after(.now.advanced(by: 5 * 60)))
            completion(timeline)
        }
    }

    private func getSign() async throws -> SignModel {
        let groupHeaderFields = SignProvider.widgetGroup?.data(forKey: "groupHTTPHeaderFieldsKey")
        var headers = try? JSONDecoder().decode([String : String].self, from: groupHeaderFields ?? Data())
        headers?["User-Agent"] = "Mozilla/5.0 (Macintosh; Intel Mac OS X 12_0_1) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.1 Safari/605.1.15"
        // swiftlint:disable force_unwrapping
        let url = URL(string: "https://www.chongbuluo.com/plugin.php?id=wq_sign")!
        // swiftlint:enble force_unwrapping
        var requset = URLRequest(url: url)
        requset.allHTTPHeaderFields = headers
        let (data, _) = try await URLSession.shared.data(for: requset)
        var signModel = SignModel()
        if let html = try? HTML(html: data, encoding: .utf8) {
            let sign = html.at_xpath("//a[@class='wqpc_sign_btn_red']")
            let sign_btn = html.at_xpath("//div[@class='wqpc_sign_btna']")
            var text_btn = signModel.signText
            if let text = sign?.text {
                text_btn = text
            } else if let text = sign_btn?.text {
                text_btn = text
            }
            signModel.signText = text_btn.trimmingCharacters(in: .whitespacesAndNewlines)

            var list = [CalendarDayModel]()
            let calendar = html.at_xpath("//div[@class='wqpc_sign_btn_calendar']")
            let dates = calendar?.xpath("/ul[@class='wq_date']/li")
            dates?.forEach { element in
                var model = CalendarDayModel()
                if let text = element.at_xpath("/span")?.text {
                    model.title = text
                }
                if let text = element.at_xpath("/span/i/@class")?.text, text == "wqsign_dot_red" || text == "wqsign_dot_white" {
                    model.isSign = true
                }
                if let text = element.at_xpath("/span/@class")?.text, text == "wq_sign_today" {
                    model.isToday = true
                }
                list.append(model)
            }
            if !list.isEmpty {
                var todayRow = 0
                for (index, item) in list.enumerated() where item.isToday {
                    todayRow = index / 7
                }

                var days = [CalendarDayModel]()
                for (index, item) in list.enumerated() {
                    if todayRow == 0 {
                        if index / 7 == 0 || index / 7 == 1 {
                            days.append(item)
                        }
                    } else {
                        if index / 7 == todayRow - 1 || index / 7 == todayRow {
                            days.append(item)
                        }
                    }
                }

                signModel.dates = days
            }
        }
        return signModel
    }
}

struct SignEntry: TimelineEntry {
    var date: Date
    var sign = SignModel()
}

struct SignModel: Identifiable {
    var id = UUID()
    var signText = "今日未签到，点击签到"

    var dates = [CalendarDayModel]()
    private var weeks: [CalendarDayModel] = [
        CalendarDayModel(title: "日"),
        CalendarDayModel(title: "一"),
        CalendarDayModel(title: "二"),
        CalendarDayModel(title: "三"),
        CalendarDayModel(title: "四"),
        CalendarDayModel(title: "五"),
        CalendarDayModel(title: "六")
    ]
    var list: [CalendarDayModel] {
        // swiftlint:disable implicit_getter
        get {
            var days = [CalendarDayModel]()
            days.append(contentsOf: weeks)

            if dates.isEmpty {
                for index in 1...14 {
                    days.append(CalendarDayModel(title: "\(index)"))
                }
            } else {
                dates.forEach { day in
                    days.append(day)
                }
            }

            return days
        }
        // swiftlint:enble implicit_getter
    }
}

struct CalendarDayModel: Identifiable {
    var id = UUID()

    var title = ""
    var isSign = false
    var isToday = false
}

@available (iOSApplicationExtension 16, *)
struct SignWidgetEntryView: View {
    var entry: SignEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .accessoryInline:
            Text(entry.sign.signText)
                .widgetURL(URL(string: "msea://daysign"))
        case .accessoryRectangular:
            let columns = [GridItem(.fixed(15)), GridItem(.fixed(15)), GridItem(.fixed(15)), GridItem(.fixed(15)), GridItem(.fixed(15)), GridItem(.fixed(15)), GridItem(.fixed(15))]
            LazyVGrid(columns: columns, spacing: 3) {
                ForEach(entry.sign.list) { date in
                    RoundedRectangle(cornerRadius: 3)
                        .frame(width: 18, height: 18)
                        .foregroundColor(date.isToday ? Color(white: 1.0) : Color(white: 0.1))
                        .overlay(
                            VStack(alignment: .center, spacing: 0) {
                                Text(date.title)
                                    .font(.system(size: 10))
                                    .foregroundColor(date.isToday ? .black : .white)

                                if date.isSign {
                                    Circle()
                                        .frame(width: 3, height: 3)
                                        .foregroundColor(date.isToday ? .black : .white)
                                }
                            }
                        )
                }
            }
            .widgetURL(URL(string: "msea://daysign"))
        case .accessoryCircular:
            ZStack {
//                AccessoryWidgetBackground()

                Image(systemName: "leaf.fill")
                    .resizable()
                    .frame(width: 30, height: 30)
            }
            .widgetURL(URL(string: "msea://daysign"))
        default:
            Text("签到")
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
        .description("签到按钮与签到月历")
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
