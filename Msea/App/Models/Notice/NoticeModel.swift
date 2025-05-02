//
//  NoticeModel.swift
//  Msea
//
//  Created by tzqiang on 2023/4/21.
//  Copyright © 2023 eternal.just. All rights reserved.
//

import Foundation

enum NoticeItem: String, CaseIterable, Identifiable {
    case mypost
    case interactive
    case system
//    case app

    var id: String { self.rawValue }
    var icon: String {
        switch self {
        case .mypost: return "newspaper"
        case .interactive: return "repeat.circle"
        case .system: return "gearshape"
//        case .app: return "app.badge"
        }
    }
    var title: String {
        switch self {
        case .mypost: return "我的帖子"
        case .interactive: return "坛友互动"
        case .system: return "系统提醒"
//        case .app: return "应用提醒"
        }
    }
    var index: Int {
        switch self {
        case .mypost: return 0
        case .interactive: return 1
        case .system: return 2
//        case .app: return 3
        }
    }
}

enum MyPostTab: String, CaseIterable, Identifiable {
    case post
    case pcomment
    case activity
    case reward
    case goods
    case at

    var id: String { self.rawValue }
    var title: String {
        switch self {
        case .post:
            return "帖子"
        case .pcomment:
            return "点评"
        case .activity:
            return "活动"
        case .reward:
            return "悬赏"
        case .goods:
            return "商品"
        case .at:
            return "提到我"
        }
    }

    var body: String {
        switch self {
        case .post:
            return "回复了您的帖子"
        case .pcomment:
            return "回复了您的点评"
        case .activity:
            return "活动"
        case .reward:
            return "悬赏"
        case .goods:
            return "商品"
        case .at:
            return "@"
        }
    }
}

struct PostListModel: Identifiable {
    var id = UUID()
    var uid = ""
    var ptid = ""
    var pid = ""
    var avatar = ""
    var name = ""
    var time = ""
    var title = ""
}
