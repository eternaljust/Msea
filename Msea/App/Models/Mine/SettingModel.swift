//
//  SettingModel.swift
//  Msea
//
//  Created by tzqiang on 2023/4/21.
//  Copyright © 2023 eternal.just. All rights reserved.
//

import Foundation
import Intents
import Common

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
    case delete
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
        case .delete:
            return ""
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
        case .delete:
            return "注销账号"
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

enum AboutItem: String, CaseIterable, Identifiable {
    case license
    case sdklist
    case sourceCode

    var id: String { self.rawValue }

    var title: String {
        switch self {
        case .license:
            return "开源协议"
        case .sourceCode:
            return "源代码"
        case .sdklist:
            return "SDK 目录"
        }
    }

    var url: String {
        switch self {
        case .license:
            return ""
        case .sourceCode:
            return "https://github.com/eternaljust/Msea"
        case .sdklist:
            return ""
        }
    }
}

enum LicenseItem: String, CaseIterable, Identifiable {
    case kanna

    var id: String { self.rawValue }

    var title: String {
        switch self {
        case .kanna:
            return "Kanna"
        }
    }

    var url: String {
        switch self {
        case .kanna:
            return "https://github.com/tid-kijyun/Kanna"
        }
    }
}

enum URLSchemesItem: String, CaseIterable, Identifiable {
    case daysign
    case ranklist
    case notice
    case space
    case viewthread

    var id: String { self.rawValue }

    var title: String {
        switch self {
        case .daysign:
            return "每日签到"
        case .ranklist:
            return "排行榜"
        case .notice:
            return "消息提醒"
        case .space:
            return "个人空间"
        case .viewthread:
            return "帖子内容页"
        }
    }

    var action: String {
        switch self {
        case .daysign:
            return "msea://daysign"
        case .ranklist:
            return "msea://ranklist"
        case .notice:
            return "msea://notice"
        case .space:
            return "msea://space?uid=id"
        case .viewthread:
            return "msea://viewthread?tid=id"
        }
    }
}

enum SiriShortcutItem: String, CaseIterable, Identifiable {
    case daysign
    case ranklist

    var id: String { self.rawValue }

    var title: String {
        switch self {
        case .daysign:
            return "每日签到"
        case .ranklist:
            return "排行榜"
        }
    }

    var shortcut: INShortcut {
        switch self {
        case .daysign:
            let userActivity = NSUserActivity(activityType: Constants.daysignUserActivityType)
            userActivity.title = "虫部落签到"
            userActivity.suggestedInvocationPhrase = "虫部落签到"

            return INShortcut(userActivity: userActivity)
        case .ranklist:
            let userActivity = NSUserActivity(activityType: Constants.ranklistUserActivityType)
            userActivity.title = "虫部落排行榜"
            userActivity.suggestedInvocationPhrase = "虫部落排行榜"

            return INShortcut(userActivity: userActivity)
        }
    }
}
