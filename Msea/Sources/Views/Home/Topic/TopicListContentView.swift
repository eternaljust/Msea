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

    @State private var uid = ""
    @State private var isSpace = false
    @State private var tid = ""
    @State private var isTopic = false

    var body: some View {
        ZStack {
            List(topics) { topic in
                VStack(alignment: .leading) {
                    HStack {
                        HStack {
                            AsyncImage(url: URL(string: "https://www.chongbuluo.com/\(topic.avatar)")) { image in
                                image.resizable()
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(width: 40, height: 40)
                            .cornerRadius(5)
                            .onTapGesture(perform: {
                                if !topic.uid.isEmpty {
                                    gotoProfileSpace(topic.uid)
                                }
                            })

                            VStack(alignment: .leading, spacing: 5) {
                                HStack {
                                    Text(topic.name)
                                        .font(.font17Blod)
                                        .onTapGesture(perform: {
                                            if !topic.uid.isEmpty {
                                                gotoProfileSpace(topic.uid)
                                            }
                                        })

                                    Spacer()

                                    Text("\(topic.reply)/\(topic.examine)")
                                        .padding(EdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5))
                                        .foregroundColor(.white)
                                        .background(
                                            Capsule()
                                                .foregroundColor(.secondaryTheme.opacity(0.8))
                                        )
                                }

                                HStack {
                                    Text(topic.time)
                                        .font(.font13)

                                    if !topic.icon1.isEmpty {
                                        Image(systemName: topic.icon1)
                                            .foregroundColor(getColor(topic.icon1))
                                    }

                                    if !topic.icon2.isEmpty {
                                        Image(systemName: topic.icon2)
                                            .foregroundColor(getColor(topic.icon2))
                                    }

                                    if !topic.icon3.isEmpty {
                                        Image(systemName: topic.icon3)
                                            .foregroundColor(getColor(topic.icon3))
                                    }

                                    if !topic.icon4.isEmpty {
                                        Image(systemName: topic.icon4)
                                            .foregroundColor(getColor(topic.icon4))
                                    }
                                }
                            }
                        }
                    }

                    Text("\(topic.title)\(Text(topic.attachment).foregroundColor(topic.attachmentColorRed ? .red : Color(light: .black, dark: .white)))")
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
                .onTapGesture(perform: {
                    if !topic.tid.isEmpty {
                        tid = topic.tid
                        if UIDevice.current.isPad {
                            isTopic.toggle()
                        } else {
                            isTopic = true
                        }
                    }
                })
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

            NavigationLink(destination: SpaceProfileContentView(uid: uid), isActive: $isSpace) {
                EmptyView()
            }
            .opacity(0.0)

            NavigationLink(destination: TopicDetailContentView(tid: tid), isActive: $isTopic) {
                EmptyView()
            }
            .opacity(0.0)
        }
        .onAppear {
            shieldUsers()
        }
        .onReceive(NotificationCenter.default.publisher(for: .shieldUser, object: nil)) { _ in
            shieldUsers()
        }
        .onChange(of: isSpace) { newValue in
            if UIDevice.current.isPad && newValue {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isSpace.toggle()
                }
            }
        }
        .onChange(of: isTopic) { newValue in
            if UIDevice.current.isPad && newValue {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isTopic.toggle()
                }
            }
        }
    }

    private func gotoProfileSpace(_ uid: String) {
        self.uid = uid
        if UIDevice.current.isPad {
            isSpace.toggle()
        } else {
            isSpace = true
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
                        if let name = element.at_xpath("//th[@class='common']/span[1]/@class")?.text {
                            topic.icon1 = getIcon(name)
                        }
                        if let name = element.at_xpath("//th[@class='common']/span[2]/@class")?.text {
                            topic.icon2 = getIcon(name)
                        }
                        if let name = element.at_xpath("//th[@class='common']/span[3]/@class")?.text {
                            topic.icon3 = getIcon(name)
                        }
                        if let name = element.at_xpath("//th[@class='common']/span[4]/@class")?.text {
                            topic.icon4 = getIcon(name)
                        }
                        if let text = element.at_xpath("//th[@class='common']/span[@class='xi1']")?.text, !text.isEmpty {
                            topic.attachment = text
                        } else if var text = element.at_xpath("//th[@class='common']")?.text, text.count != title.count {
                            text = text.replacingOccurrences(of: "\r\n", with: "")
                            var attachment = text.replacingOccurrences(of: title, with: "")
                            if let num = element.at_xpath("//th[@class='common']/span[@class='tps']")?.text {
                                attachment = attachment.replacingOccurrences(of: num, with: "")
                            }
                            attachment = attachment.replacingOccurrences(of: " ", with: "")
                            topic.attachment = attachment
                        }
                        if !topic.attachment.isEmpty {
                            topic.attachment = topic.attachment.replacingOccurrences(of: "-", with: "")
                            topic.attachment = " - \(topic.attachment)"
                            topic.attachmentColorRed = topic.attachment.contains("回帖") || topic.attachment.contains("悬赏")
                        }
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
                            topic.uid = uid.getUid()
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

    private func getIcon(_ name: String) -> String {
        if name == "iconfont icon-image" {
            return "photo"
        } else if name == "iconfont icon-fire" {
            return "flame"
        } else if name == "iconfont icon-guzhang1" {
            return "hands.sparkles"
        } else if name == "iconfont icon-attachment1" {
            return "link"
        } else if name == "iconfont icon-jinghua" {
            return "rosette"
        }
        return ""
    }

    private func getColor(_ icon: String) -> Color {
        if icon == "photo" {
            return .theme
        } else if icon == "flame" {
            return .red
        } else if icon == "hands.sparkles" {
            return .secondaryTheme
        } else if icon == "link" {
            return .blue
        } else if icon == "rosette" {
            return .brown
        }
        return .theme
    }
}

struct TopicListContentView_Previews: PreviewProvider {
    static var previews: some View {
        TopicListContentView()
    }
}
