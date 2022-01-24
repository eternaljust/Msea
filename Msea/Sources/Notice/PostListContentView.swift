//
//  PostListContentView.swift
//  Msea
//
//  Created by tzqiang on 2022/1/12.
//  Copyright © 2022 eternal.just. All rights reserved.
//

import SwiftUI
import Kanna

struct PostListContentView: View {
    var type = MyPostTab.post

    @State private var page = 1
    @State private var postList = [PostListModel]()
    @State private var isHidden = false

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

                        VStack(alignment: .leading) {
                            Text(post.time)
                                .font(.footnote)

                            ZStack(alignment: .leading) {
                                Text("\(Text(post.name).foregroundColor(.secondaryTheme)) \(type.body) \(Text(post.title).foregroundColor(.secondaryTheme))")
                                    .font(.footnote)

                                NavigationLink(destination: TopicDetailContentView(tid: post.ptid)) {
                                    EmptyView()
                                }
                                .opacity(0.0)
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
                }
                .listStyle(.plain)
                .refreshable {
                    page = 1
                    await loadData()
                }
                .navigationTitle("系统提醒")
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
            let url = URL(string: "https://www.chongbuluo.com/home.php?mod=space&do=notice&view=mypost&type=\(type.rawValue)&page=\(page)")!
            // swiftlint:enble force_unwrapping
            var request = URLRequest(url: url)
            request.configHeaderFields()
            request.addValue(UserAgentType.mac.description, forHTTPHeaderField: HTTPHeaderField.userAgent.description)
            let (data, _) = try await URLSession.shared.data(for: request)
            if let html = try? HTML(html: data, encoding: .utf8) {
                let dl = html.xpath("//dl[@class='cl ']", namespaces: nil)
                var list = [PostListModel]()
                dl.forEach({ element in
                    var post = PostListModel()
                    if let time = element.at_xpath("//span[@class='xg1 xw0']", namespaces: nil)?.text {
                        post.time = time
                    }
                    if let avatar = element.at_xpath("//dd[@class='m avt mbn']/a/img/@src", namespaces: nil)?.text {
                        post.avatar = avatar.replacingOccurrences(of: "&size=small", with: "")
                    }
                    if let name = element.at_xpath("//dd[@class='ntc_body']/a[1]", namespaces: nil)?.text {
                        post.name = name
                    }
                    if let title = element.at_xpath("//dd[@class='ntc_body']/a[2]", namespaces: nil)?.text {
                        post.title = title
                    }
                    if let href = element.at_xpath("//dd[@class='ntc_body']/a[2]/@href", namespaces: nil)?.text {
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

struct PostListModel: Identifiable {
    var id = UUID()
    var uid = ""
    var ptid = ""
    var pid = ""
    var avatar = ""
    var name = ""
    var time = ""
    var title = ""
}
