//
//  NodeContentView.swift
//  Msea
//
//  Created by Awro on 2022/2/26.
//  Copyright © 2022 eternal.just. All rights reserved.
//

import SwiftUI
import Kanna

/// 节点分区导航
struct NodeContentView: View {
    @State private var nodes = [NodeModel]()
    @State private var isHidden = false

    @State private var isTopic = false
    @State private var tid = ""
    @State private var isProfile = false
    @State private var username = ""
    @State private var uid = ""

    var body: some View {
        NavigationView {
            VStack {
                ZStack {
                    List {
                        ForEach(nodes) { node in
                            Section {
                                ForEach(node.list) { forum in
                                    VStack(alignment: .leading) {
                                        HStack {
                                            Image(systemName: forum.icon)
                                                .imageScale(.large)
                                                .foregroundColor(.theme)
                                                .frame(width: 40, height: 40)

                                            VStack(alignment: .leading, spacing: 5) {
                                                HStack {
                                                    Text(forum.title)
                                                        .font(.font17Blod)

                                                    if !forum.today.isEmpty {
                                                        Image(systemName: "\(forum.today).circle.fill")
                                                            .resizable()
                                                            .symbolRenderingMode(.palette)
                                                            .foregroundStyle(.white, .red)
                                                            .frame(width: 18, height: 18)
                                                    }
                                                }

                                                Text(forum.count)
                                                    .font(.font13)
                                            }

                                            Spacer()
                                        }

                                        HStack {
                                            Text(forum.content)
                                                .onTapGesture {
                                                    tid = forum.tid
                                                    isTopic = true
                                                }

                                            Spacer()

                                            Text(forum.time)
                                                .foregroundColor(.secondary)

                                            Text(forum.username)
                                                .onTapGesture {
                                                    username = forum.username
                                                    Task {
                                                        await loadUid()
                                                    }
                                                }
                                        }
                                        .foregroundColor(.secondaryTheme)
                                        .fixedSize(horizontal: false, vertical: true)
                                    }
                                    .padding([.top, .bottom], 5)
                                }
                            } header: {
                                HStack {
                                    Text(node.title)

                                    Spacer()

                                    if !node.moderators.isEmpty {
                                        Text("分区版主：")

                                        ForEach(node.moderators, id: \.self) { user in
                                            Text(user)
                                                .foregroundColor(.secondaryTheme)
                                                .onTapGesture {
                                                    username = user
                                                    Task {
                                                        await loadUid()
                                                    }
                                                }
                                        }
                                    }
                                }
                                .font(.font17)
                            }
                        }
                    }
                    .listStyle(.plain)
                    .refreshable {
                        Task {
                            await loadData()
                        }
                    }
                    .task {
                        if !isHidden {
                            await loadData()
                        }
                    }

                    ProgressView()
                        .isHidden(isHidden)

                    NavigationLink(destination: TopicDetailContentView(tid: tid), isActive: $isTopic) {
                        EmptyView()
                    }
                    .opacity(0.0)

                    NavigationLink(destination: SpaceProfileContentView(uid: uid), isActive: $isProfile) {
                        EmptyView()
                    }
                    .opacity(0.0)
                }
            }
            .navigationBarTitle("节点")
            .onAppear(perform: {
                TabBarTool.showTabBar(true)
                CacheInfo.shared.selectedTab = .node
            })

            Text("选择你感兴趣的分区吧")
        }
    }

    private func loadData() async {
        Task {
            // swiftlint:disable force_unwrapping
            let url = URL(string: "https://www.chongbuluo.com/forum.php?mod=index")!
            // swiftlint:enble force_unwrapping
            var requset = URLRequest(url: url)
            requset.configHeaderFields()
            let (data, _) = try await URLSession.shared.data(for: requset)
            if let html = try? HTML(html: data, encoding: .utf8) {
                let category = html.xpath("//div[@class='bm bmw  flg cl']")
                var nodes = [NodeModel]()
                category.forEach { element in
                    var node = NodeModel()
                    if let title = element.at_xpath("/div[@class='bm_h cl']/h2/a")?.text {
                        node.title = title
                    }
                    let span = element.xpath("/div[@class='bm_h cl']/span/a")
                    var users = [String]()
                    span.forEach { a in
                        if let name = a.text {
                            users.append(name)
                        }
                    }
                    node.moderators = users

                    var list = [NodeListModel]()
                    let td = element.xpath("//td[@class='fl_g']")
                    td.forEach { dl in
                        var model = NodeListModel()
                        if let forum = dl.at_xpath("/div[@class='fl_icn_g']/a/@href")?.text {
                            if forum.contains("forum-") {
                                let id = forum.components(separatedBy: "forum-")[1].components(separatedBy: "-")[0]
                                model.fid = id
                            } else if forum.contains("fid=") {
                                model.fid = forum.components(separatedBy: "fid=")[1]
                            }
                        }
                        if let title = dl.at_xpath("/dl/dt/a")?.text {
                            model.title = title
                        }
                        if let today = dl.at_xpath("/dl/dt/em[@class='xw0 xi1']")?.text {
                            model.today = today
                        }
                        if let count = dl.at_xpath("/dl/dd[1]")?.text {
                            model.count = count
                        }
                        if let content = dl.at_xpath("/dl/dd[2]/a")?.text {
                            model.content = content
                        }
                        if let tid = dl.at_xpath("/dl/dd[2]/a/@href")?.text {
                            if tid.contains("tid="), tid.contains("goto=") {
                                model.tid = tid.components(separatedBy: "goto=")[0].components(separatedBy: "tid=")[1]
                            }
                        }
                        if let time = dl.at_xpath("/dl/dd[2]/cite/span")?.text {
                            model.time = time
                        }
                        if let name = dl.at_xpath("/dl/dd[2]/cite/a")?.text {
                            model.username = name
                        }
                        if let time = dl.at_xpath("/dl/dd[2]/cite")?.text, !time.isEmpty {
                            model.time = time.replacingOccurrences(of: " \(model.username)", with: "")
                        }

                        list.append(model)
                    }
                    node.list = list

                    nodes.append(node)
                }

                isHidden = true
                self.nodes = nodes
            }
        }
    }

    private func loadUid() async {
        uid = ""
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
                var id = ""
                if let src = html.at_xpath("//div[@id='profile_content']//img/@src")?.text, !src.isEmpty {
                    id = src
                } else if let src = html.at_xpath("//div[@class='wp cl']//span[@class='xs0 xw0']/a[last()]/@href")?.text {
                    id = src
                }
                print(id)
                id = id.replacingOccurrences(of: "&size=middle", with: "")
                id = id.replacingOccurrences(of: "&size=big", with: "")
                id = id.replacingOccurrences(of: "&size=small", with: "")
                id = id.replacingOccurrences(of: "&boan_h5avatar=yes", with: "")
                if id.contains("uid=") {
                    uid = id.components(separatedBy: "uid=")[1]
                }
                if !uid.isEmpty {
                    isProfile = true
                }
                isHidden = true
            }
        }
    }
}

struct NodeContentView_Previews: PreviewProvider {
    static var previews: some View {
        NodeContentView()
    }
}

struct NodeListModel: Identifiable {
    var id = UUID()
    var fid = ""
    var tid = ""
    var title = ""
    var today = ""
    var count = ""
    var content = ""
    var time = ""
    var username = ""
    var icon: String {
        switch fid {
        case "2": return "laptopcomputer"
        case "44": return "key"
        case "47": return "square.grid.3x3.bottomleft.filled"
        case "93": return "plus.magnifyingglass"
        case "98": return "w.circle"
        case "112": return "yensign.circle"
        case "113": return "lightbulb"
        case "114": return "icloud.and.arrow.down"
        case "117": return "list.bullet.rectangle.portrait"
        case "119": return "eye"
        case "120": return "sun.max"
        case "121": return "building"
        case "122": return "highlighter"
        case "123": return "arrow.up.heart"
        case "125": return "eye.slash"
        case "126": return "g.circle"
        case "127": return "applelogo"
        case "128": return "gyroscope"
        default: return "yensign.circle"
        }
    }
}

struct NodeModel: Identifiable {
    var id = UUID()
    var title = ""
    var moderators = [String]()
    var list = [NodeListModel]()
}
