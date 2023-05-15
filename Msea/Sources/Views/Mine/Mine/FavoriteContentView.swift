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
    @State private var deleteAction = ""
    @EnvironmentObject private var hud: HUDState

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
                    .contextMenu {
                        Button {
                            if !post.action.isEmpty {
                                deleteAction = post.action
                                Task {
                                    await deleteFavorite()
                                }
                            }
                        } label: {
                            HStack {
                                Text("删除")
                                Image(systemName: "trash")
                            }
                        }
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
            }

            ProgressView()
                .isHidden(isHidden)
        }
        .navigationTitle("收藏")
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
            let (data, _) = try await URLSession.shared.data(for: request)
            if let html = try? HTML(html: data, encoding: .utf8) {
                let li = html.xpath("//ul[@id='favorite_ul']/li")
                var list = [FavoritePostModel]()
                li.forEach({ element in
                    var post = FavoritePostModel()
                    if let time = element.at_xpath("//span[@class='xg1']")?.text {
                        post.time = time
                    }
                    if let tid = element.at_xpath("/a[2]/@href")?.text {
                        post.tid = tid.getTid()
                    }
                    if let title = element.at_xpath("/a[2]")?.text {
                        post.title = title
                    }
                    if let action = element.at_xpath("/a[1]/@href")?.text,
                       var id = element.at_xpath("/a[1]/@id")?.text {
                        id = id.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                        post.action = "https://www.chongbuluo.com/\(action)&formhash=\(UserInfo.shared.formhash)&deletesubmit=true&handlekey=\(id)"
                        print(post.action)
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

    private func deleteFavorite() async {
        Task {
            // swiftlint:disable force_unwrapping
            let url = URL(string: deleteAction)!
            // swiftlint:enble force_unwrapping
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.configHeaderFields()
            let (data, _) = try await URLSession.shared.data(for: request)
            if let html = try? HTML(html: data, encoding: .utf8) {
                if let text = html.toXML, text.contains("全部收藏") {
                    hud.show(message: "操作成功")
                    deleteAction = ""
                    page = 1
                    await loadData()
                } else {
                    hud.show(message: "操作失败，请稍后重试")
                }
            } else {
                hud.show(message: "操作失败，请稍后重试")
            }
        }
    }
}

struct FavoriteContentView_Previews: PreviewProvider {
    static var previews: some View {
        FavoriteContentView()
    }
}
