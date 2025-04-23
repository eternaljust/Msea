//
//  MyVisitorTraceContentView.swift
//  Msea
//
//  Created by tzqiang on 2022/5/27.
//  Copyright © 2022 eternal.just. All rights reserved.
//

import SwiftUI
import Kanna

/// 我的访客和我的足迹
struct MyVisitorTraceContentView: View {
    var type = MyFriendVisitorTraceTab.visitor

    @State private var myFriends = [MyVisitorTraceModel]()
    @State private var page = 1
    @State private var isHidden = false

    @State private var uid = ""
    @State private var isSpace = false

    var body: some View {
        ZStack {
            if myFriends.isEmpty {
                Text("暂无记录")
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

                                            Text(friend.time)
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
                                Text(type.header)

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
        }
        .navigationBarTitle(type.title)
        .navigationDestination(isPresented: $isSpace, destination: {
            SpaceProfileContentView(uid: uid)
        })
//        .onAppear {
//            if !UIDevice.current.isPad {
//                TabBarTool.showTabBar(false)
//            }
//        }
        .task {
            if !isHidden {
                await loadData()
            }
        }
    }

    private func loadData() async {
        Task {
            // swiftlint:disable force_unwrapping
            let url = URL(string: "https://www.chongbuluo.com/home.php?mod=space&uid=\(UserInfo.shared.uid)&do=friend&view=\(type.id)&page=\(page)")!
            // swiftlint:enble force_unwrapping
            var request = URLRequest(url: url)
            request.configHeaderFields()
            let (data, _) = try await URLSession.shared.data(for: request)
            if let html = try? HTML(html: data, encoding: .utf8) {
                let lis = html.xpath("//ul[@class='buddy cl']/li")
                var friends = [MyVisitorTraceModel]()
                lis.forEach { element in
                    var friend = MyVisitorTraceModel()
                    if let avatar = element.at_xpath("/div[@class='avt']/a/img/@src")?.text {
                        friend.avatar = avatar.replacingOccurrences(of: "&size=small", with: "")
                    }
                    if let name = element.text {
                        friend.name = name
                    }
                    if let text = element.at_xpath("/h4/span[@class='xg1 xw0 y']")?.text {
                        friend.time = text.replacingOccurrences(of: "\n", with: "")
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

struct MyVisitorTraceContentView_Previews: PreviewProvider {
    static var previews: some View {
        MyVisitorTraceContentView()
    }
}
