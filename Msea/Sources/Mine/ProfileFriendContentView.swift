//
//  ProfileFriendContentView.swift
//  Msea
//
//  Created by tzqiang on 2022/8/4.
//  Copyright © 2022 eternal.just. All rights reserved.
//

import SwiftUI
import Kanna

/// 个人空间好友列表
struct ProfileFriendContentView: View {
    var uid = ""

    @State private var page = 1
    @State private var isHidden = false
    @State private var count = "0"
    @State private var friends = [MyFriendListModel]()

    @State private var theUid = ""
    @State private var isSpace = false

    var body: some View {
        ZStack {
            if friends.isEmpty {
                Text("暂无好友")
            } else {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.fixed(175)), GridItem(.fixed(175))],
                              alignment: .center,
                              pinnedViews: [.sectionHeaders]) {
                        Section {
                            ForEach(friends) { friend in
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
                                            theUid = friend.uid
                                            isSpace = true
                                        }
                                    })

                                    VStack(alignment: .leading, spacing: 5) {
                                        Text(friend.name)
                                            .font(.font13)
                                            .onAppear {
                                                if friend.id == friends.last?.id {
                                                    page += 1
                                                    Task {
                                                        await loadData()
                                                    }
                                                }
                                            }

                                        Text(friend.integral)
                                            .font(.font12)
                                            .lineLimit(2)
                                    }

                                    Spacer()
                                }
                                .padding([.top, .bottom], 5)
                            }
                        } header: {
                            HStack {
                                Text("当前共有 \(Text(count).bold()) 个好友")

                                Spacer()
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

            NavigationLink(destination: SpaceProfileContentView(uid: theUid), isActive: $isSpace) {
                EmptyView()
            }
            .opacity(0.0)
        }
        .navigationBarTitle("好友列表")
        .task {
            if !isHidden {
                await loadData()
            }
        }
    }

    private func loadData() async {
        Task {
            // swiftlint:disable force_unwrapping
            let url = URL(string: "https://www.chongbuluo.com/home.php?mod=space&uid=\(uid)&do=friend&view=me&from=space&page=\(page)")!
            // swiftlint:enble force_unwrapping
            var request = URLRequest(url: url)
            request.configHeaderFields()
            let (data, _) = try await URLSession.shared.data(for: request)
            if let html = try? HTML(html: data, encoding: .utf8) {
                if let text = html.at_xpath("//div[@class='bm_c']/p/span[@class='xw1']")?.text {
                    count = text
                }

                let lis = html.xpath("//ul[@class='buddy cl']/li")
                var friends = [MyFriendListModel]()
                lis.forEach { element in
                    var friend = MyFriendListModel()
                    if let avatar = element.at_xpath("/div[@class='avt']/a/img/@src")?.text {
                        friend.avatar = avatar.replacingOccurrences(of: "&size=small", with: "")
                    }
                    if let href = element.at_xpath("/h4/a/@href")?.text {
                        let uids = href.components(separatedBy: "uid=")
                        if let uid = uids.last {
                            friend.uid = uid
                        }
                    }
                    if let text = element.at_xpath("/h4/a")?.text {
                        friend.name = text
                    }
                    if let text = element.at_xpath("/p[@class='maxh']")?.text {
                        friend.integral = text.replacingOccurrences(of: "\r\n", with: "")
                    }

                    friends.append(friend)
                }
                if page == 1 {
                    self.friends = friends
                } else {
                    self.friends += friends
                }
            }

            isHidden = true
        }
    }
}

struct ProfileFriendContentView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileFriendContentView()
    }
}
