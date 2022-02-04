//
//  FavoriteContentView.swift
//  Msea
//
//  Created by Awro on 2022/2/4.
//  Copyright © 2022 eternal.just. All rights reserved.
//

import SwiftUI
import Kanna

/// 收藏
struct FavoriteContentView: View {
    @State private var page = 1
    @State private var postList = [FavoritePostModel]()
    @State private var isHidden = false

    var body: some View {
        ZStack {
            if postList.isEmpty {
                Text("暂时没有收藏内容")
            } else {
                List(postList) { post in
                    ZStack(alignment: .leading) {
                        Text("\(Text(post.title))  \(Text(post.time).foregroundColor(.secondary))")

                        NavigationLink(destination: TopicDetailContentView(tid: post.tid)) {
                            EmptyView()
                        }
                        .opacity(0.0)
                    }
                    .onAppear {
                        if post.id == postList.last?.id {
                            page += 1
                            Task {
                                await loadData()
                            }
                        }
                    }
                }
                .listStyle(.plain)
                .refreshable {
                    page = 1
                    await loadData()
                }
                .navigationTitle("收藏")
            }

            ProgressView()
                .isHidden(isHidden)
        }
        .task {
            if !isHidden {
                await loadData()
            }
        }
    }

    private func loadData() async {
        Task {
            // swiftlint:disable force_unwrapping
            let url = URL(string: "https://www.chongbuluo.com/home.php?mod=space&do=favorite&type=thread&page=\(page)")!
            // swiftlint:enble force_unwrapping
            var request = URLRequest(url: url)
            request.configHeaderFields()
            request.addValue(UserAgentType.mac.description, forHTTPHeaderField: HTTPHeaderField.userAgent.description)
            let (data, _) = try await URLSession.shared.data(for: request)
            if let html = try? HTML(html: data, encoding: .utf8) {
                let li = html.xpath("//ul[@id='favorite_ul']/li", namespaces: nil)
                var list = [FavoritePostModel]()
                li.forEach({ element in
                    var post = FavoritePostModel()
                    if let time = element.at_xpath("//span[@class='xg1']", namespaces: nil)?.text {
                        post.time = time
                    }
                    if let tid = element.at_xpath("/a[2]/@href", namespaces: nil)?.text,
                       tid.contains("tid=") {
                        post.tid = tid.components(separatedBy: "tid=")[1]
                    }
                    if let title = element.at_xpath("/a[2]", namespaces: nil)?.text {
                        post.title = title
                    }
                    if let action = element.at_xpath("/a[1]/@href", namespaces: nil)?.text {
                        post.action = action
                    }

                    list.append(post)
                })

                if page == 1 {
                    postList = list
                } else {
                    postList += list
                }
            }

            isHidden = true
        }
    }
}

struct FavoriteContentView_Previews: PreviewProvider {
    static var previews: some View {
        FavoriteContentView()
    }
}

struct FavoritePostModel: Identifiable {
    var id = UUID()
    var tid = ""
    var time = ""
    var title = ""
    var action = ""
}
