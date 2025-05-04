//
//  ProfileWidget.swift
//  TopicWidget
//
//  Created by tzqiang on 2021/12/28.
//  Copyright © 2021 eternal.just. All rights reserved.
//

import WidgetKit
import SwiftUI
import Kanna
import EJExtension

struct ProfileProvider: IntentTimelineProvider {
    private static let widgetGroup: UserDefaults? = UserDefaults(suiteName: "group.com.eternaljust.Msea.Topic.Widget")

    typealias Entry = ProfileEntry
    typealias Intent = ProfileIntent

    func placeholder(in context: Context) -> ProfileEntry {
        ProfileEntry(date: .now, configuration: ProfileIntent(), profile: ProfileModel())
    }

    func getSnapshot(for configuration: ProfileIntent, in context: Context, completion: @escaping (ProfileEntry) -> Void) {
        Task {
            let entry = try await ProfileEntry(date: .now, configuration: configuration, profile: getProfile(for: configuration))
            completion(entry)
        }
    }

    func getTimeline(for configuration: ProfileIntent, in context: Context, completion: @escaping (Timeline<ProfileEntry>) -> Void) {
        Task {
            let entry = try await ProfileEntry(date: .now, configuration: configuration, profile: getProfile(for: configuration))
            let timeline = Timeline(entries: [entry], policy: .after(.now.advanced(by: 5 * 60)))
            completion(timeline)
        }
    }

    private func getProfile(for configuration: ProfileIntent) async throws -> ProfileModel {
        let groupHeaderFields = ProfileProvider.widgetGroup?.data(forKey: "groupHTTPHeaderFieldsKey")
        var headers = try? JSONDecoder().decode([String : String].self, from: groupHeaderFields ?? Data())
        headers?["User-Agent"] = "Mozilla/5.0 (Macintosh; Intel Mac OS X 12_0_1) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.1 Safari/605.1.15"
        let uid = configuration.uid?.stringValue ?? "1"
        // swiftlint:disable force_unwrapping
        let url = URL(string: "https://www.chongbuluo.com/home.php?mod=space&do=profile&from=space&uid=\(uid)")!
        // swiftlint:enble force_unwrapping
        var requset = URLRequest(url: url)
        requset.allHTTPHeaderFields = headers

        let (data, _) = try await URLSession.shared.data(for: requset)
        var profile = ProfileModel()
        profile.uid = uid
        if let html = try? HTML(html: data, encoding: .utf8) {
            let img = html.at_xpath("//div[@class='h cl']//img/@src")
            if let avatar = img?.text {
                profile.avatar = avatar.replacingOccurrences(of: "&size=small", with: "")
            }
            let mbn = html.at_xpath("//div[@class='h cl']//h2")
            if let name = mbn?.text {
                profile.name = name.replacingOccurrences(of: "\n", with: "")
            }

            profile.reply = ""
            let a1 = html.at_xpath("//ul[@class='cl bbda pbm mbm']//a[1]")?.text ?? ""
            if let text = a1.components(separatedBy: " ").last, !text.isEmpty {
                profile.reply = text
            }
            let a2 = html.at_xpath("//ul[@class='cl bbda pbm mbm']//a[2]")?.text ?? ""
            if let text = a2.components(separatedBy: " ").last, !text.isEmpty {
                profile.topic = text
            }

            let li2 = html.at_xpath("//div[@id='psts']/ul[@class='pf_l']/li[2]")
            if let text = li2?.text {
                profile.integral = text.replacingOccurrences(of: "积分", with: "")
            }
            let li3 = html.at_xpath("//div[@id='psts']/ul[@class='pf_l']/li[3]")
            if let text = li3?.text {
                profile.bits = text.replacingOccurrences(of: "Bit", with: "")
            }
            let li4 = html.at_xpath("//div[@id='psts']/ul[@class='pf_l']/li[4]")
            if let text = li4?.text {
                profile.violation = text.replacingOccurrences(of: "违规", with: "")
            }
        }

        if profile.avatar.hasPrefix("http") {
            // swiftlint:disable force_unwrapping
            let (imageData, _) = try await URLSession.shared.data(from: URL(string: profile.avatar)!)
            // swiftlint:enble force_unwrapping
            profile.imageData = imageData
        }

        return profile
    }

    private func getNumbers(_ nums: String) -> String {
        if nums.contains(":"), let num = nums.replacingOccurrences(of: " ", with: "").components(separatedBy: ":").last {
            return num
        }
        return "--"
    }
}

struct ProfileEntry: TimelineEntry {
    var date: Date
    let configuration: ProfileIntent
    let profile: ProfileModel
}

struct ProfileWidgetEntryView : View {
    var entry: ProfileProvider.Entry

    var body: some View {
        VStack {
            if let data = entry.profile.imageData, let image = UIImage(data: data) {
                Image(uiImage: image)
                    .resizable()
                    .frame(width: 50, height: 50)
                    .cornerRadius(5)
            } else {
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .fill(.gray)
                    .frame(width: 50, height: 50)
            }

            Text(entry.profile.name)
                .font(.font15)
                .foregroundColor(.secondaryTheme)
                .padding(.bottom, -2)

            Text("回帖: \(Text(entry.profile.reply).foregroundColor(.theme))")
                .font(.font12)

            Text("主题: \(Text(entry.profile.topic).foregroundColor(.theme)) 积分: \(Text(entry.profile.integral).foregroundColor(.theme))")
                .font(.font12)

            Text("Bit: \(Text(entry.profile.bits).foregroundColor(.theme)) \("违规"): \(Text(entry.profile.violation).foregroundColor(.theme))")
                .font(.font12)
        }
        .widgetURL(URL(string: "msea://space?uid=\(entry.profile.uid)"))
    }
}

struct ProfileModel {
    var uid = ""
    var name = ""
    var avatar = ""
    var integral = "--"
    var bits = "--"
    var friend = "--"
    var reply = "--"
    var topic = "--"
    var violation = "--"
    var imageData: Data?
}

struct ProfileWidget: Widget {
    let kind: String = "ProfileWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ProfileIntent.self, provider: ProfileProvider()) { entry in
            ProfileWidgetEntryView(entry: entry)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(light: .white, dark: .widgetBlack))
        }
        .configurationDisplayName("个人资料")
        .description("统计信息")
        .supportedFamilies([.systemSmall])
    }
}

struct ProfileWidget_Previews: PreviewProvider {
    static var previews: some View {
        ProfileWidgetEntryView(entry: ProfileEntry(date: .now, configuration: ProfileIntent(), profile: ProfileModel()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
