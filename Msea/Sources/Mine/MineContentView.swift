//
//  MineContentView.swift
//  Msea
//
//  Created by Awro on 2021/12/5.
//  Copyright © 2021 eternal.just. All rights reserved.
//

import SwiftUI
import Kanna

/// 我的详情
struct MineContentView: View {
    @State private var isPresented = false
    @State private var isLogin = UserInfo.shared.isLogin()
    @State private var avatar = UserInfo.shared.avatar
    @State private var name = UserInfo.shared.name
    @State private var views = UserInfo.shared.views
    @State private var integral = UserInfo.shared.integral
    @State private var bits = UserInfo.shared.bits
    @State private var violation = UserInfo.shared.violation
    @State private var friend = UserInfo.shared.friend
    @State private var topic = UserInfo.shared.topic
    @State private var blog = UserInfo.shared.blog
    @State private var album = UserInfo.shared.album
    @State private var share = UserInfo.shared.share
    @State private var selectedMineTab = MineTab.topic

    var body: some View {
        NavigationView {
            VStack {
                if isLogin {
                    AsyncImage(url: URL(string: avatar)) { image in
                        image.resizable()
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: 80, height: 80)
                    .cornerRadius(5)

                    Text(name)
                        .padding(.bottom, -2)

                    Text("已有 \(Text(views).foregroundColor(.red)) 人来访过")
                        .font(.font15)
                        .padding(.bottom, 1)

                    Text("积分: \(Text(integral).foregroundColor(.theme))  Bit: \(Text(bits).foregroundColor(.theme))  好友: \(Text(friend).foregroundColor(.theme))  主题: \(Text(topic).foregroundColor(.theme))")
                        .font(.font14)

                    Text("违规: \(Text(violation).foregroundColor(.theme))  日志: \(Text(blog).foregroundColor(.theme))  相册:  \(Text(album).foregroundColor(.theme))  分享: \(Text(share).foregroundColor(.theme))")
                        .font(.font14)

                    Picker("MineTab", selection: $selectedMineTab) {
                        ForEach(MineTab.allCases) { view in
                            Text(view.title)
                                .tag(view)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))

                    TabView(selection: $selectedMineTab) {
                        ForEach(MineTab.allCases) { mine in
                            switch mine {
                            case .topic:
                                ProfileTopicContentView()
                                    .tag(mine)
                            case .firendvisitor:
                                FriendVisitorContentView()
                                    .tag(mine)
                            case .messageboard:
                                MessageBoardContentView()
                                    .tag(mine)
                            }
                        }
                    }
                    .tabViewStyle(.page)
                    .indexViewStyle(.page(backgroundDisplayMode: .never))

                    Spacer()
                } else {
                    Button("登录") {
                        isPresented.toggle()
                    }
                }
            }
            .sheet(isPresented: $isPresented) {
                LoginContentView()
            }
            .navigationTitle("我的")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                NavigationLink(destination: SettingContentView()) {
                    Text("设置")
                }
            }
            .onAppear(perform: {
                if isLogin {
                    Task {
                        await loadData()
                    }
                }
                TabBarTool.showTabBar(true)
            })
            .onReceive(NotificationCenter.default.publisher(for: .login, object: nil)) { _ in
                isLogin.toggle()
                Task {
                    await loadData()
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .logout, object: nil)) { _ in
                isLogin.toggle()
            }
        }
    }

    private func loadData() async {
        Task {
            // swiftlint:disable force_unwrapping
            let url = URL(string: "\(kAppBaseURL)\(UserInfo.shared.space)")!
            // swiftlint:enble force_unwrapping
            var request = URLRequest(url: url)
            request.configHeaderFields()
            let (data, _) = try await URLSession.shared.data(for: request)
            if let html = try? HTML(html: data, encoding: .utf8) {
                let img = html.at_xpath("//div[@id='profile_content']//img/@src", namespaces: nil)
                if let avatar = img?.text {
                    UserInfo.shared.avatar = avatar
                    self.avatar = avatar
                }
                let mbn = html.at_xpath("//div[@id='profile_content']//h2", namespaces: nil)
                if let name = mbn?.text {
                    UserInfo.shared.name = name
                    self.name = name
                }
                let xi1 = html.at_xpath("//div[@id='statistic_content']//strong[@class='xi1']", namespaces: nil)
                if let views = xi1?.text {
                    UserInfo.shared.views = views
                    self.views = views
                }
                let li1 = html.at_xpath("//ul[@class='xl xl2 cl']/li[1]/a", namespaces: nil)
                if let integral = li1?.text {
                    UserInfo.shared.integral = integral
                    self.integral = integral
                }
                let li2 = html.at_xpath("//ul[@class='xl xl2 cl']/li[2]/a", namespaces: nil)
                if let bits = li2?.text {
                    UserInfo.shared.bits = bits
                    self.bits = bits
                }
                let li3 = html.at_xpath("//ul[@class='xl xl2 cl']/li[3]/a", namespaces: nil)
                if let violation = li3?.text {
                    UserInfo.shared.violation = violation
                    self.violation = violation
                }
                let li4 = html.at_xpath("//ul[@class='xl xl2 cl']/li[4]/a", namespaces: nil)
                if let friend = li4?.text {
                    UserInfo.shared.friend = friend
                    self.friend = friend
                }
                let li5 = html.at_xpath("//ul[@class='xl xl2 cl']/li[5]/a", namespaces: nil)
                if let topic = li5?.text {
                    UserInfo.shared.topic = topic
                    self.topic = topic
                }
                let li6 = html.at_xpath("//ul[@class='xl xl2 cl']/li[6]/a", namespaces: nil)
                if let blog = li6?.text {
                    UserInfo.shared.blog = blog
                    self.blog = blog
                }
                let li7 = html.at_xpath("//ul[@class='xl xl2 cl']/li[7]/a", namespaces: nil)
                if let album = li7?.text {
                    UserInfo.shared.album = album
                    self.album = album
                }
                let li8 = html.at_xpath("//ul[@class='xl xl2 cl']/li[8]/a", namespaces: nil)
                if let share = li8?.text {
                    UserInfo.shared.share = share
                    self.share = share
                }

                html.getFormhash()
            }
        }
    }
}

struct MineContentView_Previews: PreviewProvider {
    static var previews: some View {
        MineContentView()
    }
}

enum MineTab: String, CaseIterable, Identifiable {
    case topic
    case firendvisitor
    case messageboard

    var id: String { self.rawValue }
    var title: String {
        switch self {
        case .topic: return "主题"
        case .firendvisitor: return "好友与访客"
        case .messageboard: return "留言板"
        }
    }
}
