//
//  TagListContentView.swift
//  Msea
//
//  Created by tzqiang on 2022/3/29.
//  Copyright © 2022 eternal.just. All rights reserved.
//

import SwiftUI
import Kanna

/// 标签列表
struct TagListContentView: View {
    var id = ""

    @StateObject var searchState: SearchState
    @State private var name = ""

    @State private var title = ""
    @State private var topics = [TagTopicListModel]()
    @State private var isHidden = false

    @State private var username = ""
    @State private var theUid = ""
    @State private var isSpace = false
    @State private var tid = ""
    @State private var isTopic = false
    @State private var nodeTitle = ""
    @State private var nodeFid = ""
    @State private var isNode = false

    var body: some View {
        ZStack {
            if topics.isEmpty {
                Text("没有此标签")
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
                                    .onTapGesture {
                                        if !topic.uid.isEmpty {
                                            theUid = topic.uid
                                            isSpace = true
                                        }
                                    }

                                    Spacer()

                                    Text(topic.plate)
                                        .font(.font15)
                                        .fixedSize(horizontal: false, vertical: true)
                                        .onTapGesture {
                                            if !topic.plate.isEmpty && !topic.fid.isEmpty {
                                                nodeTitle = topic.plate
                                                nodeFid = topic.fid
                                                isNode = true
                                            }
                                        }

                                    Spacer()

                                    VStack(alignment: .center) {
                                        Text(topic.lastName)
                                            .font(.font15)

                                        Text(topic.lastTime)
                                            .font(.font12)
                                    }
                                    .frame(width: UIDevice.current.isPad ? 250 : 100, alignment: .trailing)
                                    .onTapGesture {
                                        username = topic.lastName
                                        Task {
                                            await loadUid()
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
                                }

                                Text(topic.title)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .onTapGesture(perform: {
                                        if !topic.tid.isEmpty {
                                            tid = topic.tid
                                            isTopic = true
                                        }
                                    })
                            }
                            .padding([.top, .bottom], 5)
                        }
                    } header: {
                        HStack {
                            Text("作者")
                                .frame(width: 100, alignment: .leading)

                            Spacer()

                            Text("板块")

                            Spacer()

                            Text("最后发表")

                            Spacer()

                            Text("回复/查看")
                        }
                    }
                }
                .listStyle(.plain)
            }

            ProgressView()
                .isHidden(isHidden)
        }
        .navigationTitle(title)
        .navigationDestination(isPresented: $isSpace, destination: {
            SpaceProfileContentView(uid: theUid)
        })
        .navigationDestination(isPresented: $isTopic, destination: {
            TopicDetailContentView(tid: tid)
        })
        .navigationDestination(isPresented: $isNode, destination: {
            NodeListContentView(nodeTitle: nodeTitle, nodeFid: nodeFid)
        })
        .task {
            if !id.isEmpty && !isHidden {
                await loadData()
            }
        }
        .onAppear(perform: {
            if !id.isEmpty, topics.isEmpty {
                isHidden = false
            } else {
                isHidden = true
            }
        })
        .onChange(of: searchState.keywrod, { _, newValue in
            Task {
                if newValue.isEmpty {
                    name = ""
                    topics = []
                    title = "标签搜索"
                } else if newValue != name {
                    name = newValue
                    await loadData()
                }
            }
        })
    }

    private func loadData() async {
        isHidden = false
        topics = []
        Task {
            // swiftlint:disable force_unwrapping
            var url = URL(string: "https://www.chongbuluo.com/misc.php?mod=tag&id=\(id)")!
            if !name.isEmpty {
                let param = name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                url = URL(string: "https://www.chongbuluo.com/misc.php?mod=tag&name=\(param)")!
            }
            // swiftlint:enble force_unwrapping
            var request = URLRequest(url: url)
            request.configHeaderFields()
            let (data, _) = try await URLSession.shared.data(for: request)
            if let html = try? HTML(html: data, encoding: .utf8) {
                if let text = html.at_xpath("//div[@class='wp cl']/h1")?.text {
                    title = text
                }
                let content = html.xpath("//div[@class='bm_c']//table/tr")
                var list = [TagTopicListModel]()
                content.forEach { element in
                    var topic = TagTopicListModel()

                    if let gif = element.at_xpath("/td[@class='icn']/a/img/@src")?.text {
                        topic.gif = "https://www.chongbuluo.com/" + gif
                    }
                    if let text = element.at_xpath("/th/a")?.text {
                        topic.title = text
                    }
                    if let text = element.at_xpath("/th/a/@href")?.text {
                        topic.tid = text.getTid()
                    }
                    if let xg1 = element.at_xpath("/td[@class='by']/a")?.text {
                        topic.plate = xg1
                    }
                    if let href = element.at_xpath("/td[@class='by']/a/@href")?.text, href.contains("fid=") {
                        topic.fid = href.components(separatedBy: "fid=")[1]
                    }
                    if let reply = element.at_xpath("/td[@class='num']/a[@class='xi2']")?.text {
                        topic.reply = reply
                    }
                    if let examine = element.at_xpath("/td[@class='num']/em")?.text {
                        topic.examine = examine
                    }
                    if let name = element.at_xpath("/td[@class='by']/cite")?.text {
                        topic.name = name.replacingOccurrences(of: "\n", with: "")
                    }
                    if let uid = element.at_xpath("/td[@class='by']/cite/a/@href")?.text, uid.contains("uid") {
                        topic.uid = uid.getUid()
                    }
                    if let name = element.at_xpath("/td[@class='by'][last()]/cite")?.text {
                        topic.lastName = name.replacingOccurrences(of: "\n", with: "")
                    }
                    if let time = element.at_xpath("/td[@class='by']/em")?.text {
                        topic.time = time
                    }
                    if let time = element.at_xpath("/td[@class='by'][last()]/em")?.text {
                        topic.lastTime = time
                    }
                    print(topic)

                    list.append(topic)
                }

                topics = list
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

struct TagListContentView_Previews: PreviewProvider {
    static var previews: some View {
        TagListContentView(searchState: SearchState())
    }
}
