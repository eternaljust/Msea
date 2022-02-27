//
//  NodeListContentView.swift
//  Msea
//
//  Created by Awro on 2022/2/27.
//  Copyright © 2022 eternal.just. All rights reserved.
//

import SwiftUI
import Kanna

/// 节点分区列表
struct NodeListContentView: View {
    var node = NodeListModel()

    @State private var topics = [TopicListModel]()
    @State private var isHidden = false
    @State private var page = 1
    @State private var isRefreshing = false
    @State private var payContent = ""
    @State private var isLock = false

    @State private var today = ""
    @State private var todayImage = ""
    @State private var topicCount = ""
    @State private var rank = ""
    @State private var rankImage = ""

    var body: some View {
        ZStack {
            List {
                Section {
                    ForEach(topics) { topic in
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
                } header: {
                    HStack {
                        Text("今日: ")

                        Text(today)
                            .foregroundColor(.red)

                        if !todayImage.isEmpty {
                            Image(systemName: todayImage)
                                .foregroundColor(.secondaryTheme)
                        }

                        Text(" | ")

                        Text("主题: ")

                        Text(topicCount)
                            .foregroundColor(.red)

                        Text(" | ")

                        Text("排名: ")

                        Text(rank)
                            .foregroundColor(.red)

                        if !rankImage.isEmpty {
                            Image(systemName: rankImage)
                                .foregroundColor(.secondaryTheme)
                        }
                    }
                    .font(.font17)
                }
            }
            .listStyle(.plain)
            .isHidden(!payContent.isEmpty)
            .refreshable {
                page = 1
                await loadData()
            }
            .task {
                if !isHidden {
                    await loadData()
                }
            }

            VStack {
                Text(payContent)

                Text("需要在电脑上确认支付")
            }
            .foregroundColor(.red)
            .isHidden(payContent.isEmpty)

            ProgressView()
                .isHidden(isHidden)
        }
        .navigationBarTitle(node.title)
        .onAppear {
            if !UIDevice.current.isPad {
                TabBarTool.showTabBar(false)
            }
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
            let url = URL(string: "https://www.chongbuluo.com/forum.php?mod=forumdisplay&fid=\(node.fid)&page=\(page)")!
            // swiftlint:enble force_unwrapping
            var requset = URLRequest(url: url)
            requset.configHeaderFields()
            let (data, _) = try await URLSession.shared.data(for: requset)
            if let html = try? HTML(html: data, encoding: .utf8) {
                if let pay = html.at_xpath("//h3[@class='xs2 xi2 mbm']")?.text {
                    payContent = pay
                }

                if let today = html.at_xpath("//h1[@class='xs2']/span[@class='xs1 xw0 i']/strong[1]")?.text {
                    self.today = today
                }
                if let image = html.at_xpath("//h1[@class='xs2']/span[@class='xs1 xw0 i']/span[1]/@class")?.text {
                    if image.contains("paixu") {
                        todayImage = "arrow.up"
                    } else if image.contains("xiangshang") {
                        todayImage = "arrow.down"
                    }
                }
                if let topic = html.at_xpath("//h1[@class='xs2']/span[@class='xs1 xw0 i']/strong[2]")?.text {
                    topicCount = topic
                }
                if let rank = html.at_xpath("//h1[@class='xs2']/span[@class='xs1 xw0 i']/strong[3]")?.text {
                    self.rank = rank
                }
                if let image = html.at_xpath("//h1[@class='xs2']/span[@class='xs1 xw0 i']/span[last()]/@class")?.text {
                    if image.contains("paixu") {
                        rankImage = "arrow.up"
                    } else if image.contains("xiangshang") {
                        rankImage = "arrow.down"
                    }
                }

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
                    if let title = element.at_xpath("//th[@class='common']/a[@class='s xst']")?.text,
                       !title.isEmpty {
                        topic.title = title
                    } else if let title = element.at_xpath("//th[@class='lock']/a[@class='s xst']")?.text,
                              !title.isEmpty {
                        topic.title = title
                        isLock = true
                    }
                    if !topic.title.isEmpty {
                        if let time = element.at_xpath("//td[@class='by']//span//@title")?.text, !time.isEmpty {
                            topic.time = time
                        } else if let time = element.at_xpath("//td[@class='by']/em/a")?.text, !time.isEmpty {
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

struct NodeListContentView_Previews: PreviewProvider {
    static var previews: some View {
        NodeListContentView()
    }
}
