//
//  TopicListContentView.swift
//  Msea
//
//  Created by Awro on 2021/12/4.
//  Copyright © 2021 eternal.just. All rights reserved.
//

import SwiftUI
import Kanna

struct TopicListContentView: View {
    var view = ViewTab.new

    @State private var topics = [TopicListModel]()
    @State private var isHidden = false
    @State private var page = 1

    var body: some View {
        ZStack {
            List(topics) { topic in
                VStack(alignment: .leading) {
                    HStack {
                        AsyncImage(url: URL(string: "https://www.chongbuluo.com/\(topic.avatar)")) { image in
                            image.resizable()
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 40, height: 40)
                        .cornerRadius(5)
                        VStack(alignment: .leading) {
                            Text(topic.name)
                                .font(.headline)
                            Text(topic.time)
                                .font(.footnote)
                        }
                        Spacer()
                        Text("\(topic.reply)/\(topic.examine)")
                    }
                    Text(topic.title)
                        .fixedSize(horizontal: false, vertical: true)
                        .onAppear {
                            if topic.id == topics.last?.id {
                                print("scroll bottom")
                                self.page += 1
                                Task {
                                    await loadData()
                                }
                            }
                        }
                }
            }
            .listStyle(.plain)
            .refreshable {
                await loadData()
            }
            .task {
                await loadData()
            }

            ProgressView()
                .isHidden(isHidden)
        }
    }

    func loadData() async {
        Task {
            // swiftlint:disable force_unwrapping
            let url = URL(string: "https://www.chongbuluo.com/forum.php?mod=guide&view=\(view.id)&page=\(page)")!
            // swiftlint:enble force_unwrapping
            let (data, _) = try await URLSession.shared.data(from: url)
            if let html = try? HTML(html: data, encoding: .utf8) {
                let node = html.xpath("//tbody", namespaces: nil)
                print(node.count)
                var list = [TopicListModel]()
                node.forEach { element in
                    print("\n")
                    var topic = TopicListModel()
                    if let avatar = element.at_xpath("//img//@src", namespaces: nil)?.text {
                        topic.avatar = avatar
                        print("avatar: \(avatar)")
                    }

                    if let name = element.at_xpath("//cite/a", namespaces: nil)?.text {
                        topic.name = name
                        print("name: \(name)")
                    }
                    if let title = element.at_xpath("//th/a[@class='xst']", namespaces: nil)?.text {
                        topic.title = title
                        print("title: \(title)")
                    }
                    if let time = element.at_xpath("//td[@class='by']//span//@title", namespaces: nil)?.text {
                        topic.time = time
                        print("time: \(time)")
                    }
                    if let xi2 = element.at_xpath("//td/a[@class='xi2']", namespaces: nil)?.text, let reply = Int(xi2) {
                        topic.reply = reply
                        print("reply: \(reply)")
                    }
                    if let em = element.at_xpath("//td[@class='num']/em", namespaces: nil)?.text, let examine = Int(em) {
                        topic.examine = examine
                        print("examine: \(examine)")
                    }
                    if let uid = element.at_xpath("//cite/a//@href", namespaces: nil)?.text {
                        topic.uid = uid
                        print("uid: \(uid)")
                    }
                    if let id = element.at_xpath("//@id", namespaces: nil)?.text, let tid = id.components(separatedBy: "_").last {
                        topic.tid = tid
                        print("tid: \(tid)")
                    }
                    list.append(topic)
                }

                if page == 1 {
                    topics = list
                } else {
                    topics += list
                }
                isHidden = true
            }
        }
    }
}

struct TopicListContentView_Previews: PreviewProvider {
    static var previews: some View {
        TopicListContentView()
    }
}

struct TopicListModel: Identifiable {
    var id = UUID()
    var uid = ""
    var tid = ""
    var name = ""
    var avatar = ""
    var title = ""
    var time = ""
    var examine = 0
    var reply = 0
}
