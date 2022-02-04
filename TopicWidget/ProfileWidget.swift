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

struct ProfileProvider: IntentTimelineProvider {
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
        let uid = configuration.uid?.stringValue ?? "1"
        // swiftlint:disable force_unwrapping
        let url = URL(string: "https://www.chongbuluo.com/home.php?mod=space&uid=\(uid)")!
        // swiftlint:enble force_unwrapping
        let (data, _) = try await URLSession.shared.data(from: url)
        var profile = ProfileModel()
        profile.uid = uid
        if let html = try? HTML(html: data, encoding: .utf8) {
            if let text = html.toHTML, text.contains("隐私提醒") {
                let img = html.at_xpath("//div[@class='avt avtm']//img/@src", namespaces: nil)
                if let avatar = img?.text {
                    profile.avatar = avatar
                }
                let a = html.at_xpath("//p[@class='mtm xw1 xi2 xs2']", namespaces: nil)
                if let name = a?.text {
                    profile.name = name
                }
                let li1 = html.at_xpath("//ul[@class='pbm mbm bbda cl xl xl2 '][1]/li[1]", namespaces: nil)
                if let views = li1?.text {
                    profile.views = getNumbers(views)
                }
                let li2 = html.at_xpath("//ul[@class='pbm mbm bbda cl xl xl2 '][1]/li[2]", namespaces: nil)
                if let friend = li2?.text {
                    profile.friend = getNumbers(friend)
                }
                let li3 = html.at_xpath("//ul[@class='pbm mbm bbda cl xl xl2 '][1]/li[3]", namespaces: nil)
                if let post = li3?.text {
                    profile.post = getNumbers(post)
                }
                let li4 = html.at_xpath("//ul[@class='pbm mbm bbda cl xl xl2 '][1]/li[4]", namespaces: nil)
                if let topic = li4?.text {
                    profile.topic = getNumbers(topic)
                }

                let li5 = html.at_xpath("//ul[@class='pbm mbm bbda cl xl xl2 '][2]/li[1]", namespaces: nil)
                if let integral = li5?.text {
                    profile.integral = getNumbers(integral)
                }
                let li6 = html.at_xpath("//ul[@class='pbm mbm bbda cl xl xl2 '][2]/li[2]", namespaces: nil)
                if let bits = li6?.text {
                    profile.bits = getNumbers(bits)
                }
            } else {
                let img = html.at_xpath("//div[@id='profile_content']//img/@src", namespaces: nil)
                if let avatar = img?.text {
                    profile.avatar = avatar
                }
                let mbn = html.at_xpath("//div[@id='profile_content']//h2", namespaces: nil)
                if let name = mbn?.text {
                    profile.name = name
                }
                let xi1 = html.at_xpath("//div[@id='statistic_content']//strong[@class='xi1']", namespaces: nil)
                if let views = xi1?.text {
                    profile.views = views
                }
                let li1 = html.at_xpath("//ul[@class='xl xl2 cl']/li[1]/a", namespaces: nil)
                if let integral = li1?.text {
                    profile.integral = integral
                }
                let li2 = html.at_xpath("//ul[@class='xl xl2 cl']/li[2]/a", namespaces: nil)
                if let bits = li2?.text {
                    profile.bits = bits
                }
                let li4 = html.at_xpath("//ul[@class='xl xl2 cl']/li[4]/a", namespaces: nil)
                if let friend = li4?.text {
                    profile.friend = friend
                }
                let li5 = html.at_xpath("//ul[@class='xl xl2 cl']/li[5]/a", namespaces: nil)
                if let topic = li5?.text {
                    profile.topic = topic
                }
                let li6 = html.at_xpath("//ul[@class='xl xl2 cl']/li[6]/a", namespaces: nil)
                if let blog = li6?.text {
                    profile.blog = blog
                }
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

            Text("访问: \(Text(entry.profile.views).foregroundColor(.theme)) 好友: \(Text(entry.profile.friend).foregroundColor(.theme))")
                .font(.font12)

            Text("积分: \(Text(entry.profile.integral).foregroundColor(.theme)) Bit: \(Text(entry.profile.bits).foregroundColor(.theme))")
                .font(.font12)

            Text("主题: \(Text(entry.profile.topic).foregroundColor(.theme)) \(entry.profile.post != "--" ? "帖子" : "日志"): \(Text(entry.profile.post != "--" ? entry.profile.post : entry.profile.blog).foregroundColor(.theme))")
                .font(.font12)
        }
        .widgetURL(URL(string: "msea://space?uid=\(entry.profile.uid)"))
    }
}

struct ProfileModel {
    var uid = ""
    var name = ""
    var avatar = ""
    var views = "--"
    var integral = "--"
    var bits = "--"
    var friend = "--"
    var topic = "--"
    var post = "--"
    var blog = "--"
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
