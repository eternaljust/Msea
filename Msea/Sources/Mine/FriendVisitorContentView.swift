//
//  FriendVisitorContentView.swift
//  Msea
//
//  Created by tzqiang on 2021/12/30.
//  Copyright © 2021 eternal.just. All rights reserved.
//

import SwiftUI
import Kanna

/// 好友与访客
struct FriendVisitorContentView: View {
    var uid = ""

    @State private var friendVisitors = [FriendVisitorListModel(type: .friend, persons: [FriendVisitorModel]()),
                                         FriendVisitorListModel(type: .visitor, persons: [FriendVisitorModel]())]
    @State private var isHidden = false

    let columns = [
        GridItem(.adaptive(minimum: 80, maximum: 120), spacing: 2)
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, alignment: .leading, spacing: 10, pinnedViews: [.sectionHeaders]) {
                ForEach(friendVisitors) { section in
                    Section {
                        if section.persons.isEmpty {
                            Text("暂无")
                                .font(.font15)
                        } else {
                            ForEach(section.persons, id: \.id) { persion in
                                NavigationLink(destination: SpaceProfileContentView(uid: persion.uid)) {
                                    VStack {
                                        AsyncImage(url: URL(string: persion.avatar)) { image in
                                            image.resizable()
                                        } placeholder: {
                                            ProgressView()
                                        }
                                        .frame(width: 45, height: 45)
                                        .cornerRadius(5)

                                        Text(persion.name)
                                            .font(.font12)
                                            .foregroundColor(.theme)
                                            .lineLimit(2)
                                            .multilineTextAlignment(.center)

                                        if !persion.time.isEmpty {
                                            Text(persion.time)
                                                .font(.font12)
                                                .foregroundColor(.secondary)
                                                .lineLimit(2)
                                                .multilineTextAlignment(.center)
                                        }
                                    }
                                }
                            }
                        }
                    } header: {
                        FriendVisitorHeaderView(title: section.type.title)
                    }
                }
            }
            .refreshable {
                await loadData()
            }
            .task {
                if friendVisitors[0].persons.isEmpty && friendVisitors[1].persons.isEmpty {
                    await loadData()
                }
            }
        }
        .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
        .navigationBarTitle("好友访客")
    }

    private func loadData() async {
        Task {
            // swiftlint:disable force_unwrapping
            let url = URL(string: "https://www.chongbuluo.com/home.php?mod=space&uid=\(uid)")!
            // swiftlint:enble force_unwrapping
            let (data, _) = try await URLSession.shared.data(from: url)
            if let html = try? HTML(html: data, encoding: .utf8) {
                friendVisitors = [FriendVisitorListModel(type: .friend, persons: [FriendVisitorModel]()),
                                  FriendVisitorListModel(type: .visitor, persons: [FriendVisitorModel]())]
                let friend_content = html.xpath("//div[@id='friend_content']/ul/li")
                var friends = [FriendVisitorModel]()
                friend_content.forEach { element in
                    var friend = FriendVisitorModel()
                    if let name = element.text {
                        friend.name = name
                    }
                    let img = element.at_xpath("/a/img/@src")
                    if let avatar = img?.text {
                        friend.avatar = avatar.replacingOccurrences(of: "&size=small", with: "")
                    }
                    if let href = element.at_xpath("/a/@href")?.text {
                        let uids = href.components(separatedBy: "-")
                        if let uid = uids.last {
                            friend.uid = uid.replacingOccurrences(of: ".html", with: "")
                        }
                    }
                    friends.append(friend)
                }
                friendVisitors[0].persons = friends

                //
                let visitor_content = html.xpath("//div[@id='visitor_content']/ul/li")
                var visitors = [FriendVisitorModel]()
                visitor_content.forEach { element in
                    var visitor = FriendVisitorModel()
                    let a = element.at_xpath("/p/a")
                    if let name = a?.text {
                        visitor.name = name
                    }
                    let span = element.at_xpath("span")
                    if let time = span?.text {
                        visitor.time = time
                    }
                    let img = element.at_xpath("/a/img/@src")
                    if let avatar = img?.text {
                        visitor.avatar = avatar.replacingOccurrences(of: "&size=small", with: "")
                    }
                    if let href = element.at_xpath("/a/@href")?.text {
                        let uids = href.components(separatedBy: "-")
                        if let uid = uids.last {
                            visitor.uid = uid.replacingOccurrences(of: ".html", with: "")
                        }
                    }
                    visitors.append(visitor)
                }
                friendVisitors[1].persons = visitors
            }
        }
    }
}

struct FriendVisitorHeaderView: View {
    @State var title: String

    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
                .font(.font15)
                .padding(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))

            Spacer()
        }
        .background(Color.backGround)
    }
}

struct FriendVisitorContentView_Previews: PreviewProvider {
    static var previews: some View {
        FriendVisitorContentView()
    }
}

struct FriendVisitorListModel: Identifiable {
    var id = UUID()
    var type: FriendVisitor
    var persons: [FriendVisitorModel]
}

struct FriendVisitorModel: Identifiable {
    var id = UUID()
    var name = ""
    var uid = ""
    var avatar = ""
    var time = ""
}

enum FriendVisitor: String, CaseIterable, Identifiable {
    case friend
    case visitor

    var id: String { self.rawValue }
    var title: String {
        switch self {
        case .friend: return "好友"
        case .visitor: return "访客"
        }
    }
}
