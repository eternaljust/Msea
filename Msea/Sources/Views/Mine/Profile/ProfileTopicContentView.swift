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
    var uid = ""

    @State private var page = 1
    @State private var topics = [ProfileTopicListModel]()
    @State private var isHidden = false
    @State private var isPosterShielding = false

    @State private var username = ""
    @State private var theUid = ""
    @State private var isSpace = false
    @State private var tid = ""
    @State private var isTopic = false
    @State private var nodeTitle = ""
    @State private var nodeFid = ""
    @State private var isNode = false

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
                                    .onTapGesture {
                                        username = topic.name
                                        Task {
                                            await loadUid()
                                        }
                                    }

                                    Spacer()

                                    Text(topic.plate)
                                        .font(.font15)
                                        .frame(width: uid == UserInfo.shared.uid ? 70 : (UIDevice.current.isPad ? 140 : 70))
                                        .fixedSize(horizontal: false, vertical: true)
                                        .onTapGesture {
                                            if !topic.plate.isEmpty && !topic.fid.isEmpty {
                                                nodeTitle = topic.plate
                                                nodeFid = topic.fid
                                                isNode = true
                                            }
                                        }

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
                                    .onTapGesture(perform: {
                                        if !topic.tid.isEmpty {
                                            tid = topic.tid
                                            isTopic = true
                                        }
                                    })
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

            NavigationLink(destination: SpaceProfileContentView(uid: theUid), isActive: $isSpace) {
                EmptyView()
            }
            .opacity(0.0)

            NavigationLink(destination: TopicDetailContentView(tid: tid, isNodeFid125: false), isActive: $isTopic) {
                EmptyView()
            }
            .opacity(0.0)

            NavigationLink(destination: NodeListContentView(nodeTitle: nodeTitle, nodeFid: nodeFid), isActive: $isNode) {
                EmptyView()
            }
            .opacity(0.0)
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
        .onChange(of: isTopic) { newValue in
            if UIDevice.current.isPad && newValue {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isTopic.toggle()
                }
            }
        }
        .onChange(of: isSpace) { newValue in
            if UIDevice.current.isPad && newValue {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isSpace.toggle()
                }
            }
        }
    }

    private func loadData() async {
        Task {
            // swiftlint:disable force_unwrapping
            let url = URL(string: "https://www.chongbuluo.com/home.php?mod=space&uid=\(uid)&do=thread&view=me&from=space&type=thread&page=\(page)")!
            // swiftlint:enble force_unwrapping
            var request = URLRequest(url: url)
            request.configHeaderFields()
            let (data, _) = try await URLSession.shared.data(for: request)
            if let html = try? HTML(html: data, encoding: .utf8) {
                let content = html.xpath("//div[@class='tl']/form/table/tr")
                var list = [ProfileTopicListModel]()
                content.forEach { element in
                    var topic = ProfileTopicListModel()
                    if let gif = element.at_xpath("/td[@class='icn']/a/img/@src")?.text {
                        topic.gif = "https://www.chongbuluo.com/" + gif
                    }
                    if let text = element.at_xpath("/th/a")?.text {
                        topic.title = text
                    }
                    if let text = element.at_xpath("/th/a/@href")?.text {
                        topic.tid = text.getTid()
                    }
                    if let xg1 = element.at_xpath("/td/a[@class='xg1']")?.text {
                        topic.plate = xg1
                    }
                    if let href = element.at_xpath("/td/a[@class='xg1']/@href")?.text, href.contains("fid=") {
                        topic.fid = href.components(separatedBy: "fid=")[1]
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

                    if !topic.title.isEmpty {
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

    private func loadUid() async {
        theUid = ""
        Task {
            isHidden = false
            // swiftlint:disable force_unwrapping
            let parames = "&username=\(username)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            let url = URL(string: "https://www.chongbuluo.com/home.php?mod=space\(parames)")!
            // swiftlint:enble force_unwrapping
            var request = URLRequest(url: url)
            request.configHeaderFields()
            let (data, _) = try await URLSession.shared.data(for: request)
            if let html = try? HTML(html: data, encoding: .utf8) {
                theUid = html.getProfileUid()
                if !theUid.isEmpty {
                    if UIDevice.current.isPad {
                        isSpace.toggle()
                    } else {
                        isSpace = true
                    }
                }
                isHidden = true
            }
        }
    }
}

struct ProfileTopicContentView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileTopicContentView()
    }
}
