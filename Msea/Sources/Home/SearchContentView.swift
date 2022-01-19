//
//  SearchContentView.swift
//  Msea
//
//  Created by tzqiang on 2022/1/19.
//  Copyright © 2022 eternal.just. All rights reserved.
//

import SwiftUI
import Kanna

/// 站内搜索
struct SearchContentView: View {
    @State private var search = ""
    @State private var page = 1
    @State private var nextPage = false
    @State private var searchList = [SearchListModel]()
    @State private var href = ""
    @State private var result = ""

    @Environment(\.dismiss) private var dismiss
    @FocusState private var focused: Bool
    @EnvironmentObject private var hud: HUDState

    var body: some View {
        VStack {
            List {
                Section {
                    ForEach(searchList) { searchModel in
                        ZStack(alignment: .leading) {
                            VStack(alignment: .leading) {
                                getContentView(searchModel.title)
                                    .font(.headline)
                                    .foregroundColor(.secondaryTheme)
                                    .fixedSize(horizontal: false, vertical: true)

                                Text(searchModel.replyViews)
                                    .font(.footnote)
                                    .foregroundColor(.secondary)

                                getContentView(searchModel.content)
                                    .fixedSize(horizontal: false, vertical: true)

                                Text("\(Text(searchModel.time).foregroundColor(.theme)) - \(Text(searchModel.name).foregroundColor(.secondary)) - \(Text(searchModel.plate).foregroundColor(.secondary))")
                                    .font(.footnote)
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
                    }
                } header: {
                    Text(result)
                }
            }
            .listStyle(.plain)
        }
        .toolbar(content: {
            ToolbarItem(placement: .principal) {
                TextField("站内搜索", text: $search)
                    .textFieldStyle(.roundedBorder)
                    .focused($focused)
                    .submitLabel(.search)
                    .onSubmit {
                        Task {
                            page = 1
                            await loadData()
                        }
                    }
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    dismiss()
                } label: {
                    Text("取消")
                }
            }
        })
        .navigationBarBackButtonHidden(true)
        .navigationBarTitle("站内搜索")
        .onAppear {
            TabBarTool.showTabBar(false)
        }
    }

    private func loadData() async {
        Task {
            if search.isEmpty {
                hud.show(message: "请输入内容")
                return
            }

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
                if let toHTML = html.toHTML, toHTML.contains("下一页") {
                    nextPage = true
                } else {
                    nextPage = false
                }
                if let h2 = html.at_xpath("//h2", namespaces: nil)?.text {
                    result = h2
                }

                var list = [SearchListModel]()
                let li = html.xpath("//ul/li[@class='pbw']", namespaces: nil)
                li.forEach { element in
                    var search = SearchListModel()
                    if let tid = element.at_xpath("/@id", namespaces: nil)?.text {
                        search.tid = tid
                    }
                    if let title = element.at_xpath("//a[1]", namespaces: nil)?.text {
                        search.title = title
                    }
                    if let views = element.at_xpath("/p[@class='xg1']", namespaces: nil)?.text {
                        search.replyViews = views
                    }
                    if let content = element.at_xpath("/p[2]", namespaces: nil)?.text {
                        search.content = content
                    }
                    if let time = element.at_xpath("//span[1]", namespaces: nil)?.text {
                        search.time = time
                    }
                    if let name = element.at_xpath("//span/a[1]", namespaces: nil)?.text {
                        search.name = name
                    }
                    if let plate = element.at_xpath("//span/a[@class='xi1']", namespaces: nil)?.text {
                        search.plate = plate
                    }
                    list.append(search)
                }

                if page == 1 {
                    searchList = list
                } else {
                    searchList += list
                }
                let a = html.xpath("//div[@class='pgs cl mbm']//a", namespaces: nil)
                a.forEach { element in
                    if let text = element.text, text == "\(page + 1)", let href = element.at_xpath("/@href", namespaces: nil)?.text {
                        self.href = href
                    }
                }
            }
        }
    }

    @ViewBuilder private func getContentView(_ text: String) -> some View {
        let texts = text.components(separatedBy: search)
        if texts.count == 1 {
            if text.hasPrefix(search) {
                Text(search).foregroundColor(.red) + Text(texts[0])
            } else if text.hasSuffix(search) {
                Text(texts[0]) + Text(search).foregroundColor(.red)
            } else {
                Text(text)
            }
        } else {
            texts.reduce(Text(""), { $0 + Text(search).foregroundColor(.red) + Text($1) })
        }
    }
}

struct SearchContentView_Previews: PreviewProvider {
    static var previews: some View {
        SearchContentView()
    }
}

struct SearchListModel: Identifiable {
    var id = UUID()
    var tid = ""
    var title = ""
    var content = ""
    var time = ""
    var replyViews = ""
    var name = ""
    var plate = ""
}
