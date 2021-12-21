//
//  SettingContentView.swift
//  Msea
//
//  Created by tzqiang on 2021/12/20.
//  Copyright © 2021 eternal.just. All rights reserved.
//

import SwiftUI
import Kanna

struct SettingContentView: View {
    @EnvironmentObject private var hud: HUDState
    @Environment(\.dismiss) private var dismiss

    @State private var itemSections: [SettingSection] = [
        SettingSection(items: [.review, .feedback, .share]),
        SettingSection(items: [.urlschemes, .about]),
        SettingSection(items: [.logout])
    ]

    var body: some View {
        VStack {
            List {
                ForEach(itemSections) { section in
                    Section {
                        ForEach(section.items) { item in
                            HStack {
                                if item != .logout {
                                    Image(systemName: item.icon)

                                    Text(item.title)

                                    Spacer()

                                    Image(systemName: "chevron.right")
                                } else {
                                    Text(item.title)
                                        .foregroundColor(.red)
                                        .frame(maxWidth: .infinity, alignment: .center)
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                if item == .logout {
                                    Task {
                                        await logout()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    private func logout() async {
        Task {
            // swiftlint:disable force_unwrapping
            let url = URL(string: "\(kAppBaseURL)member.php?mod=logging&action=logout&formhash=\(UserInfo.shared.formhash)")!
            // swiftlint:enble force_unwrapping
            print(url.absoluteString)
            let (data, _) = try await URLSession.shared.data(from: url)
            if let html = try? HTML(html: data, encoding: .utf8) {
                print(html.toHTML)
                UserInfo.shared.reset()
                NotificationCenter.default.post(name: .logout, object: nil)
                hud.show(message: "已退出登录！")
                dismiss()
            }
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
    case review
    case share
    case feedback
    case urlschemes
    case about
    case logout

    var id: String { self.rawValue }

    var icon: String {
        switch self {
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
