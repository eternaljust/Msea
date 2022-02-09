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

/// 设置相关
struct SettingContentView: View {
    @EnvironmentObject private var hud: HUDState
    @Environment(\.dismiss) private var dismiss
    @State private var isOn = false

    @State private var itemSections: [SettingSection] = [
        SettingSection(items: [.signalert, .notice]),
        SettingSection(items: [.feedback, .review, .contactus, .share]),
        SettingSection(items: [.cleancache, .dynamicfont]),
        SettingSection(items: [.urlschemes, .termsofservice, .about])
    ]
    @State private var logoutSetion = SettingSection(items: [.logout])

    @State var isShowingMail = false
    @State private var isSharePresented: Bool = false
    @State private var isConfirming = false
    @State private var dynamicTypeSize = UIFontMetrics(forTextStyle: .body).scaledFont(for: .preferredFont(forTextStyle: .body)).pointSize
    @State private var cacheSize = FileManager.default.getCacheSize()

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
                                                    .renderingMode(.original)
                                                    .foregroundColor(.theme)

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
                                                .renderingMode(.original)
                                                .foregroundColor(.theme)

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
                            case .logout:
                                Button {
                                    Task {
                                        await logout()
                                    }
                                } label: {
                                    Text(item.title)
                                        .foregroundColor(.red)
                                        .frame(maxWidth: .infinity, alignment: .center)
                                }
                            case .share, .feedback, .review, .contactus:
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
                            case .urlschemes, .dynamicfont, .termsofservice, .about:
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
            cacheSize = FileManager.default.getCacheSize()
            addLogoutSection()
            if !UIDevice.current.isPad {
                TabBarTool.showTabBar(false)
            }
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
        case .signalert:
            EmptyView()
        case .notice:
            MseeageNoticeContentView()
        case .review:
            EmptyView()
        case .share:
            EmptyView()
        case .feedback:
            EmptyView()
        case .contactus:
            EmptyView()
        case .urlschemes:
            URLSchemesContentView()
        case .dynamicfont:
            DynamicFontContentView()
        case .cleancache:
            EmptyView()
        case .termsofservice:
            TermsOfServiceContentView()
        case .about:
            AboutContentView()
        case .logout:
            EmptyView()
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
    case review
    case share
    case feedback
    case contactus
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
            return "clock"
        case .notice:
            return "app.badge"
        case .review:
            return "star.fill"
        case .share:
            return "arrowshape.turn.up.right.fill"
        case .feedback:
            return "text.bubble.fill"
        case .contactus:
            return "message.fill"
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
        case .review:
            return "评价应用"
        case .share:
            return "分享给朋友"
        case .feedback:
            return "反馈问题"
        case .contactus:
            return "联系我们"
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

struct SignalertContentView: View {
    @State private var isOn = false
    @State private var selectedDate = Date.now
    @State private var showAlert = false
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
                .onChange(of: isOn) { value in
                    Task {
                        print(value)
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
                .onChange(of: isOn) { value in
                    Task {
                        print(value)
                        if await LocalNotification.shared.isAuthorizationDenied() {
                            if !isOn && !value {
                                showAlert.toggle()
                            }
                            isOn = false
                        } else {
                            CacheInfo.shared.noticeIsOn = value
                        }
                    }
                }
        }
        .tint(.theme)
        .onAppear {
            Task {
                isOn = await LocalNotification.shared.isAuthorizationDenied() ? false : CacheInfo.shared.noticeIsOn
            }
        }
    }
}
