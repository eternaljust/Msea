//
//  SearchPostConentView.swift
//  Msea
//
//  Created by tzqiang on 2022/1/20.
//  Copyright © 2022 eternal.just. All rights reserved.
//

import SwiftUI
import Kanna
import IHome

/// 帖子搜索
struct SearchPostConentView: View {
    @State var searchState = SearchState()

    @State private var search = ""
    @State private var page = 1
    @State private var nextPage = false
    @State private var searchList = [SearchListModel]()
    @State private var href = ""
    @State private var result = ""

    @EnvironmentObject private var hud: HUDState

    var body: some View {
        VStack {
            if searchList.isEmpty {
                Text("对不起，没有找到匹配结果。")
            } else {
                List {
                    Section {
                        ForEach(searchList) { searchModel in
                            ZStack(alignment: .leading) {
                                VStack(alignment: .leading, spacing: 5) {
                                    getContentView(searchModel.title)
                                        .font(.font17Blod)
                                        .foregroundColor(.secondaryTheme)
                                        .fixedSize(horizontal: false, vertical: true)

                                    Text(searchModel.replyViews)
                                        .font(.font13)
                                        .foregroundColor(.secondary)

                                    getContentView(searchModel.content)
                                        .font(.font16)
                                        .multilineTextAlignment(.leading)
                                        .lineSpacing(5)
                                        .fixedSize(horizontal: false, vertical: true)

                                    Text("\(Text(searchModel.time).foregroundColor(.theme)) - \(Text(searchModel.name).foregroundColor(.secondary)) - \(Text(searchModel.plate).foregroundColor(.secondary))")
                                        .font(.font13)
                                        .onAppear {
                                            if searchModel.id == searchList.last?.id, nextPage {
                                                page += 1
                                                Task {
                                                    await loadData()
                                                }
                                            }
                                        }
                                }

                                NavigationLink(destination: TopicDetailContentView(tid: searchModel.tid)) {
                                    EmptyView()
                                }
                                .opacity(0.0)
                            }
                            .padding([.top, .bottom], 5)
                        }
                    } header: {
                        Text(result)
                    }
                }
                .listStyle(.plain)
            }
        }
        .onChange(of: searchState.keywrod, { _, newValue in
            Task {
                if newValue != search {
                    search = newValue
                    page = 1
                    await loadData()
                }
            }
        })
        .onAppear {
            Task {
                if !search.isEmpty && searchList.isEmpty {
                    page = 1
                    await loadData()
                }
            }
        }
    }

    private func loadData() async {
        Task {
            // swiftlint:disable force_unwrapping
            let parames = "&formhash=\(UserInfo.shared.formhash)&srchtxt=\(search)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            var url = URL(string: "https://www.chongbuluo.com/search.php?mod=forum&searchsubmit=yes&orderby=lastpost&ascdesc=desc&page=\(page)\(parames)")!
            if page > 1 && !href.isEmpty {
                url = URL(string: "https://www.chongbuluo.com/\(href)")!
            }
            print(url.absoluteString)
            // swiftlint:enble force_unwrapping
            var requset = URLRequest(url: url)
            requset.configHeaderFields()
            let (data, _) = try await URLSession.shared.data(for: requset)
            if let html = try? HTML(html: data, encoding: .utf8) {
                if let toHTML = html.toXML, toHTML.contains("下一页") {
                    nextPage = true
                } else {
                    nextPage = false
                }
                if let h2 = html.at_xpath("//h2")?.text {
                    result = h2
                }

                var list = [SearchListModel]()
                let li = html.xpath("//ul/li[@class='pbw']")
                li.forEach { element in
                    var search = SearchListModel()
                    if let tid = element.at_xpath("/@id")?.text {
                        search.tid = tid
                    }
                    if let title = element.at_xpath("//a[1]")?.text {
                        search.title = title
                    }
                    if let views = element.at_xpath("/p[@class='xg1']")?.text {
                        search.replyViews = views
                    }
                    if let content = element.at_xpath("/p[2]")?.text {
                        search.content = content
                    }
                    if let time = element.at_xpath("//span[1]")?.text {
                        search.time = time
                    }
                    if let name = element.at_xpath("//span/a[1]")?.text {
                        search.name = name
                    }
                    if let plate = element.at_xpath("//span/a[@class='xi1']")?.text {
                        search.plate = plate
                    }
                    list.append(search)
                }

                if page == 1 {
                    searchList = list
                } else {
                    searchList += list
                }
                let a = html.xpath("//div[@class='pgs cl mbm']//a")
                a.forEach { element in
                    if let text = element.text, text == "\(page + 1)", let href = element.at_xpath("/@href")?.text {
                        self.href = href
                    }
                }
            }
        }
    }

    @ViewBuilder private func getContentView(_ text: String) -> some View {
        if !text.contains(search) {
            Text(text)
        } else {
            let components = text.components(separatedBy: search)
            let texts = components.filter { str in
                return !str.isEmpty
            }
            if texts.count == 1 {
                if text.hasPrefix(search) {
                    Text(search).foregroundColor(.red) + Text(texts[0])
                } else if text.hasSuffix(search) {
                    Text(texts[0]) + Text(search).foregroundColor(.red)
                } else {
                    Text(text)
                }
            } else {
                let first = texts[0]
                texts.reduce(Text("")) {
                    $1 == first ? $0 + Text($1) : $0 + Text(search).foregroundColor(.red) + Text($1)
                }
            }
        }
    }
}

struct SearchPostConentView_Previews: PreviewProvider {
    static var previews: some View {
        SearchPostConentView(searchState: SearchState())
    }
}
