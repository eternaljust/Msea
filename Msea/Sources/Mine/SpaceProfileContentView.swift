//
//  SpaceProfileContentView.swift
//  Msea
//
//  Created by tzqiang on 2022/1/17.
//  Copyright © 2022 eternal.just. All rights reserved.
//

import SwiftUI
import Kanna

/// 个人空间资料
struct SpaceProfileContentView: View {
    var uid = ""
    var username = ""

    @State private var selectedProfileTab = ProfileTab.topic
    @State private var profile = ProfileModel()
    @EnvironmentObject private var hud: HUDState
    @State private var isShielding = false
    @State private var tabs: [ProfileTab] = [.topic, .firendvisitor]
    @State private var needLogin = false
    @State private var showAlert = false
    @State private var isShieldHidden = false
    @State private var isUserGroup = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack {
            AsyncImage(url: URL(string: profile.avatar)) { image in
                image.resizable()
            } placeholder: {
                ProgressView()
            }
            .frame(width: 80, height: 80)
            .cornerRadius(5)

            Text("\(profile.name) uid(\(uid))")
                .font(.font17Blod)
                .padding(.bottom, -2)
                .onTapGesture {
                    UIPasteboard.general.string = uid
                    hud.show(message: "已复制 uid")
                }

            NavigationLink(destination: UserGroupContentView(), isActive: $isUserGroup) {
                Text(profile.level)
                    .font(.font17)
                    .foregroundColor(.secondaryTheme)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 300)
                    .padding(.bottom, -2)
                    .onTapGesture {
                        if !UserInfo.shared.isLogin() {
                            needLogin.toggle()
                        } else {
                            isUserGroup.toggle()
                        }
                    }
            }

            Text("好友: \(Text(profile.friend).foregroundColor(.theme))  回帖: \(Text(profile.reply).foregroundColor(.theme))  主题: \(Text(profile.topic).foregroundColor(.theme))")
                .font(.font16)

            Text("积分: \(Text(profile.integral).foregroundColor(.theme))  Bit: \(Text(profile.bits).foregroundColor(.theme))  违规:  \(Text(profile.violation).foregroundColor(.theme))")
                .font(.font16)

            Picker("ProfileTab", selection: $selectedProfileTab) {
                ForEach(tabs) { view in
                    Text(view.title)
                        .tag(view)
                }
            }
            .pickerStyle(.segmented)
            .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))

            TabView(selection: $selectedProfileTab) {
                ForEach(tabs) { tab in
                    switch tab {
                    case .topic:
                        ProfileTopicContentView(uid: uid)
                            .tag(tab)
                    case .firendvisitor:
                        ProfileFriendContentView(uid: uid)
                            .tag(tab)
                    case .shielduser, .favorite:
                        EmptyView()
                    }
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .edgesIgnoringSafeArea(UIDevice.current.isPad ? [] : [.bottom])
        }
        .navigationTitle("个人空间")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: {
            isShielding = UserInfo.shared.shieldUsers.contains { $0.uid == uid }
            isShieldHidden = UserInfo.shared.isLogin() ? uid == UserInfo.shared.uid : false

            Task {
                await loadData()
            }
            if !UIDevice.current.isPad {
                TabBarTool.showTabBar(false)
            }
        })
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    if !UserInfo.shared.isLogin() {
                        needLogin.toggle()
                        hud.show(message: "屏蔽用户前请先登录")
                    } else {
                        if isShielding {
                            if let index = UserInfo.shared.shieldUsers.firstIndex(where: { $0.uid == uid }) {
                                UserInfo.shared.shieldUsers.remove(at: index)
                                hud.show(message: "已经将该用户移除屏蔽列表")
                                isShielding = false
                                NotificationCenter.default.post(name: .shieldUser, object: nil, userInfo: nil)
                            } else {
                                hud.show(message: "移除失败，请稍后重试")
                            }
                        } else {
                            showAlert.toggle()
                        }
                    }
                } label: {
                    Text(isShielding ? "已屏蔽" : "屏蔽")
                }
                .alert("是否确认要屏蔽\(profile.name)", isPresented: $showAlert) {
                    Button("取消", role: .cancel) {
                    }

                    Button("确认") {
                        if !profile.uid.isEmpty && !profile.name.isEmpty && !profile.avatar.isEmpty {
                            let user = ShieldUserModel(uid: profile.uid, name: profile.name, avatar: profile.avatar)
                            UserInfo.shared.shieldUsers.append(user)
                            hud.show(message: "已经将该用户屏蔽")
                            isShielding = true
                            NotificationCenter.default.post(name: .shieldUser, object: nil, userInfo: nil)
                            dismiss()
                        } else {
                            hud.show(message: "屏蔽失败，请稍后重试")
                        }
                    }
                } message: {
                    Text("屏蔽后将不再看到该用户发表的帖子和回复")
                }
                .isHidden(isShieldHidden)
            }
        }
        .sheet(isPresented: $needLogin) {
            LoginContentView()
        }
        .onReceive(NotificationCenter.default.publisher(for: .login, object: nil)) { _ in
            isShielding = UserInfo.shared.shieldUsers.contains { $0.uid == uid }
        }
    }

    private func loadData() async {
        Task {
            // swiftlint:disable force_unwrapping
            var url = URL(string: "https://www.chongbuluo.com/home.php?mod=space&uid=\(uid)")!
            if !username.isEmpty {
                let parames = "&username=\(username)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                url = URL(string: "https://www.chongbuluo.com/home.php?mod=space\(parames)")!
            }
            // swiftlint:enble force_unwrapping
            var request = URLRequest(url: url)
            request.configHeaderFields()
            let (data, _) = try await URLSession.shared.data(for: request)
            if let html = try? HTML(html: data, encoding: .utf8) {
                if let message = html.at_xpath("//td[@class='xs1']/h2[@class='xs2']")?.text {
                    hud.show(message: message.replacingOccurrences(of: "\r\n", with: ""))
                    return
                }
                let img = html.at_xpath("//div[@class='h cl']//img/@src")
                if let avatar = img?.text {
                    profile.avatar = avatar.replacingOccurrences(of: "&size=small", with: "")
                }
                let mbn = html.at_xpath("//div[@class='h cl']//h2")
                if let name = mbn?.text {
                    profile.name = name.replacingOccurrences(of: "\n", with: "")
                }

                let a1 = html.at_xpath("//ul[@class='cl bbda pbm mbm']//a[1]")?.text ?? ""
                if let text = a1.components(separatedBy: " ").last, !text.isEmpty {
                    profile.friend = text
                }
                let a2 = html.at_xpath("//ul[@class='cl bbda pbm mbm']//a[2]")?.text ?? ""
                if let text = a2.components(separatedBy: " ").last, !text.isEmpty {
                    profile.reply = text
                }
                let a3 = html.at_xpath("//ul[@class='cl bbda pbm mbm']//a[3]")?.text ?? ""
                if let text = a3.components(separatedBy: " ").last, !text.isEmpty {
                    profile.topic = text
                }

                let li2 = html.at_xpath("//div[@id='psts']/ul[@class='pf_l']/li[2]")
                if let text = li2?.text {
                    profile.integral = text.replacingOccurrences(of: "积分", with: "")
                }
                let li3 = html.at_xpath("//div[@id='psts']/ul[@class='pf_l']/li[3]")
                if let text = li3?.text {
                    profile.bits = text.replacingOccurrences(of: "Bit", with: "")
                }
                let li4 = html.at_xpath("//div[@id='psts']/ul[@class='pf_l']/li[4]")
                if let text = li4?.text {
                    profile.violation = text.replacingOccurrences(of: "违规", with: "")
                }
            }
        }

        await loadProfile()
    }

    private func loadProfile() async {
        Task {
            // swiftlint:disable force_unwrapping
            let url = URL(string: "https://www.chongbuluo.com/home.php?mod=space&uid=\(uid)&do=profile")!
            // swiftlint:enble force_unwrapping
            var request = URLRequest(url: url)
            request.configHeaderFields()
            let (data, _) = try await URLSession.shared.data(for: request)
            if let html = try? HTML(html: data, encoding: .utf8) {
                let li = html.xpath("//div[@class='bm_c u_profile']/div[@class='pbm mbm bbda cl'][last()]/ul[1]/li")
                var level = [String]()
                li.forEach { element in
                    if var name = element.at_xpath("/em[@class='xg1']")?.text {
                        name = name.trimmingCharacters(in: .whitespaces)
                        var lv = ""
                        if let text = element.at_xpath("/span")?.text, !text.isEmpty {
                            lv = text.trimmingCharacters(in: .whitespaces)
                        } else if let text = element.text, !text.isEmpty {
                            lv = text.replacingOccurrences(of: name, with: "").trimmingCharacters(in: .whitespaces)
                        }

                        level.append("\(name)(\(lv))")
                    }
                }
                profile.level = level.joined(separator: "  ")
            }
        }
    }
}

struct SpaceProfileContentView_Previews: PreviewProvider {
    static var previews: some View {
        SpaceProfileContentView()
    }
}

struct ProfileModel {
    var uid = ""
    var space = ""
    var level = ""
    var name = ""
    var avatar = ""
    var views = "0"
    var integral = "--"
    var bits = "--"
    var friend = "--"
    var topic = "--"
    var violation = "--"
    var blog = "--"
    var album = "--"
    var share = "--"
    var reply = "--"
}

struct ShieldUserModel: Codable, Identifiable {
    var id = UUID().uuidString
    var uid = ""
    var name = ""
    var avatar = ""
}
