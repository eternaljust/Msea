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
        let entry = SignEntry(date: .now, sign: SignModel())
        completion(entry)
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
        }
        return signModel
    }
}

struct SignEntry: TimelineEntry {
    var date: Date
    var sign: SignModel
}

struct SignModel: Identifiable {
    var id = UUID()
    var signText = "今日未签到，点击签到"
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
//                AccessoryWidgetBackground()

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
            SignWidgetEntryView(entry: SignEntry(date: .now, sign: SignModel()))
                .previewContext(WidgetPreviewContext(family: .accessoryInline))
            SignWidgetEntryView(entry: SignEntry(date: .now, sign: SignModel()))
                .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
            SignWidgetEntryView(entry: SignEntry(date: .now, sign: SignModel()))
                .previewContext(WidgetPreviewContext(family: .accessoryCircular))
        }
    }
}
