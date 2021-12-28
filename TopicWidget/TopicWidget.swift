//
//  TopicWidget.swift
//  TopicWidget
//
//  Created by tzqiang on 2021/12/28.
//  Copyright © 2021 eternal.just. All rights reserved.
//

import WidgetKit
import SwiftUI
import Kanna

struct TopicProvider: TimelineProvider {
    func placeholder(in context: Context) -> TopicEntry {
        TopicEntry(date: .now, topics: [TopicModel]())
    }

    func getSnapshot(in context: Context, completion: @escaping (TopicEntry) -> Void) {
        Task {
            let entry = try await TopicEntry(date: .now, topics: getTopics())
            completion(entry)
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        Task {
            let entry = try await TopicEntry(date: .now, topics: getTopics())
            let timeline = Timeline(entries: [entry], policy: .after(.now.advanced(by: 5 * 60)))
            completion(timeline)
        }
    }

    private func getTopics() async throws -> [TopicModel] {
        // swiftlint:disable force_unwrapping
        let url = URL(string: "https://www.chongbuluo.com/forum.php?mod=viewthread&tid=820")!
        // swiftlint:enble force_unwrapping
        let (data, _) = try await URLSession.shared.data(from: url)
        var list = [TopicModel]()
        if let html = try? HTML(html: data, encoding: .utf8) {
            let hot = html.xpath("//div[@class='module cl xl xl1 rs_hot bls']//li", namespaces: nil)
            print(hot.count)

            hot.forEach { element in
                var topic = TopicModel()
                if let avatar = element.at_xpath("//@src", namespaces: nil)?.content {
                    topic.avatar = avatar
                }
                if let title = element.at_xpath("//@title", namespaces: nil)?.content {
                    topic.title = title
                }
                if let em = element.at_xpath("//em", namespaces: nil)?.content, let examine = Int(em) {
                    topic.examine = examine
                }
                if let href = element.at_xpath("//@href", namespaces: nil)?.content {
                    let ids = href.components(separatedBy: "-")
                    if ids.count > 2 {
                        let tid = ids[1]
                        topic.tid = tid
                    }
                }
                if list.count < 4 {
                    list.append(topic)
                }
            }
        }

        let imageDatas = try await withThrowingTaskGroup(of: Data.self) { group -> [Data] in
            for topic in list {
                group.addTask {
                    // swiftlint:disable force_unwrapping
                    let (imageData, _) = try await URLSession.shared.data(from: URL(string: topic.avatar)!)
                    // swiftlint:enble force_unwrapping
                    return imageData
                }
            }

            var imageList = [Data]()
            for try await value in group {
                imageList.append(value)
            }
            return imageList
        }

        for (index, image) in imageDatas.enumerated() {
            list[index].imageData = image
        }

        return list
    }
}

struct TopicEntry: TimelineEntry {
    var date: Date

    let topics: [TopicModel]
}

struct TopicPlaceholderViewRow: View {
    var body: some View {
        HStack {
            RoundedRectangle(cornerRadius: 5, style: .continuous)
                .fill(.gray)
                .frame(width: 20, height: 20)

            Text("************")

            Spacer()

            Capsule()
                .foregroundColor(.secondaryTheme.opacity(0.8))
                .frame(width: 22, height: 16)
        }
        .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
        .redacted(reason: .placeholder)

        Divider()
    }
}

struct TopicWidgetEntryView : View {
    var entry: TopicProvider.Entry

    var body: some View {
        VStack(spacing: 5) {
            if entry.topics.isEmpty {
                TopicPlaceholderViewRow()

                TopicPlaceholderViewRow()

                TopicPlaceholderViewRow()
            } else {
                ForEach(entry.topics, id:\.id) { item in
                    HStack {
                        if let data = item.imageData, let image = UIImage(data: data) {
                            Image(uiImage: image)
                                .resizable()
                                .frame(width: 20, height: 20)
                                .cornerRadius(5)
                        }

                        Text(item.title)
                            .font(.font14)
                            .lineLimit(1)

                        Spacer()

                        Text("\(item.examine)")
                            .font(.footnote)
                            .padding(EdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5))
                            .foregroundColor(.white)
                            .background(
                                Capsule()
                                    .foregroundColor(.secondaryTheme.opacity(0.8))
                            )
                    }
                    .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))

                    Divider()
                }
            }
        }
    }
}

struct TopicModel: Identifiable {
    var id = UUID()
    var avatar = ""
    var title = ""
    var tid = ""
    var examine = 0
    var imageData: Data?
}

struct TopicWidget: Widget {
    let kind: String = "TopicWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TopicProvider()) { entry in
            TopicWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("近日热议")
        .description("虫友最近关注的话题讨论")
        .supportedFamilies([.systemMedium])
    }
}

struct TopicWidget_Previews: PreviewProvider {
    static var previews: some View {
        TopicWidgetEntryView(entry: TopicEntry(date: .now, topics: [TopicModel]()))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}

@main
struct Widgets: WidgetBundle {
    @WidgetBundleBuilder

    var body: some Widget {
        TopicWidget()
        ProfileWidget()
    }
}
