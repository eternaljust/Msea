//
//  TopicListContentView.swift
//  Msea
//
//  Created by Awro on 2021/12/4.
//  Copyright © 2021 eternal.just. All rights reserved.
//

import SwiftUI
import Kanna

/// 主题列表
struct TopicListContentView: View {
    var view = ViewTab.new

    @State private var topics = [TopicListModel]()
    @State private var isHidden = false
    @State private var page = 1
    @State private var isRefreshing = false

    var body: some View {
        ZStack {
            List(topics) { topic in
                ZStack {
                    VStack(alignment: .leading) {
                        HStack {
                            AsyncImage(url: URL(string: "https://www.chongbuluo.com/\(topic.avatar)")) { image in
                                image.resizable()
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(width: 40, height: 40)
                            .cornerRadius(5)

                            VStack(alignment: .leading, spacing: 5) {
                                Text(topic.name)
                                    .font(.font17Blod)

                                Text(topic.time)
                                    .font(.font13)
                            }

                            Spacer()

                            Text("\(topic.reply)/\(topic.examine)")
                                .padding(EdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5))
                                .foregroundColor(.white)
                                .background(
                                    Capsule()
                                        .foregroundColor(.secondaryTheme.opacity(0.8))
                                )
                        }

                        Text(topic.title)
                            .fixedSize(horizontal: false, vertical: true)
                            .onAppear {
                                if topic.id == topics.last?.id {
                                    page += 1
                                    Task {
                                        await loadData()
                                    }
                                }
                            }
                    }
                    .padding([.top, .bottom], 5)

                    NavigationLink(destination: TopicDetailContentView(tid: topic.tid)) {
                        EmptyView()
                    }
                    .opacity(0.0)
                }
            }
            .listStyle(.plain)
            .refreshable {
                page = 1
                await loadData()
            }
            .task {
                if !isHidden {
                    await loadData()
                }
            }

            ProgressView()
                .isHidden(isHidden)
        }
        .onAppear {
            shieldUsers()
        }
        .onReceive(NotificationCenter.default.publisher(for: .shieldUser, object: nil)) { _ in
            shieldUsers()
        }
    }

    private func shieldUsers() {
        topics = topics.filter { model in
            !UserInfo.shared.shieldUsers.contains { $0.uid == model.uid }
        }
    }

    private func loadData() async {
        isRefreshing = true
        Task {
            // swiftlint:disable force_unwrapping
            let url = URL(string: "https://www.chongbuluo.com/forum.php?mod=guide&view=\(view.id)&page=\(page)")!
            // swiftlint:enble force_unwrapping
            var requset = URLRequest(url: url)
            requset.configHeaderFields()
            let (data, _) = try await URLSession.shared.data(for: requset)
            if let html = try? HTML(html: data, encoding: .utf8) {
                let node = html.xpath("//tbody")
                var list = [TopicListModel]()
                node.forEach { element in
                    var topic = TopicListModel()
                    if let avatar = element.at_xpath("//img//@src")?.text {
                        topic.avatar = avatar
                    }
                    if let name = element.at_xpath("//cite/a")?.text {
                        topic.name = name
                    }
                    if let title = element.at_xpath("//th/a[@class='xst']")?.text {
                        topic.title = title
                        if let time = element.at_xpath("//td[@class='by']//span//@title")?.text {
                            topic.time = time
                        }
                        if let xi2 = element.at_xpath("//td/a[@class='xi2']")?.text, let reply = Int(xi2) {
                            topic.reply = reply
                        }
                        if let em = element.at_xpath("//td[@class='num']/em")?.text, let examine = Int(em) {
                            topic.examine = examine
                        }
                        if let uid = element.at_xpath("//cite/a//@href")?.text {
                            let uids = uid.components(separatedBy: "uid=")
                            if uid.contains("uid"), uids.count == 2 {
                                topic.uid = uids[1]
                            }
                        }
                        if let id = element.at_xpath("//@id")?.text, let tid = id.components(separatedBy: "_").last {
                            topic.tid = tid
                        }
                        list.append(topic)
                    }
                }
                html.getFormhash()

                if page == 1 {
                    topics = list
                    isRefreshing = false
                } else {
                    topics += list
                }
                isHidden = true

                shieldUsers()
            }
        }
    }
}

struct TopicListContentView_Previews: PreviewProvider {
    static var previews: some View {
        TopicListContentView()
    }
}

struct TopicListModel: Identifiable {
    var id = UUID()
    var uid = ""
    var tid = ""
    var name = ""
    var avatar = ""
    var title = ""
    var time = ""
    var examine = 0
    var reply = 0
}
