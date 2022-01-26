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

    @State private var itemSections: [SettingSection] = [
        SettingSection(items: [.signalert]),
        SettingSection(items: [.review, .feedback, .share]),
        SettingSection(items: [.urlschemes, .about])
    ]
    @State private var logoutSetion = SettingSection(items: [.logout])

    @State var isShowingMail = false

    var body: some View {
        VStack {
            List {
                ForEach(itemSections) { section in
                    Section {
                        ForEach(section.items) { item in
                            switch item {
                            case .signalert:
                                HStack {
                                    Image(systemName: item.icon)

                                    Text(item.title)

                                    Spacer()

                                    SignalertContentView()
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
                            case .feedback:
                                Button {
                                    if MFMailComposeViewController.canSendMail() {
                                        isShowingMail.toggle()
                                    } else {
                                        hud.show(message: "您的设备尚未设置邮箱，请在“邮件”应用中设置后再尝试发送。")
                                    }
                                } label: {
                                    HStack {
                                        Image(systemName: item.icon)

                                        Text(item.title)

                                        Spacer()

                                        Indicator()
                                    }
                                    .foregroundColor(Color(light: .black, dark: .white))
                                }
                            case .review, .share, .urlschemes, .about:
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
            addLogoutSection()
            if !UIDevice.current.isPad {
                TabBarTool.showTabBar(false)
            }
        }
        .sheet(isPresented: $isShowingMail) {
            Email(isShowing: $isShowingMail)
        }
        .onReceive(NotificationCenter.default.publisher(for: .login, object: nil)) { _ in
            addLogoutSection()
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
            if let html = try? HTML(html: data, encoding: .utf8) {
                if let text = html.toHTML, text.contains("退出") {
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

    @ViewBuilder private func getContentView(_ item: SettingItem) -> some View {
        switch item {
        case .signalert:
            EmptyView()
        case .review:
            EmptyView()
        case .share:
            EmptyView()
        case .feedback:
            EmptyView()
        case .urlschemes:
            URLSchemesContentView()
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
    case review
    case share
    case feedback
    case urlschemes
    case about
    case logout

    var id: String { self.rawValue }

    var icon: String {
        switch self {
        case .signalert:
            return "clock.fill"
        case .review:
            return "star.fill"
        case .share:
            return "arrowshape.turn.up.right.fill"
        case .feedback:
            return "text.bubble.fill"
        case .urlschemes:
            return "personalhotspot.circle.fill"
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
        case .review:
            return "评价应用"
        case .share:
            return "分享给朋友"
        case .feedback:
            return "反馈问题"
        case .urlschemes:
            return "URL Schemes"
        case .about:
            return "关于 Msea"
        case .logout:
            return "退出登录"
        }
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
                        .font(.callout)
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
