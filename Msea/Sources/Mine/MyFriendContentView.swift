//
//  MyFriendContentView.swift
//  Msea
//
//  Created by tzqiang on 2022/5/24.
//  Copyright © 2022 eternal.just. All rights reserved.
//

import SwiftUI
import Kanna

/// 我的好友
struct MyFriendContentView: View {
    @State private var myFriends = [MyFriendListModel]()
    @State private var page = 1
    @State private var isHidden = false
    @State private var count = "0"
    @State private var groups = [FriendGroupModel]()
    @State private var gid = "-1"
    @State private var title = "全部好友"

    @State private var uid = ""
    @State private var isSpace = false

    var body: some View {
        ZStack {
            if myFriends.isEmpty {
                Text("暂无好友")
            } else {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.fixed(175)), GridItem(.fixed(175))],
                              alignment: .center,
                              pinnedViews: [.sectionHeaders]) {
                        Section {
                            ForEach(myFriends) { friend in
                                HStack {
                                    AsyncImage(url: URL(string: friend.avatar)) { image in
                                        image.resizable()
                                    } placeholder: {
                                        ProgressView()
                                    }
                                    .frame(width: 40, height: 40)
                                    .cornerRadius(5)
                                    .onTapGesture(perform: {
                                        if !friend.uid.isEmpty {
                                            uid = friend.uid
                                            isSpace = true
                                        }
                                    })

                                    VStack(alignment: .leading, spacing: 5) {
                                        HStack {
                                            Text(friend.name)
                                                .font(.font13)

                                            Spacer()

                                            Text(friend.hot)
                                                .font(.font12)
                                                .foregroundColor(.secondary)
                                                .onAppear {
                                                    if friend.id == myFriends.last?.id {
                                                        page += 1
                                                        Task {
                                                            await loadData()
                                                        }
                                                    }
                                                }
                                        }
                                        .padding(.top, 0)

                                        Text(friend.topic)
                                            .font(.font12)
                                            .lineLimit(1)
                                    }

                                    Spacer()
                                }
                                .padding([.top, .bottom], 5)
                            }
                        } header: {
                            HStack {
                                Text("按照好友热度排序")

                                Spacer()

                                Text("当前共有 \(Text(count).bold()) 个好友")
                            }
                            .foregroundColor(.secondary)
                            .font(.font15)
                            .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
                            .background(Color.backGround)
                        }
                    }
                }
            }

            ProgressView()
                .isHidden(isHidden)

            NavigationLink(destination: SpaceProfileContentView(uid: uid), isActive: $isSpace) {
                EmptyView()
            }
            .opacity(0.0)
        }
        .navigationBarTitle(title)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    ForEach(groups) { item in
                        Button {
                            Task {
                                gid = item.gid
                                title = item.name
                                page = 1
                                await loadData()
                            }
                        } label: {
                            Text(item.name)
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis")
                }
            }
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
            let url = URL(string: "https://www.chongbuluo.com/home.php?mod=space&do=friend&order=num&group=\(gid)&page=\(page)")!
            // swiftlint:enble force_unwrapping
            var request = URLRequest(url: url)
            request.configHeaderFields()
            let (data, _) = try await URLSession.shared.data(for: request)
            if let html = try? HTML(html: data, encoding: .utf8) {
                if let text = html.at_xpath("//div[@class='tbmu cl']/p/span[@class='xw1']")?.text {
                    count = text
                }
                let group = html.xpath("//ul[@class='buddy_group']/li")
                var list = [FriendGroupModel]()
                group.forEach { element in
                    var model = FriendGroupModel()
                    if let text = element.at_xpath("/a[last()]/@href")?.text, text.contains("group=") {
                        if let id = text.components(separatedBy: "group=").last {
                            model.gid = id
                        }
                    }
                    if let text = element.at_xpath("/a[last()]")?.text {
                        model.name = text
                    }
                    list.append(model)
                }
                groups = list

                let lis = html.xpath("//ul[@class='buddy cl']/li")
                var friends = [MyFriendListModel]()
                lis.forEach { element in
                    var friend = MyFriendListModel()
                    if let avatar = element.at_xpath("/div[@class='avt']/a/img/@src")?.text {
                        friend.avatar = avatar.replacingOccurrences(of: "&size=small", with: "")
                    }
                    if let name = element.text {
                        friend.name = name
                    }
                    if let text = element.at_xpath("/h4/span[@class='xg1 xw0 y']")?.text {
                        friend.hot = text.replacingOccurrences(of: "\n", with: "")
                    }
                    if let href = element.at_xpath("/h4/a/@href")?.text {
                        friend.uid = href.getUid()
                    }
                    if let text = element.at_xpath("/h4/a")?.text {
                        friend.name = text
                    }
                    if let text = element.at_xpath("/p[@class='maxh']")?.text {
                        friend.topic = text
                    }

                    friends.append(friend)
                }
                if page == 1 {
                    myFriends = friends
                } else {
                    myFriends += friends
                }
            }

            isHidden = true
        }
    }
}

struct MyFriendContentView_Previews: PreviewProvider {
    static var previews: some View {
        MyFriendContentView()
    }
}

struct MyFriendListModel: Identifiable {
    var id = UUID()
    var name = ""
    var uid = ""
    var avatar = ""
    var hot = ""
    var topic = ""
    var integral = ""
}
