//
//  TopicDetailContentView.swift
//  Msea
//
//  Created by tzqiang on 2022/1/6.
//  Copyright © 2022 eternal.just. All rights reserved.
//

import SwiftUI
import Kanna

struct TopicDetailContentView: View {
    var tid: String = "820"

    @State private var title = ""
    @State private var commentCount = ""
    @State private var comments = [TopicCommentModel]()
    @State private var isHidden = false
    @State private var page = 1
    @State private var isRefreshing = false
    @State private var nextPage = false

    var body: some View {
        ZStack {
            List {
                Section {
                    ForEach(comments, id: \.id) { comment in
                        VStack(alignment: .leading) {
                            HStack {
                                AsyncImage(url: URL(string: comment.avatar)) { image in
                                    image.resizable()
                                } placeholder: {
                                    ProgressView()
                                }
                                .frame(width: 40, height: 40)
                                .cornerRadius(5)

                                VStack(alignment: .leading) {
                                    Text(comment.name)
                                        .font(.headline)
                                    Text(comment.time)
                                        .font(.footnote)
                                }
                            }

                            Web(bodyHTMLString: comment.content, didFinish: { scrollHeight in
                                if comment.webViewHeight == .zero, let index = comments.firstIndex(where: { obj in obj.id == comment.id }) {
                                    var model = comment
                                    model.webViewHeight = scrollHeight
                                    model.id = UUID()
                                    if index < comments.count, comments.count != 1 {
                                        comments.replaceSubrange(index..<(index + 1), with: [model])
                                    } else {
                                        comments = [model]
                                    }
                                }
                            })
                                .frame(height: comment.webViewHeight)
                                .onAppear {
                                    if comment.id == comments.last?.id {
                                        if nextPage {
                                            page += 1
                                            Task {
                                                await loadData()
                                            }
                                        }
                                    }
                                }
                        }
                    }
                } header: {
                    TopicDetailHeaderView(title: title, commentCount: commentCount)
                }
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
        }
        .navigationTitle("帖子详情")
    }

    private func loadData() async {
        isRefreshing = true
        Task {
            // swiftlint:disable force_unwrapping
            let url = URL(string: "https://www.chongbuluo.com/forum.php?mod=viewthread&tid=\(tid)&extra=&page=\(page)")!
            // swiftlint:enble force_unwrapping
            var requset = URLRequest(url: url)
            requset.configHeaderFields()
            let (data, _) = try await URLSession.shared.data(for: requset)
            if let html = try? HTML(html: data, encoding: .utf8) {
                if let text = html.at_xpath("//td[@class='plc ptm pbn vwthd']/h1/span", namespaces: nil)?.text {
                    title = text
                }
                if let text1 = html.at_xpath("//td[@class='plc ptm pbn vwthd']/div[@class='ptn']/span[2]", namespaces: nil)?.text, let text2 = html.at_xpath("//td[@class='plc ptm pbn vwthd']/div[@class='ptn']/span[5]", namespaces: nil)?.text {
                    commentCount = "查看: \(text1)  |  回复: \(text2)"
                }
                if let text = html.toHTML, text.contains("下一页") {
                    nextPage = true
                }
                let node = html.xpath("//table[@class='plhin']", namespaces: nil)
                var list = [TopicCommentModel]()
                node.forEach { element in
                    var comment = TopicCommentModel()
                    if let avatar = element.at_xpath("//div[@class='avatar']//img/@src", namespaces: nil)?.text {
                        comment.avatar = avatar
                    }
                    if let name = element.at_xpath("//div[@class='authi']/a", namespaces: nil)?.text {
                        comment.name = name
                    }
                    if let time = element.at_xpath("//div[@class='authi']/em", namespaces: nil)?.text {
                        comment.time = time
                    }
                    if let content = element.at_xpath("//div[@class='t_fsz']/table", namespaces: nil)?.toHTML {
                        comment.content = content
                    }
                    list.append(comment)
                }
                html.getFormhash()

                if page == 1 {
                    comments = list
                    isRefreshing = false
                } else {
                    comments += list
                }
                isHidden = true
            }
        }
    }
}

struct TopicDetailHeaderView: View {
    var title = ""
    var commentCount = ""
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.title3)

            Text(commentCount)
        }
    }
}

struct TopicDetailContentView_Previews: PreviewProvider {
    static var previews: some View {
        TopicDetailContentView()
    }
}

struct TopicCommentModel: Identifiable {
    var id = UUID()
    var uid = ""
    var name = ""
    var avatar = ""
    var lv = ""
    var time = ""
    var content = ""
    var webViewHeight: CGFloat = .zero
}
