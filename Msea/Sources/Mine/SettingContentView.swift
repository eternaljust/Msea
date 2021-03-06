//
//  SettingContentView.swift
//  Msea
//
//  Created by tzqiang on 2021/12/20.
//  Copyright © 2021 eternal.just. All rights reserved.
//

import SwiftUI
import Kanna
import MessageUI
import StoreKit

/// 设置相关
struct SettingContentView: View {
    @EnvironmentObject private var hud: HUDState
    @Environment(\.dismiss) private var dismiss
    @State private var isOn = false
    @State private var colorSchemeTab: ColorSchemeTab = CacheInfo.shared.colorScheme

    @State private var itemSections: [SettingSection] = [
        SettingSection(items: [.signalert, .notice, .colorscheme]),
        SettingSection(items: [.feedback, .review, .contactus, .share, .testflight, .sirishortcut]),
        SettingSection(items: [.cleancache, .dynamicfont]),
        SettingSection(items: [.urlschemes, .termsofservice, .about])
    ]
    @State private var logoutSetion = SettingSection(items: [.logout])

    @State var isShowingMail = false
    @State private var isSharePresented: Bool = false
    @State private var isConfirming = false
    @State private var dynamicTypeSize = UIFontMetrics(forTextStyle: .body).scaledFont(for: .preferredFont(forTextStyle: .body)).pointSize
    @State private var cacheSize = FileManager.default.getCacheSize()
    @State private var showAlert = false

    var body: some View {
        VStack {
            List {
                ForEach(itemSections) { section in
                    Section {
                        ForEach(section.items) { item in
                            switch item {
                            case .signalert:
                                if dynamicTypeSize >= 43 && !UIDevice.current.isPad {
                                    VStack {
                                        HStack {
                                            Image(systemName: item.icon)
                                                .foregroundColor(.theme)

                                            Text(item.title)

                                            Spacer()
                                        }

                                        SignalertContentView()
                                    }
                                } else {
                                    HStack {
                                        Image(systemName: item.icon)
                                            .foregroundColor(.theme)

                                        Text(item.title)

                                        Spacer()

                                        SignalertContentView()
                                    }
                                }
                            case .notice:
                                ZStack(alignment: .leading) {
                                    if dynamicTypeSize >= 43 && !UIDevice.current.isPad {
                                        VStack {
                                            HStack {
                                                Image(systemName: item.icon)
                                                    .symbolRenderingMode(.palette)
                                                    .foregroundStyle(.red, Color.theme)

                                                Text("\(Text(item.title))\n\(Text(item.subTitle).font(.font15).foregroundColor(.secondary))")
                                                    .fixedSize(horizontal: true, vertical: true)

                                                Spacer()
                                            }

                                            MessageNoticeView()
                                                .padding(.trailing, dynamicTypeSize)
                                        }
                                    } else {
                                        HStack {
                                            Image(systemName: item.icon)
                                                .symbolRenderingMode(.palette)
                                                .foregroundStyle(.red, Color.theme)

                                            Text("\(Text(item.title))\n\(Text(item.subTitle).font(.font15).foregroundColor(.secondary))")
                                                .fixedSize(horizontal: true, vertical: true)

                                            Spacer()

                                            MessageNoticeView()
                                        }
                                    }

                                    NavigationLink(destination: getContentView(item)) {
                                        EmptyView()
                                    }
                                    .opacity(0.0)
                                }
                            case .colorscheme:
                                HStack {
                                    Image(systemName: item.icon)
                                        .foregroundColor(.theme)

                                    Text("主题风格")

//                                    Text(item.title)

                                    Spacer()

                                    Picker("ColorSchemeTab", selection: $colorSchemeTab) {
                                        ForEach(ColorSchemeTab.allCases) { view in
                                            Text(view.title)
                                                .tag(view)
                                        }
                                    }
                                    .pickerStyle(.segmented)
                                    .frame(width: 120)
                                    .onChange(of: colorSchemeTab) { newValue in
                                        print(newValue)
                                        CacheInfo.shared.colorScheme = newValue
                                        print(CacheInfo.shared.colorScheme)
                                        print("---")
                                        NotificationCenter.default.post(name: .colorScheme, object: nil)
                                    }
                                }
                            case .logout:
                                Button {
                                    if CacheInfo.shared.daysignIsOn || CacheInfo.shared.groupNoticeIsOn {
                                        showAlert.toggle()
                                    } else {
                                        Task {
                                            await logout()
                                        }
                                    }
                                } label: {
                                    Text(item.title)
                                        .foregroundColor(.red)
                                        .frame(maxWidth: .infinity, alignment: .center)
                                }
                            case .share, .feedback, .review, .contactus, .testflight:
                                Button {
                                    buttonAction(item)
                                } label: {
                                    HStack {
                                        Image(systemName: item.icon)

                                        Text(item.title)

                                        Spacer()

                                        Indicator()
                                    }
                                    .foregroundColor(Color(light: .black, dark: .white))
                                }
                                .confirmationDialog("", isPresented: $isConfirming) {
                                    getActionSheetListView()
                                } message: {
                                    Text("联系我们")
                                }
                            case .cleancache:
                                Button {
                                    FileManager.default.cleanCache()
                                    cacheSize = FileManager.default.getCacheSize()
                                    hud.show(message: "缓存清理成功")
                                } label: {
                                    HStack {
                                        Image(systemName: item.icon)

                                        Text(item.title)

                                        Spacer()

                                        Text(cacheSize)
                                            .padding(.trailing, -5)

                                        Indicator()
                                    }
                                    .foregroundColor(Color(light: .black, dark: .white))
                                }
                            case .sirishortcut, .urlschemes, .dynamicfont, .termsofservice, .about:
                                NavigationLink(destination: getContentView(item)) {
                                    HStack {
                                        Image(systemName: item.icon)

                                        Text(item.title)

                                        Spacer()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationBarTitle("设置")
        .onAppear {
            colorSchemeTab = CacheInfo.shared.colorScheme
            cacheSize = FileManager.default.getCacheSize()
            addLogoutSection()
            if !UIDevice.current.isPad {
                TabBarTool.showTabBar(false)
            }

            if CacheInfo.shared.reviewCount.isMultiple(of: 18) {
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                    SKStoreReviewController.requestReview(in: windowScene)
                }
            }
            CacheInfo.shared.reviewCount += 1
        }
        .alert("提示", isPresented: $showAlert) {
            Button("取消", role: .cancel) {
            }

            Button("确认退出") {
                Task {
                    await logout()
                }
            }
        } message: {
            Text("退出登录后，已开启的“签到提醒”和“新消息通知”会被关闭，切换账号登录后需重新开启。")
        }
        .sheet(isPresented: $isShowingMail) {
            Email(isShowing: $isShowingMail)
        }
        .sheet(isPresented: $isSharePresented) {
            if let image = UIImage(named: "Icon"), let url = URL(string: "https://apps.apple.com/app/id1607297894") {
                ShareSheet(items: [ "Msea - 虫部落搜索论坛第三方应用",
                                    image,
                                    url
                                  ])
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .login, object: nil)) { _ in
            addLogoutSection()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIContentSizeCategory.didChangeNotification, object: nil)) { _ in
            dynamicTypeSize = UIFontMetrics(forTextStyle: .body).scaledFont(for: .preferredFont(forTextStyle: .body)).pointSize
            print("dynamicTypeSize:\(dynamicTypeSize)")
        }
    }

    private func buttonAction(_ item: SettingItem) {
        if item == .share {
            isSharePresented.toggle()
        } else if item == .review {
            if let url = URL(string: "https://apps.apple.com/app/id1607297894?action=write-review") {
                UIApplication.shared.open(url)
            }
        } else if item == .feedback {
            if MFMailComposeViewController.canSendMail() {
                isShowingMail.toggle()
            } else {
                hud.show(message: "您的设备尚未设置邮箱，请在“邮件”应用中设置后再尝试发送。")
            }
        } else if item == .contactus {
            isConfirming.toggle()
        } else if item == .testflight {
            if let url = URL(string: "https://testflight.apple.com/join/YW7YgKWV") {
                UIApplication.shared.open(url)
            }
        }
    }

    private func logout() async {
        Task {
            // swiftlint:disable force_unwrapping
            let url = URL(string: "\(kAppBaseURL)member.php?mod=logging&action=logout&formhash=\(UserInfo.shared.formhash)")!
            // swiftlint:enble force_unwrapping
            var request = URLRequest(url: url)
            request.configHeaderFields()
            let (data, _) = try await URLSession.shared.data(for: request)
            if let html = try? HTML(html: data, encoding: .utf8), html.toHTML != nil {
                CacheInfo.shared.daysignIsOn = false
                CacheInfo.shared.groupNoticeIsOn = false
                UserInfo.shared.reset()
                NotificationCenter.default.post(name: .logout, object: nil)
                hud.show(message: "您已退出登录！")
                if itemSections.count == 4 {
                    itemSections.remove(at: 3)
                }
                dismiss()
            } else {
                hud.show(message: "退出异常，请稍后重试！")
            }
        }
    }

    private func addLogoutSection() {
        Task {
            var contains = false
            if let last = itemSections.last, last.items.contains(.logout) {
                contains = true
            }
            if UserInfo.shared.isLogin() && !contains {
                itemSections.append(logoutSetion)
            }
        }
    }

    @ViewBuilder private func getActionSheetListView() -> some View {
        Button {
            if let url = URL(string: "https://m.weibo.cn/u/3266569590") {
                UIApplication.shared.open(url)
            }
        } label: {
            Text("微博：@远恒之义")
        }

        Button {
            if let url = URL(string: "https://twitter.com/eternaljust_") {
                UIApplication.shared.open(url)
            }
        } label: {
            Text("推特：@eternaljust_")
        }

        Button {
            UIPasteboard.general.string = "eternaljust"
            hud.show(message: "微信号已复制")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                if let url = URL(string: "weixin://") {
                    UIApplication.shared.open(url)
                }
            }
        } label: {
            Text("加微信：eternaljust  发送：加群")
        }

        Button("取消", role: .cancel) {
        }
    }

    @ViewBuilder private func getContentView(_ item: SettingItem) -> some View {
        switch item {
        case .signalert, .review, .colorscheme, .share, .feedback,
             .contactus, .testflight, .cleancache, .logout:
            EmptyView()
        case .notice:
            MseeageNoticeContentView()
        case .sirishortcut:
            SiriShortcutContentView()
        case .urlschemes:
            URLSchemesContentView()
        case .dynamicfont:
            DynamicFontContentView()
        case .termsofservice:
            TermsOfServiceContentView()
        case .about:
            AboutContentView()
        }
    }
}

struct SettingContentView_Previews: PreviewProvider {
    static var previews: some View {
        SettingContentView()
    }
}

struct SettingSection: Identifiable {
    var id = UUID()
    var items: [SettingItem]
}

enum SettingItem: String, CaseIterable, Identifiable {
    case signalert
    case notice
    case colorscheme
    case review
    case share
    case feedback
    case contactus
    case testflight
    case sirishortcut
    case urlschemes
    case dynamicfont
    case cleancache
    case termsofservice
    case about
    case logout

    var id: String { self.rawValue }

    var icon: String {
        switch self {
        case .signalert:
            return "clock.fill"
        case .notice:
            return "bell.badge.fill"
        case .colorscheme:
            return "circle.lefthalf.filled"
        case .review:
            return "star.fill"
        case .share:
            return "arrowshape.turn.up.right.fill"
        case .feedback:
            return "text.bubble.fill"
        case .contactus:
            return "message.fill"
        case .testflight:
            return "app.fill"
        case .sirishortcut:
            return "rectangle.fill.on.rectangle.fill"
        case .urlschemes:
            return "personalhotspot.circle.fill"
        case .dynamicfont:
            return "a.circle.fill"
        case .cleancache:
            return "paintbrush.fill"
        case .termsofservice:
            return "list.bullet.circle.fill"
        case .about:
            return "exclamationmark.circle.fill"
        case .logout:
            return ""
        }
    }

    var title: String {
        switch self {
        case .signalert:
            return "签到提醒"
        case .notice:
            return "新消息提醒通知"
        case .colorscheme:
            return "主题风格"
        case .review:
            return "评价应用"
        case .share:
            return "分享给朋友"
        case .feedback:
            return "反馈问题"
        case .contactus:
            return "联系我们"
        case .testflight:
            return "加入 TestFlight"
        case .sirishortcut:
            return "添加 Siri 捷径"
        case .urlschemes:
            return "URL Schemes"
        case .dynamicfont:
            return "动态字体大小"
        case .cleancache:
            return "清理缓存"
        case .termsofservice:
            return "使用条款"
        case .about:
            return "关于 Msea"
        case .logout:
            return "退出登录"
        }
    }

    var subTitle: String {
        if self == .notice {
            return "需添加桌面小组件辅助"
        }
        return ""
    }
}

enum ColorSchemeTab: String, CaseIterable, Identifiable {
    case unspecified
    case light
    case dark

    var id: String { self.rawValue }
    var title: String {
        switch self {
        case .unspecified: return "自动"
        case .light: return "浅色"
        case .dark: return "深色"
        }
    }
}

struct SignalertContentView: View {
    @State private var isOn = false
    @State private var selectedDate = Date.now
    @State private var showAlert = false
    @State private var needLogin = false
    @Environment(\.openURL) var openURL

    var body: some View {
        HStack {
            DatePicker("", selection: $selectedDate, displayedComponents: [.hourAndMinute])
                .onChange(of: selectedDate) { value in
                    let components = Calendar.current.dateComponents([.hour, .minute], from: value)
                    if let hour = components.hour, let minute = components.minute {
                        CacheInfo.shared.daysignHour = hour
                        CacheInfo.shared.daysignMinute = minute
                    }
                    if isOn {
                        Task {
                            _ = await LocalNotification.shared.daysign()
                        }
                    }
                }

            Toggle("", isOn: $isOn)
                .alert("通知权限已关闭", isPresented: $showAlert) {
                    Button("取消", role: .cancel) {
                    }

                    Button("去设置") {
                        // swiftlint:disable force_unwrapping
                        openURL(URL(string: UIApplication.openSettingsURLString)!)
                        // swiftlint:enble force_unwrapping
                    }
                } message: {
                    Text("可在设置中重新开启签到提醒")
                        .font(.font16)
                }
                .sheet(isPresented: $needLogin) {
                    LoginContentView()
                }
                .onChange(of: isOn) { value in
                    print(value)
                    if value && !UserInfo.shared.isLogin() {
                        isOn = false
                        needLogin.toggle()
                    } else {
                        Task {
                            if await LocalNotification.shared.isAuthorizationDenied() {
                                if !isOn && !value {
                                    showAlert.toggle()
                                }
                                isOn = false
                            } else {
                                CacheInfo.shared.daysignIsOn = value
                                if value {
                                    if await !LocalNotification.shared.daysign() {
                                        isOn = false
                                    }
                                } else {
                                    LocalNotification.shared.removeDaysign()
                                }
                            }
                        }
                    }
                }
        }
        .tint(.theme)
        .onAppear {
            Task {
                let now = Date.now
                var components = Calendar.current.dateComponents([.hour, .minute], from: now)
                components.hour = CacheInfo.shared.daysignHour
                components.minute = CacheInfo.shared.daysignMinute
                let date = Calendar.current.date(from: components)
                selectedDate = date ?? now
                isOn = await LocalNotification.shared.isAuthorizationDenied() ? false : CacheInfo.shared.daysignIsOn
            }
        }
    }
}

struct MessageNoticeView: View {
    @State private var isOn = false
    @State private var showAlert = false
    @State private var needLogin = false
    @Environment(\.openURL) var openURL

    var body: some View {
        HStack {
            Toggle("", isOn: $isOn)
                .alert("通知权限已关闭", isPresented: $showAlert) {
                    Button("取消", role: .cancel) {
                    }

                    Button("去设置") {
                        // swiftlint:disable force_unwrapping
                        openURL(URL(string: UIApplication.openSettingsURLString)!)
                        // swiftlint:enble force_unwrapping
                    }
                } message: {
                    Text("可在设置中重新开启消息提醒")
                        .font(.font16)
                }
                .sheet(isPresented: $needLogin) {
                    LoginContentView()
                }
                .onChange(of: isOn) { value in
                    print(value)
                    if value && !UserInfo.shared.isLogin() {
                        isOn = false
                        needLogin.toggle()
                    } else {
                        Task {
                            if await LocalNotification.shared.isAuthorizationDenied() {
                                if !isOn && !value {
                                    showAlert.toggle()
                                }
                                isOn = false
                            } else {
                                CacheInfo.shared.groupNoticeIsOn = value
                                if value {
                                    if try await !LocalNotification.shared.authorization() {
                                        isOn = false
                                    }
                                }
                            }
                        }
                    }
                }
        }
        .tint(.theme)
        .onAppear {
            Task {
                isOn = await LocalNotification.shared.isAuthorizationDenied() ? false : CacheInfo.shared.groupNoticeIsOn
            }
        }
    }
}
