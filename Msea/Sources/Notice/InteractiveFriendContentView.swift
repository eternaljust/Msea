//
//  InteractiveFriendContentView.swift
//  Msea
//
//  Created by tzqiang on 2022/5/19.
//  Copyright © 2022 eternal.just. All rights reserved.
//

import SwiftUI
import Kanna

/// 坛友互动：好友
struct InteractiveFriendContentView: View {
    private let type = InteractiveTab.friend

    @State private var page = 1
    @State private var friendList = [InteractiveFriendListModel]()
    @State private var isHidden = false
    @State private var isConfirming = false
    @State private var groupList = [FriendGroupModel]()
    @State private var selectedFriend = InteractiveFriendListModel()
    @EnvironmentObject private var hud: HUDState

    @State private var uid = ""
    @State private var isSpace = false

    var body: some View {
        ZStack {
            if friendList.isEmpty {
                Text("暂时没有提醒内容")
            } else {
                List(friendList) { friend in
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
                            Text(friend.time)
                                .font(.font13)

                            Text(getContent(friend: friend))
                                .confirmationDialog("", isPresented: $isConfirming) {
                                    ForEach(groupList) { group in
                                        Button {
                                            print(group.gid)
                                            Task {
                                                await action("\(selectedFriend.actionURL)&group=\(group.gid)&add2submit=true")
                                            }
                                        } label: {
                                            Text(group.name)
                                        }
                                    }
                                } message: {
                                    Text("批准 \(selectedFriend.name) 的好友请求，并分组：")
                                }
                        }
                        .padding([.top, .bottom], 5)
                        .onAppear {
                            if friend.id == friendList.last?.id {
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
                .navigationTitle("坛友互动")
            }

            ProgressView()
                .isHidden(isHidden)

            NavigationLink(destination: SpaceProfileContentView(uid: uid), isActive: $isSpace) {
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
        .onOpenURL { url in
            print(url.absoluteString)
            if let friend = friendList.first(where: { $0.actionURL == url.absoluteString }) {
                selectedFriend = friend
            }

            Task {
                await action(url.absoluteString)
            }
        }
    }

    private func loadData() async {
        Task {
            // swiftlint:disable force_unwrapping
            let url = URL(string: "https://www.chongbuluo.com/home.php?mod=space&do=notice&view=interactive&type=\(type.rawValue)&page=\(page)")!
            // swiftlint:enble force_unwrapping
            var request = URLRequest(url: url)
            request.configHeaderFields()
            let (data, _) = try await URLSession.shared.data(for: request)
            if let html = try? HTML(html: data, encoding: .utf8) {
                let dl = html.xpath("//dl[@class='cl ']")
                var list = [InteractiveFriendListModel]()
                dl.forEach({ element in
                    var friend = InteractiveFriendListModel()
                    if let time = element.at_xpath("//span[@class='xg1 xw0']")?.text {
                        friend.time = time
                    }
                    if let avatar = element.at_xpath("//dd[@class='m avt mbn']/a/img/@src")?.text {
                        friend.avatar = avatar.replacingOccurrences(of: "&size=small", with: "")
                    }
                    if let name = element.at_xpath("//dd[@class='ntc_body']/a[1]")?.text {
                        friend.name = name
                    }
                    if let uid = element.at_xpath("//dd[@class='ntc_body']/a[1]/@href")?.text,
                       uid.contains("uid") {
                        friend.uid = uid.getUid()
                    }
                    if let text = element.at_xpath("//dd[@class='ntc_body']/a[2]")?.text {
                        friend.action = text
                    }
                    if let text = element.at_xpath("//dd[@class='ntc_body']/a[2]/@href")?.text {
                        friend.actionURL = "msea://" + text
                    }
                    if let content = element.at_xpath("//dd[@class='ntc_body']")?.text {
                        friend.content = content.replacingOccurrences(of: friend.name, with: "")
                        friend.content = friend.content.replacingOccurrences(of: friend.action, with: "")
                        friend.content = friend.content.replacingOccurrences(of: "\r\n", with: "")
                    }
                    list.append(friend)
                })

                if page == 1 {
                    friendList = list
                } else {
                    friendList += list
                }
            }

            isHidden = true
        }
    }

    private func action(_ url: String) async {
        isHidden = false
        Task {
            // swiftlint:disable force_unwrapping
            let url = URL(string: "https://www.chongbuluo.com/\(url.replacingOccurrences(of: "msea://", with: ""))&formhash=\(UserInfo.shared.formhash)")!
            // swiftlint:enble force_unwrapping
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.configHeaderFields()
            let (data, _) = try await URLSession.shared.data(for: request)
            if let html = try? HTML(html: data, encoding: .utf8) {
                if let message = html.at_xpath("//div[@id='messagetext']/p")?.text, !message.isEmpty {
                    if message.contains("setTimeout") {
                        let text = message.components(separatedBy: "setTimeout")[0]
                        hud.show(message: text)
                    } else {
                        hud.show(message: message)
                    }

                    page = 1
                    await loadData()
                } else {
                    let tds = html.xpath("//div[@class='bm bw0']//td[@valign='top']/table/tr/td")
                    var list = [FriendGroupModel]()
                    tds.forEach { element in
                        var group = FriendGroupModel()
                        if let text = element.at_xpath("/label")?.text {
                            group.name = text
                        }
                        if let text = element.at_xpath("/label/input/@value")?.text {
                            group.gid = text
                        }
                        list.append(group)
                    }

                    groupList = list
                    if !groupList.isEmpty {
                        isConfirming.toggle()
                    }
                }
            }

            isHidden = true
        }
    }

    private func getContent(friend: InteractiveFriendListModel) -> AttributedString {
        var text = AttributedString("")

        var name = AttributedString(friend.name)
        name.foregroundColor = .secondaryTheme

        let content = AttributedString(friend.content)

        var action = AttributedString(friend.action)
        action.foregroundColor = .secondaryTheme
        action.link = URL(string: friend.actionURL)

        text.append(name)
        text.append(content)
        text.append(action)

        text.font = .font16

        return text
    }
}

struct InteractiveFriendContentView_Previews: PreviewProvider {
    static var previews: some View {
        InteractiveFriendContentView()
    }
}

struct InteractiveFriendListModel: Identifiable {
    var id = UUID()
    var uid = ""
    var avatar = ""
    var name = ""
    var time = ""
    var content = ""
    var action = ""
    var actionURL = ""
}

struct FriendGroupModel: Identifiable {
    var id = UUID()
    var gid = ""
    var name = ""
}
