//
//  MessageBoardContentView.swift
//  Msea
//
//  Created by tzqiang on 2021/12/30.
//  Copyright © 2021 eternal.just. All rights reserved.
//

import SwiftUI
import Kanna

/// 留言板
struct MessageBoardContentView: View {
    var uid = CacheInfo.shared.defaultUid
    @State private var messages = [MessageBoardListModel]()
    @State private var isHidden = false
    @State private var page = 1
    @State private var isRefreshing = false
    @State private var clickUid = ""
    @State private var isSpace = false

    var body: some View {
        ZStack {
            if messages.isEmpty {
                Text("现在还没有留言")
            } else {
                List(messages) { message in
                    VStack(alignment: .leading) {
                        HStack {
                            AsyncImage(url: URL(string: message.avatar)) { image in
                                image.resizable()
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(width: 40, height: 40)
                            .cornerRadius(5)
                            .onTapGesture {
                                if !message.uid.isEmpty {
                                    clickUid = message.uid
                                    isSpace.toggle()
                                }
                            }

                            VStack(alignment: .leading) {
                                Text(message.name)
                                    .font(.font17Blod)

                                Text(message.time)
                                    .font(.font13)
                            }
                            .onAppear {
                                if message.id == messages.last?.id {
                                    page += 1
                                    Task {
                                        await loadData()
                                    }
                                }
                            }
                        }

                        if !message.replyName.isEmpty && !message.quote.isEmpty {
                            Text("   \(Text(message.replyName)): \(Text(message.quote).foregroundColor(.secondary))")
                                .font(.font16)
                        }

                        if message.gifURL.isEmpty {
                            Text(message.comment)
                                .font(.font16)
                                .fixedSize(horizontal: false, vertical: true)
                        } else {
                            HStack {
                                if !message.gifLeft {
                                    Text(message.comment)
                                        .font(.font16)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                if let url = URL(string: message.gifURL) {
                                    GifImage(url: url)
                                        .frame(width: 20, height: 20)
                                }
                                if message.gifLeft {
                                    Text(message.comment)
                                        .font(.font16)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                        }
                    }
                    .padding([.top, .bottom], 5)
                }
                .listStyle(.plain)
                .refreshable {
                    page = 1
                    await loadData()
                }

                NavigationLink(destination: SpaceProfileContentView(uid: clickUid), isActive: $isSpace) {
                    EmptyView()
                }
                .opacity(0.0)
            }

            ProgressView()
                .isHidden(isHidden)
        }
        .navigationBarTitle("留言板")
        .task {
            if !isHidden {
                await loadData()
            }
        }
    }

    private func loadData() async {
        isRefreshing = true
        Task {
            // swiftlint:disable force_unwrapping
            let url = URL(string: "https://www.chongbuluo.com/home.php?mod=space&uid=\(uid)&do=wall&page=\(page)")!
            // swiftlint:enble force_unwrapping
            var requset = URLRequest(url: url)
            requset.configHeaderFields()
            let (data, _) = try await URLSession.shared.data(for: requset)
            if let html = try? HTML(html: data, encoding: .utf8) {
                let node = html.xpath("//dl[@class='bbda cl']", namespaces: nil)
                var list = [MessageBoardListModel]()
                node.forEach { element in
                    var message = MessageBoardListModel()
                    if let avatar = element.at_xpath("/dd[@class='m avt']//img//@src", namespaces: nil)?.text {
                        message.avatar = avatar.replacingOccurrences(of: "&size=small", with: "")
                    }
                    if let name = element.at_xpath("/dt/a", namespaces: nil)?.text {
                        message.name = name
                    }
                    if let href = element.at_xpath("/dt/a/@href", namespaces: nil)?.text {
                        let uids = href.components(separatedBy: "=")
                        if let uid = uids.last {
                            message.uid = uid
                        }
                    }
                    if let time = element.at_xpath("/dt/span[@class='xg1 xw0']", namespaces: nil)?.text {
                        message.time = time
                    }
                    if let comment = element.at_xpath("/dd[2]", namespaces: nil)?.text {
                        if let quote = element.at_xpath("/dd[2]//blockquote", namespaces: nil)?.text {
                            message.comment = comment.replacingOccurrences(of: quote, with: "")
                            let texts = quote.components(separatedBy: ": ")
                            if texts.count == 2 {
                                message.replyName = texts[0]
                                message.quote = texts[1]
                            }
                        } else {
                            message.comment = comment
                        }
                        if let src = element.at_xpath("/dd[2]/img/@src", namespaces: nil)?.text {
                            message.gifURL = "https://www.chongbuluo.com/" + src
                            if let dd2 = element.at_xpath("/dd[2]", namespaces: nil)?.toHTML {
                                if !message.comment.isEmpty {
                                    if let range1 = dd2.range(of: message.comment), let range2 = dd2.range(of: "<img") {
                                        message.gifLeft = range2.lowerBound < range1.lowerBound
                                    }
                                }
                            }
                        }
                    }
                    list.append(message)
                }
                html.getFormhash()

                if page == 1 {
                    messages = list
                    isRefreshing = false
                } else {
                    messages += list
                }
                isHidden = true
            }
        }
    }
}

struct MessageBoardContentView_Previews: PreviewProvider {
    static var previews: some View {
        MessageBoardContentView()
    }
}

struct MessageBoardListModel: Identifiable {
    var id = UUID()
    var uid = ""
    var name = ""
    var avatar = ""
    var comment = ""
    var replyName = ""
    var quote = ""
    var time = ""
    var gifURL = ""
    var gifLeft = true
    var quoteGifURL = ""
    var quoteGifLeft = true
}
