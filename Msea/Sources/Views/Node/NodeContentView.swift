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
    var gid = ""

    @State private var nodes = [NodeModel]()
    @State private var isHidden = false
    @State private var isLogin = UserInfo.shared.isLogin()

    @State private var isTopic = false
    @State private var tid = ""
    @State private var fid = ""
    @State private var isProfile = false
    @State private var username = ""
    @State private var uid = ""
    @State private var isNode = false
    @State private var selectedNode = NodeListModel()
    @State private var isWiki = false
    @State private var isTag = false

    var body: some View {
        if gid.isEmpty {
            NavigationView {
                getContentView()
            }
        } else {
            getContentView()
        }
    }

    @ViewBuilder private func getContentView() -> some View {
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
                                    .onTapGesture {
                                        if forum.fid == "98" {
                                            if UIDevice.current.isPad {
                                                isWiki.toggle()
                                            } else {
                                                isWiki = true
                                            }
                                        } else {
                                            selectedNode = forum
                                            if UIDevice.current.isPad {
                                                isNode.toggle()
                                            } else {
                                                isNode = true
                                            }
                                        }
                                    }

                                    HStack {
                                        Text(forum.content)
                                            .onTapGesture {
                                                tid = forum.tid
                                                fid = forum.fid
                                                if UIDevice.current.isPad {
                                                    isTopic.toggle()
                                                } else {
                                                    isTopic = true
                                                }
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

                NavigationLink(destination: NodeListContentView(nodeTitle: selectedNode.title, nodeFid: selectedNode.fid), isActive: $isNode) {
                    EmptyView()
                }
                .opacity(0.0)

                NavigationLink(destination: NodeWikiContentView(), isActive: $isWiki) {
                    EmptyView()
                }
                .opacity(0.0)

                NavigationLink(destination: TagContentView(), isActive: $isTag) {
                    EmptyView()
                }
                .opacity(0.0)
            }
        }
        .navigationBarTitle("节点")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    isTag.toggle()
                } label: {
                    Image(systemName: "tag")
                }
                .isHidden(!isLogin)
            }
        }
        .onAppear(perform: {
            isLogin = UserInfo.shared.isLogin()
            TabBarTool.showTabBar(gid.isEmpty)
            CacheInfo.shared.selectedTab = .node
        })
        .onChange(of: isProfile) { newValue in
            if UIDevice.current.isPad && newValue {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isProfile.toggle()
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
        .onChange(of: isNode) { newValue in
            if UIDevice.current.isPad && newValue {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isNode.toggle()
                }
            }
        }
        .onChange(of: isWiki) { newValue in
            if UIDevice.current.isPad && newValue {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isWiki.toggle()
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .login, object: nil)) { _ in
            isLogin = true
        }
        .onReceive(NotificationCenter.default.publisher(for: .logout, object: nil)) { _ in
            isLogin = false
        }

        if gid.isEmpty {
            Text("选择你感兴趣的分区吧")
        }
    }

    private func loadData() async {
        Task {
            // swiftlint:disable force_unwrapping
            let url = URL(string: "https://www.chongbuluo.com/forum.php?mod=index&gid=\(gid)")!
            // swiftlint:enble force_unwrapping
            var requset = URLRequest(url: url)
            requset.configHeaderFields()
            let (data, _) = try await URLSession.shared.data(for: requset)
            if let html = try? HTML(html: data, encoding: .utf8) {
                var category = html.xpath("//div[@class='bm bmw  flg cl']")
                if category.first == nil {
                    category = html.xpath("//div[@class='bm bmw  cl']")
                }
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
                    // 搜索
                    if gid == "92" && list.isEmpty {
                        let tr = element.xpath("//table[@class='fl_tb']/tr")
                        tr.forEach { dl in
                            var model = NodeListModel()
                            if let forum = dl.at_xpath("/td[2]/h2/a/@href")?.text {
                                if forum.contains("forum-") {
                                    let id = forum.components(separatedBy: "forum-")[1].components(separatedBy: "-")[0]
                                    model.fid = id
                                } else if forum.contains("fid=") {
                                    model.fid = forum.components(separatedBy: "fid=")[1]
                                }
                            }
                            if let title = dl.at_xpath("/td[2]/h2/a")?.text {
                                model.title = title
                            }
                            if let today = dl.at_xpath("/td[2]/h2/em[@class='xw0 xi1']")?.text {
                                model.today = today
                            }
                            if let count = dl.at_xpath("/td[@class='fl_i']")?.text {
                                model.count = count.replacingOccurrences(of: "\r\n", with: "")
                            }

                            if let content = dl.at_xpath("/td[@class='fl_by']/div/a[@class='xi2']")?.text {
                                model.content = content
                            }
                            if let tid = dl.at_xpath("/td[@class='fl_by']/div/a[@class='xi2']/@href")?.text {
                                if tid.contains("tid="), tid.contains("goto=") {
                                    model.tid = tid.components(separatedBy: "goto=")[0].components(separatedBy: "tid=")[1]
                                }
                            }
                            if let time = dl.at_xpath("/td[@class='fl_by']/div/cite/span")?.text {
                                model.time = time
                            }
                            if let name = dl.at_xpath("/td[@class='fl_by']/div/cite/a")?.text {
                                model.username = name
                            }

                            if !model.title.isEmpty {
                                list.append(model)
                            }
                        }
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
                uid = html.getProfileUid()
                if !uid.isEmpty {
                    if await UIDevice.current.isPad {
                        isProfile.toggle()
                    } else {
                        isProfile = true
                    }
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
