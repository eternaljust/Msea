//
//  PostListContentView.swift
//  Msea
//
//  Created by tzqiang on 2022/1/12.
//  Copyright © 2022 eternal.just. All rights reserved.
//

import SwiftUI
import Kanna

/// 我的帖子列表
struct PostListContentView: View {
    var type = MyPostTab.post

    @State private var page = 1
    @State private var postList = [PostListModel]()
    @State private var isHidden = false

    @State private var uid = ""
    @State private var isSpace = false
    @State private var tid = ""
    @State private var isTopic = false

    var body: some View {
        ZStack {
            if postList.isEmpty {
                Text("暂时没有提醒内容")
            } else {
                List(postList) { post in
                    HStack {
                        AsyncImage(url: URL(string: post.avatar)) { image in
                            image.resizable()
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 40, height: 40)
                        .cornerRadius(5)
                        .onTapGesture(perform: {
                            if !post.uid.isEmpty {
                                uid = post.uid
                                isSpace = true
                            }
                        })

                        VStack(alignment: .leading, spacing: 5) {
                            Text(post.time)
                                .font(.font13)

                            Text("\(Text(post.name).foregroundColor(.secondaryTheme)) \(type.body) \(Text(post.title).foregroundColor(.secondaryTheme))")
                                .font(.font16)
                                .fixedSize(horizontal: false, vertical: true)
                                .onTapGesture(perform: {
                                    if !post.ptid.isEmpty {
                                        tid = post.ptid
                                        isTopic = true
                                    }
                                })
                        }
                        .padding([.top, .bottom], 5)
                        .onAppear {
                            if post.id == postList.last?.id {
                                page += 1
                                Task {
                                    await loadData()
                                }
                            }
                        }
                    }
                }
                .listStyle(.plain)
                .refreshable {
                    page = 1
                    await loadData()
                }
                .navigationTitle("我的帖子")
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
        .task {
            if !isHidden {
                page = 1
                await loadData()
            }
        }
        .onAppear {
            shieldUsers()
        }
        .onReceive(NotificationCenter.default.publisher(for: .shieldUser, object: nil)) { _ in
            shieldUsers()
        }
    }

    private func shieldUsers() {
        postList = postList.filter { model in
            !UserInfo.shared.shieldUsers.contains { $0.uid == model.uid }
        }
    }

    private func loadData() async {
        Task {
            // swiftlint:disable force_unwrapping
            let url = URL(string: "https://www.chongbuluo.com/home.php?mod=space&do=notice&view=mypost&type=\(type.rawValue)&page=\(page)")!
            // swiftlint:enble force_unwrapping
            var request = URLRequest(url: url)
            request.configHeaderFields()
            let (data, _) = try await URLSession.shared.data(for: request)
            if let html = try? HTML(html: data, encoding: .utf8) {
                let dl = html.xpath("//dl[@class='cl ']")
                var list = [PostListModel]()
                dl.forEach({ element in
                    var post = PostListModel()
                    if let time = element.at_xpath("//span[@class='xg1 xw0']")?.text {
                        post.time = time
                    }
                    if let avatar = element.at_xpath("//dd[@class='m avt mbn']/a/img/@src")?.text {
                        post.avatar = avatar.replacingOccurrences(of: "&size=small", with: "")
                    }
                    if let name = element.at_xpath("//dd[@class='ntc_body']/a[1]")?.text {
                        post.name = name
                    }
                    if let uid = element.at_xpath("//dd[@class='ntc_body']/a[1]/@href")?.text,
                       uid.contains("uid") {
                        post.uid = uid.getUid()
                    }
                    if let title = element.at_xpath("//dd[@class='ntc_body']/a[2]")?.text {
                        post.title = title
                    }
                    if let href = element.at_xpath("//dd[@class='ntc_body']/a[2]/@href")?.text {
                        let ids = href.components(separatedBy: "&")
                        if ids.count > 2 {
                            let ptid = ids[2].components(separatedBy: "=")
                            if ptid.count == 2 {
                                post.ptid = ptid[1]
                            }
                            let pid = ids[3].components(separatedBy: "=")
                            if pid.count == 2 {
                                post.pid = pid[1]
                            }
                        }
                    }
                    list.append(post)
                })

                if page == 1 {
                    postList = list
                } else {
                    postList += list
                }

                shieldUsers()
            }

            isHidden = true
        }
    }
}

struct PostListContentView_Previews: PreviewProvider {
    static var previews: some View {
        PostListContentView()
    }
}
