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
    @StateObject var profile: ProfileUidModel
    @State private var uid = ""

    @State private var page = 1
    @State private var topics = [ProfileTopicListModel]()
    @State private var isHidden = false
    @State private var isPosterShielding = false

    @EnvironmentObject private var hud: HUDState

    var body: some View {
        ZStack {
            if topics.isEmpty || isPosterShielding {
                if isPosterShielding {
                    Text("该用户的主题已被屏蔽")
                } else {
                    Text("现在还没有主题")
                }
            } else {
                List {
                    Section {
                        ForEach(topics) { topic in
                            ZStack(alignment: .leading) {
                                VStack(alignment: .leading) {
                                    HStack {
                                        HStack {
                                            GifImage(url: URL(string: topic.gif))
                                                .frame(width: 20, height: 20)

                                            VStack(alignment: .leading) {
                                                Text(topic.name)
                                                    .font(.font15)

                                                Text(topic.time)
                                                    .font(.font12)
                                            }
                                        }
                                        .frame(width: uid == UserInfo.shared.uid ? (UIDevice.current.isPad ? 100 : 130) : (UIDevice.current.isPad ? 250 : 130), alignment: .leading)

                                        Spacer()

                                        Text(topic.plate)
                                            .font(.font15)
                                            .frame(width: uid == UserInfo.shared.uid ? 70 : (UIDevice.current.isPad ? 140 : 70))
                                            .fixedSize(horizontal: false, vertical: true)

                                        Spacer()

                                        VStack {
                                            Text("\(topic.reply)/\(topic.examine)")
                                                .padding(EdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5))
                                                .foregroundColor(.white)
                                                .background(
                                                    Capsule()
                                                        .foregroundColor(.secondaryTheme.opacity(0.8))
                                                )
                                        }
                                        .frame(width: uid == UserInfo.shared.uid ? (UIDevice.current.isPad ? 100 : 130) : (UIDevice.current.isPad ? 250 : 130), alignment: .trailing)
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
                            Text("最后发帖  ")

                            Spacer()

                            Text("板块")

                            Spacer()

                            Text("回复/查看")
                        }
                    }
                }
                .listStyle(.plain)
                .refreshable {
                    page = 1
                    await loadData()
                }
            }

            ProgressView()
                .isHidden(isHidden)
        }
        .task {
            if !isHidden {
                page = 1
                await loadData()
            }
        }
        .onAppear {
            isPosterShielding = UserInfo.shared.shieldUsers.contains { $0.uid == uid }
        }
        .onReceive(NotificationCenter.default.publisher(for: .shieldUser, object: nil)) { _ in
            isPosterShielding = UserInfo.shared.shieldUsers.contains { $0.uid == uid }
        }
        .onReceive(NotificationCenter.default.publisher(for: .postPublish, object: nil)) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                hud.show(message: "帖子发表成功")
            }
            Task {
                page = 1
                await loadData()
            }
        }
        .onChange(of: profile.uid) { newValue in
            Task {
                if newValue != uid {
                    uid = newValue
                    await loadData()
                }
            }
        }
    }

    private func loadData() async {
        Task {
            // swiftlint:disable force_unwrapping
            let url = URL(string: "https://www.chongbuluo.com/home.php?mod=space&uid=\(uid)&do=thread&view=me&order=dateline&from=space&page=\(page)")!
            // swiftlint:enble force_unwrapping
            var request = URLRequest(url: url)
            request.configHeaderFields()
            let (data, _) = try await URLSession.shared.data(for: request)
            if let html = try? HTML(html: data, encoding: .utf8) {
                let content = html.xpath("//div[@class='bm_c']//table/tr")
                var list = [ProfileTopicListModel]()
                content.forEach { element in
                    if let gif = element.at_xpath("/td[@class='icn']/a/img/@src")?.text {
                        var topic = ProfileTopicListModel()
                        topic.gif = "https://www.chongbuluo.com/" + gif

                        if let text = element.at_xpath("/th/a")?.text {
                            topic.title = text
                        }
                        if let text = element.at_xpath("/th/a/@href")?.text {
                            let tids = text.components(separatedBy: "tid=")
                            if tids.count == 2 {
                                topic.tid = tids[1]
                            }
                        }
                        if let xg1 = element.at_xpath("/td/a[@class='xg1']")?.text {
                            topic.plate = xg1
                        }
                        if let xi2 = element.at_xpath("/td[@class='num']/a[@class='xi2']")?.text, let reply = Int(xi2) {
                            topic.reply = reply
                        }
                        if let em = element.at_xpath("/td[@class='num']/em")?.text, let examine = Int(em) {
                            topic.examine = examine
                        }
                        if let name = element.at_xpath("/td[@class='by']/cite")?.text {
                            topic.name = name
                        }
                        if let time = element.at_xpath("/td[@class='by']/em")?.text {
                            topic.time = time
                        }

                        list.append(topic)
                    }
                }

                if page == 1 {
                    topics = list
                } else {
                    topics += list
                }
            }
            isHidden = true
        }
    }
}

struct ProfileTopicContentView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileTopicContentView(profile: ProfileUidModel())
    }
}

struct ProfileTopicListModel: Identifiable {
    var id = UUID()
    var title = ""
    var tid = ""
    var gif = ""
    var plate = ""
    var name = ""
    var time = ""
    var examine = 0
    var reply = 0
}
