//
//  ProfileTopicContentView.swift
//  Msea
//
//  Created by tzqiang on 2021/12/30.
//  Copyright © 2021 eternal.just. All rights reserved.
//

import SwiftUI
import Kanna

/// 个人主题列表
struct ProfileTopicContentView: View {
    var uid = CacheInfo.shared.defaultUid
    @State private var topics = [ProfileTopicListModel]()
    @State private var isHidden = false

    var body: some View {
        ZStack {
            if topics.isEmpty {
                Text("现在还没有主题")
            } else {
                List(topics) { topic in
                    ZStack(alignment: .leading) {
                        Text(topic.title)
                            .fixedSize(horizontal: false, vertical: true)

                        NavigationLink(destination: TopicDetailContentView(tid: topic.tid)) {
                            EmptyView()
                        }
                        .opacity(0.0)
                    }
                }
                .listStyle(.plain)
            }

            ProgressView()
                .isHidden(isHidden)
        }
        .task {
            if !isHidden {
                await getProfileTopic()
            }
        }
    }

    private func getProfileTopic() async {
        Task {
            // swiftlint:disable force_unwrapping
            let url = URL(string: "https://www.chongbuluo.com/home.php?mod=space&uid=\(uid)")!
            // swiftlint:enble force_unwrapping
            let (data, _) = try await URLSession.shared.data(from: url)
            if let html = try? HTML(html: data, encoding: .utf8) {
                let content = html.xpath("//div[@id='thread_content']/ul/li", namespaces: nil)
                var list = [ProfileTopicListModel]()
                content.forEach { element in
                    var topic = ProfileTopicListModel()
                    if let text = element.text {
                        topic.title = text
                    }
                    let href = element.at_xpath("/a/@href", namespaces: nil)
                    if let text = href?.text {
                        let tids = text.components(separatedBy: "-")
                        if tids.count > 2 {
                            topic.tid = tids[1]
                        }
                    }
                    list.append(topic)
                }

                topics = list
            }
            isHidden = true
        }
    }
}

struct ProfileTopicContentView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileTopicContentView()
    }
}

struct ProfileTopicListModel: Identifiable {
    var id = UUID()
    var title = ""
    var tid = ""
}
