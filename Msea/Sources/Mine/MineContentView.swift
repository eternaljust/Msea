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
    @State private var selectedProfileTab = ProfileTab.topic
    @State private var isNewPost = false
    @State private var isCredit = false

    @EnvironmentObject private var hud: HUDState
    @StateObject private var rule = CreditRuleObject()

    @StateObject private var selection = MyFriendVisitorTraceSelection()
    @State private var isVisitorTrace = false

    private let columns = [
        GridItem(.adaptive(minimum: 60, maximum: 80), spacing: 10)
    ]

    var body: some View {
        NavigationView {
            VStack {
                if isLogin {
                    AsyncImage(url: URL(string: UserInfo.shared.avatar)) { image in
                        image.resizable()
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: 80, height: 80)
                    .cornerRadius(5)

                    Text("\(UserInfo.shared.name) uid(\(UserInfo.shared.uid))")
                        .font(.font17Blod)
                        .padding(.bottom, -2)
                        .onTapGesture {
                            UIPasteboard.general.string = UserInfo.shared.uid
                            hud.show(message: "已复制 uid")
                        }

                    NavigationLink(destination: UserGroupContentView()) {
                        Text(UserInfo.shared.level)
                            .font(.font17)
                            .foregroundColor(.secondaryTheme)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: 300)
                            .padding(.bottom, -2)
                    }

                    Text("已有 \(Text(UserInfo.shared.views).foregroundColor(.red)) 人来访过")
                        .font(.font16)
                        .foregroundColor(Color(light: .black, dark: .white))
                        .padding(.bottom, 1)
                        .onTapGesture {
                            isVisitorTrace = true
                            selection.tab = .visitor
                        }

                    Text("积分: \(Text(UserInfo.shared.integral).foregroundColor(.theme))  Bit: \(Text(UserInfo.shared.bits).foregroundColor(.theme))  好友: \(Text(UserInfo.shared.friend).foregroundColor(.theme))  主题: \(Text(UserInfo.shared.topic).foregroundColor(.theme))")
                        .font(.font16)

                    Text("违规: \(Text(UserInfo.shared.violation).foregroundColor(.theme))  日志: \(Text(UserInfo.shared.blog).foregroundColor(.theme))  相册:  \(Text(UserInfo.shared.album).foregroundColor(.theme))  分享: \(Text(UserInfo.shared.share).foregroundColor(.theme))")
                        .font(.font16)

                    Picker("ProfileTabMine", selection: $selectedProfileTab) {
                        ForEach(ProfileTab.allCases) { view in
                            Text(view.title)
                                .tag(view)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))

                    TabView(selection: $selectedProfileTab) {
                        ForEach(ProfileTab.allCases) { mine in
                            switch mine {
                            case .topic:
                                ProfileTopicContentView(uid: UserInfo.shared.uid)
                                    .tag(mine)
                            case .firendvisitor:
                                FriendVisitorContentView(uid: UserInfo.shared.uid)
                                    .tag(mine)
                            case .messageboard:
                                MessageBoardContentView(uid: UserInfo.shared.uid)
                                    .tag(mine)
                            case .favorite:
                                FavoriteContentView()
                                    .tag(mine)
                            case .shielduser:
                                ShieldUserContentView()
                                    .tag(mine)
                            }
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))

                    NavigationLink(destination: CreditContentView(), isActive: $isCredit) {
                        EmptyView()
                    }
                    .opacity(0.0)

                    NavigationLink(destination: MyFriendVisitorTraceContentView(), isActive: $isVisitorTrace) {
                        EmptyView()
                    }
                    .opacity(0.0)
                } else {
                    Button("登录") {
                        isPresented.toggle()
                    }
                }
            }
            .dialog(isPresented: $isNewPost) {
                VStack {
                    HStack {
                        Spacer()

                        Text("节点导航")
                            .multilineTextAlignment(.leading)
                            .font(.font15)

                        Spacer()

                        Button {
                            isNewPost.toggle()
                        } label: {
                            Image(systemName: "xmark.circle")
                        }
                    }

                    ScrollView {
                        LazyVGrid(columns: columns, alignment: .leading, spacing: 10, pinnedViews: [.sectionHeaders]) {
                            ForEach(PostNaviTab.allCases) { section in
                                Section {
                                    ForEach(section.plates, id: \.id) { plate in
                                        NavigationLink(destination: PublishPostContentView(plate: plate)) {
                                            Text(plate.title)
                                                .font(.font15)
                                                .foregroundColor(.theme)
                                        }
                                    }
                                } header: {
                                    HStack {
                                        Text(section.title)
                                            .foregroundColor(.secondary)
                                            .font(.font15)

                                        Spacer()
                                    }
                                    .background(Color.backGround)
                                }
                            }
                        }
                    }
                }
                .frame(width: UIDevice.current.isPad ? 260 : 300, height: 200)
            }
            .navigationTitle("我的")
            .navigationBarTitleDisplayMode(.inline)
            .ignoresSafeArea(edges: .bottom)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        isNewPost.toggle()
                    } label: {
                        Image(systemName: "square.and.pencil")
                    }
                    .isHidden(!isLogin)
                }

                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        isCredit.toggle()
                    } label: {
                        Image(systemName: "yensign.circle")
                    }
                    .isHidden(!isLogin)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: SettingContentView()) {
                        Text("设置")
                    }
                }
            }
            .onAppear(perform: {
                isLogin = UserInfo.shared.isLogin()
                if isLogin {
                    Task {
                        await loadData()
                    }
                }
                TabBarTool.showTabBar(true)
                isNewPost = false
                CacheInfo.shared.selectedTab = .mine
            })
            .sheet(isPresented: $isPresented) {
                LoginContentView()
            }
            .onReceive(NotificationCenter.default.publisher(for: .login, object: nil)) { _ in
                isLogin = true
                Task {
                    await loadData()
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .logout, object: nil)) { _ in
                isLogin = false
            }

            if isLogin {
                Text("\(UserInfo.shared.name)的个人空间")
            } else {
                Text("登录后可获得更多的信息")
            }
        }
        .environmentObject(rule)
        .environmentObject(selection)
    }

    private func loadData() async {
        Task {
            // swiftlint:disable force_unwrapping
            let url = URL(string: "https://www.chongbuluo.com/home.php?mod=space&uid=\(UserInfo.shared.uid)")!
            // swiftlint:enble force_unwrapping
            var request = URLRequest(url: url)
            request.configHeaderFields()
            let (data, _) = try await URLSession.shared.data(for: request)
            if let html = try? HTML(html: data, encoding: .utf8) {
                let img = html.at_xpath("//div[@id='profile_content']//img/@src")
                if let avatar = img?.text {
                    UserInfo.shared.avatar = avatar
                }
                let mbn = html.at_xpath("//div[@id='profile_content']//h2")
                if let name = mbn?.text {
                    UserInfo.shared.name = name
                }
                let xi1 = html.at_xpath("//div[@id='statistic_content']//strong[@class='xi1']")
                if let views = xi1?.text {
                    UserInfo.shared.views = views
                }
                let li1 = html.at_xpath("//ul[@class='xl xl2 cl']/li[1]/a")
                if let integral = li1?.text {
                    UserInfo.shared.integral = integral
                }
                let li2 = html.at_xpath("//ul[@class='xl xl2 cl']/li[2]/a")
                if let bits = li2?.text {
                    UserInfo.shared.bits = bits
                }
                let li3 = html.at_xpath("//ul[@class='xl xl2 cl']/li[3]/a")
                if let violation = li3?.text {
                    UserInfo.shared.violation = violation
                }
                let li4 = html.at_xpath("//ul[@class='xl xl2 cl']/li[4]/a")
                if let friend = li4?.text {
                    UserInfo.shared.friend = friend
                }
                let li5 = html.at_xpath("//ul[@class='xl xl2 cl']/li[5]/a")
                if let topic = li5?.text {
                    UserInfo.shared.topic = topic
                }
                let li6 = html.at_xpath("//ul[@class='xl xl2 cl']/li[6]/a")
                if let blog = li6?.text {
                    UserInfo.shared.blog = blog
                }
                let li7 = html.at_xpath("//ul[@class='xl xl2 cl']/li[7]/a")
                if let album = li7?.text {
                    UserInfo.shared.album = album
                }
                let li8 = html.at_xpath("//ul[@class='xl xl2 cl']/li[8]/a")
                if let share = li8?.text {
                    UserInfo.shared.share = share
                }

                html.getFormhash()
            }
        }

        await loadProfile()
    }

    private func loadProfile() async {
        Task {
            // swiftlint:disable force_unwrapping
            let url = URL(string: "https://www.chongbuluo.com/home.php?mod=space&uid=\(UserInfo.shared.uid)&do=profile")!
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
                UserInfo.shared.level = level.joined(separator: "  ")
            }
        }
    }
}

struct MineContentView_Previews: PreviewProvider {
    static var previews: some View {
        MineContentView()
    }
}

enum ProfileTab: String, CaseIterable, Identifiable {
    case topic
    case firendvisitor
    case messageboard
    case favorite
    case shielduser

    var id: String { self.rawValue }
    var title: String {
        switch self {
        case .topic: return "主题"
        case .firendvisitor: return "好友访客"
        case .messageboard: return "留言板"
        case .favorite: return "收藏"
        case .shielduser: return "屏蔽"
        }
    }
}

enum PostPlate: String, Identifiable {
    case blackboard
    case tips
    case software
    case keyword
    case methodology
    case resource
    case questionbank
    case create
    case life
    case workplace
    case learning
    case feedback
    case disappearforever
    case google
    case apple
    case researchinfrontier

    var id: String { self.rawValue }
    var fid: String {
        switch self {
        case .blackboard:
            return "2"
        case .tips:
            return "44"
        case .software:
            return "47"
        case .keyword:
            return "93"
        case .methodology:
            return "113"
        case .resource:
            return "114"
        case .questionbank:
            return "117"
        case .create:
            return "119"
        case .life:
            return "120"
        case .workplace:
            return "121"
        case .learning:
            return "122"
        case .feedback:
            return "123"
        case .disappearforever:
            return "125"
        case .google:
            return "126"
        case .apple:
            return "127"
        case .researchinfrontier:
            return "128"
        }
    }

    var title: String {
        switch self {
        case .blackboard:
            return "黑板报"
        case .tips:
            return "Tips"
        case .software:
            return "软件"
        case .keyword:
            return "Keyword"
        case .methodology:
            return "方法论"
        case .resource:
            return "资源"
        case .questionbank:
            return "题库"
        case .create:
            return "发现创造"
        case .life:
            return "生活"
        case .workplace:
            return "职场"
        case .learning:
            return "学途"
        case .feedback:
            return "反馈"
        case .disappearforever:
            return "石沉大海"
        case .google:
            return "Google"
        case .apple:
            return "Apple"
        case .researchinfrontier:
            return "探索前沿"
        }
    }
}

enum PostNaviTab: String, CaseIterable, Identifiable {
    case explore
    case workingfish
    case fulldry
    case support
    case test

    var id: String { self.rawValue }
    var title: String {
        switch self {
        case .explore:
            return "探索"
        case .workingfish:
            return "摸鱼"
        case .fulldry:
            return "干货"
        case .support:
            return "支持"
        case .test:
            return "试验"
        }
    }

    var plates: [PostPlate] {
        switch self {
        case .explore:
            return [
                .keyword,
                .questionbank,
                .methodology,
                .google,
                .researchinfrontier
            ]
        case .workingfish:
            return [
                .create,
                .life,
                .workplace,
                .learning
            ]
        case .fulldry:
            return [
                .tips,
                .software,
                .resource
            ]
        case .support:
            return [
                .feedback,
                .blackboard
            ]
        case .test:
            return [
                .disappearforever,
                .apple
            ]
        }
    }
}
