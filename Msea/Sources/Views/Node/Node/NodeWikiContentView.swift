//
//  NodeWikiContentView.swift
//  Msea
//
//  Created by Awro on 2022/3/5.
//  Copyright © 2022 eternal.just. All rights reserved.
//

import SwiftUI
import Kanna

/// 节点 Wiki
struct NodeWikiContentView: View {
    @State private var wikis = [NodeWikiListModel]()
    @State private var isHidden = false
    @State private var page = 1
    @State private var nextPage = false

    @State private var languages = [NodeWikiLanguagePlantFieldModel]()
    @State private var plants = [NodeWikiLanguagePlantFieldModel]()
    @State private var fields = [NodeWikiLanguagePlantFieldModel]()

    @State private var languageWiki = "all"
    @State private var plantWiki = "all"
    @State private var fieldWiki = "all"
    @State private var languageTitle = "不限"
    @State private var plantTitle = "不限"
    @State private var fieldTitle = "不限"
    @State private var headerTitle = " 语言:不限   版本:不限   领域:不限"

    @State private var uid = ""
    @State private var isSpace = false
    @State private var tid = ""
    @State private var isTopic = false

    let columns = [
        GridItem(.adaptive(minimum: 160, maximum: 200), spacing: 20)
    ]

    var body: some View {
        ZStack {
            if wikis.isEmpty {
                Text("本版块或指定的范围内尚无主题")
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, alignment: .leading, spacing: 10, pinnedViews: [.sectionHeaders]) {
                        Section {
                            ForEach(wikis) { wiki in
                                VStack(alignment: .center) {
                                    ZStack {
                                        AsyncImage(url: URL(string: wiki.bannerImage)) { image in
                                            image.resizable()
                                        } placeholder: {
                                            ProgressView()
                                        }
                                        .frame(height: 125)
                                        .cornerRadius(5)

                                        VStack {
                                            Text(wiki.title)
                                                .font(.font16)
                                                .foregroundColor(.white)
                                                .lineLimit(2)
                                                .multilineTextAlignment(.leading)
                                                .fixedSize(horizontal: false, vertical: true)
                                                .padding(EdgeInsets(top: 1, leading: 5, bottom: 1, trailing: 5))
                                                .background(Color(hex: "8390a3").opacity(0.5))

                                            Spacer()
                                        }
                                        .padding(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))
                                    }
                                    .frame(height: 125)
                                    .onTapGesture(perform: {
                                        if !wiki.tid.isEmpty {
                                            tid = wiki.tid
                                            isTopic = true
                                        }
                                    })

                                    HStack {
                                        AsyncImage(url: URL(string: wiki.avatar)) { image in
                                            image.resizable()
                                        } placeholder: {
                                            ProgressView()
                                        }
                                        .frame(width: 40, height: 40)
                                        .cornerRadius(20)

                                        VStack(alignment: .leading, spacing: 5) {
                                            Text(wiki.name)
                                                .font(.font17Blod)

                                            HStack {
                                                Label(title: {
                                                    Text(wiki.views)
                                                }, icon: {
                                                    Image(systemName: "eye")
                                                })

                                                Label(title: {
                                                    Text(wiki.comment)
                                                }, icon: {
                                                    Image(systemName: "message")
                                                })
                                            }
                                            .font(.font13)
                                        }

                                        Spacer()
                                    }
                                    .padding(.top, 5)
                                    .onTapGesture(perform: {
                                        if !wiki.uid.isEmpty {
                                            uid = wiki.uid
                                            isSpace = true
                                        }
                                    })
                                    .onAppear {
                                        if wiki.id == wikis.last?.id, nextPage {
                                            page += 1
                                            Task {
                                                await loadData()
                                            }
                                        }
                                    }
                                }
                                .padding(.bottom, 15)
                            }
                        } header: {
                            HStack {
                                Text(headerTitle)
                                    .foregroundColor(.secondary)
                                    .font(.font15)
                                    .padding(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))

                                Spacer()
                            }
                            .background(Color.backGround)
                        }
                    }
                    .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
                    .refreshable {
                        await loadData()
                    }
                }
            }

            ProgressView()
                .isHidden(isHidden)

            NavigationLink(destination: SpaceProfileContentView(uid: uid), isActive: $isSpace) {
                EmptyView()
            }
            .opacity(0.0)

            NavigationLink(destination: TopicDetailContentView(tid: tid, isNodeFid125: false), isActive: $isTopic) {
                EmptyView()
            }
            .opacity(0.0)
        }
        .navigationBarTitle("Wiki")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    if !languages.isEmpty {
                        Menu("语言") {
                            ForEach(languages) { item in
                                Button(item.title) {
                                    languageWiki = item.wiki
                                    languageTitle = item.title
                                    updateHeaderTitle()
                                    Task {
                                        page = 1
                                        await loadData()
                                    }
                                }
                            }
                        }
                    }

                    if !plants.isEmpty {
                        Menu("版本") {
                            ForEach(plants) { item in
                                Button(item.title) {
                                    plantWiki = item.wiki
                                    plantTitle = item.title
                                    updateHeaderTitle()
                                    Task {
                                        page = 1
                                        await loadData()
                                    }
                                }
                            }
                        }
                    }

                    if !fields.isEmpty {
                        Menu("领域") {
                            ForEach(fields) { item in
                                Button(item.title) {
                                    fieldWiki = item.wiki
                                    fieldTitle = item.title
                                    updateHeaderTitle()
                                    Task {
                                        page = 1
                                        await loadData()
                                    }
                                }
                            }
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis")
                }
            }
        }
        .task {
            if languages.isEmpty || plants.isEmpty || fields.isEmpty {
                await getFilterMenu()
            }
            if wikis.isEmpty {
                await loadData()
            }
        }
        .onAppear {
            if !UIDevice.current.isPad {
                TabBarTool.showTabBar(false)
            }
        }
    }

    private func updateHeaderTitle() {
        headerTitle = " 语言:\(languageTitle)  版本:\(plantTitle)   领域:\(fieldTitle)"
    }

    private func getFilterMenu() async {
        isHidden = false
        Task {
            // swiftlint:disable force_unwrapping
            let url = URL(string: "https://www.chongbuluo.com/forum.php?mod=forumdisplay&fid=98")!
            // swiftlint:enble force_unwrapping
            var requset = URLRequest(url: url)
            requset.configHeaderFields()
            let (data, _) = try await URLSession.shared.data(for: requset)
            if let html = try? HTML(html: data, encoding: .utf8) {
                var list1 = [NodeWikiLanguagePlantFieldModel]()
                let tr1 = html.xpath("//table[@class='tsm cl']/tr[1]//li")
                tr1.forEach { element in
                    var model = NodeWikiLanguagePlantFieldModel()
                    if let href = element.at_xpath("/a/@href")?.text, href.contains("language=") {
                        model.wiki = href.components(separatedBy: "language=")[1]
                    }
                    if let title = element.at_xpath("/a")?.text {
                        model.title = title
                    }
                    list1.append(model)
                }
                languages = list1

                var list2 = [NodeWikiLanguagePlantFieldModel]()
                let tr2 = html.xpath("//table[@class='tsm cl']/tr[2]//li")
                tr2.forEach { element in
                    var model = NodeWikiLanguagePlantFieldModel()
                    if let href = element.at_xpath("/a/@href")?.text, href.contains("plant=") {
                        model.wiki = href.components(separatedBy: "plant=")[1]
                    }
                    if let title = element.at_xpath("/a")?.text {
                        model.title = title
                    }
                    list2.append(model)
                }
                plants = list2

                var list3 = [NodeWikiLanguagePlantFieldModel]()
                let tr3 = html.xpath("//table[@class='tsm cl']/tr[3]//li")
                tr3.forEach { element in
                    var model = NodeWikiLanguagePlantFieldModel()
                    if let href = element.at_xpath("/a/@href")?.text, href.contains("field=") {
                        model.wiki = href.components(separatedBy: "field=")[1]
                    }
                    if let title = element.at_xpath("/a")?.text {
                        model.title = title
                    }
                    list3.append(model)
                }
                fields = list3
            }
            isHidden = true
        }
    }

    private func loadData() async {
        Task {
            // swiftlint:disable force_unwrapping
            let url = URL(string: "https://www.chongbuluo.com/forum.php?mod=forumdisplay&fid=98&sortid=1&filter=sortid&sortid=1&searchsort=1&field=\(fieldWiki)&plant=\(plantWiki)&language=\(languageWiki)&page=\(page)")!
            // swiftlint:enble force_unwrapping
            var requset = URLRequest(url: url)
            requset.configHeaderFields()
            let (data, _) = try await URLSession.shared.data(for: requset)
            if let html = try? HTML(html: data, encoding: .utf8) {
                if let toHTML = html.toHTML, toHTML.contains("下一页") {
                    nextPage = true
                } else {
                    nextPage = false
                }

                var list = [NodeWikiListModel]()
                let li = html.xpath("//div[@id='main']//li")
                li.forEach { element in
                    var model = NodeWikiListModel()
                    if let href = element.at_xpath("/a[@class='banner']/@href")?.text, href.contains("thread-") {
                        model.tid = href.components(separatedBy: "-")[1]
                    }
                    if let title = element.at_xpath("/a[@class='banner']/span[@class='wikititle']")?.text {
                        model.title = title
                    }
                    if let src = element.at_xpath("/a[@class='banner']/img/@src")?.text {
                        model.bannerImage = "https://www.chongbuluo.com/\(src)"
                    }
                    if let src = element.at_xpath("/div[@class='info']/a[1]/img/@src")?.text {
                        model.avatar = src.replacingOccurrences(of: "&size=small", with: "")
                    }
                    if let name = element.at_xpath("/div[@class='info']/a[3]")?.text {
                        model.name = name
                    }
                    if let uid = element.at_xpath("/div[@class='info']/a[3]/@href")?.text {
                        model.uid = uid.getUid()
                    }
                    if let comment = element.at_xpath("/div[@class='info']/em[1]")?.text {
                        model.comment = comment.replacingOccurrences(of: " ", with: "")
                    }
                    if let views = element.at_xpath("/div[@class='info']/em[2]")?.text {
                        model.views = views.replacingOccurrences(of: " ", with: "")
                    }
                    list.append(model)
                }
                if page == 1 {
                    wikis = list
                } else {
                    wikis += list
                }
                isHidden = true
            }
        }
    }
}

struct NodeWikiContentView_Previews: PreviewProvider {
    static var previews: some View {
        NodeWikiContentView()
    }
}
