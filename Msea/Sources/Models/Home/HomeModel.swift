//
//  HomeModel.swift
//  Msea
//
//  Created by tzqiang on 2023/4/21.
//  Copyright © 2023 eternal.just. All rights reserved.
//

import Foundation

enum TabBarItem: String, CaseIterable, Identifiable {
    case home
    case node
    case notice
    case mine

    var id: String { self.rawValue }
    var icon: String {
        switch self {
        case .home: return "house"
        case .node: return "circle.grid.cross.fill"
        case .notice: return "bell.fill"
        case .mine: return "person"
        }
    }
    var title: String {
        switch self {
        case .home: return "虫部落"
        case .node: return "节点"
        case .notice: return "通知"
        case .mine: return "我的"
        }
    }
}

class TabItemSelection: ObservableObject {
    @Published var index: TabBarItem = CacheInfo.shared.selectedTab
}

enum TopicTab: String, CaseIterable, Identifiable {
    case new
    case hot
    case newthread

    var id: String { self.rawValue }
    var title: String {
        switch self {
        case .new: return "最新回复"
        case .hot: return "最新热门"
        case .newthread: return "最新发表"
        }
    }
}

struct TopicListModel: Identifiable {
    var id = UUID()
    var uid = ""
    var tid = ""
    var name = ""
    var avatar = ""
    var title = ""
    var time = ""
    var icon1 = ""
    var icon2 = ""
    var icon3 = ""
    var icon4 = ""
    var attachment = ""
    var attachmentColorRed = false
    var examine = 0
    var reply = 0
}

struct TopicListTabModel {
    private(set) var tab: TopicTab
    var topics = [TopicListModel]()
    var page = 1
    var isHidden = false
}

struct TopicCommentModel: Identifiable {
    var id = UUID()
    var uid = ""
    var pid = ""
    var reply = ""
    var favorite = ""
    var name = ""
    var avatar = ""
    var lv = ""
    var time = ""
    var content = ""
    var isText = true
    var webViewHeight: CGFloat = .zero
}

struct WebURLItem: Identifiable {
    var id = UUID()
    var url = ""
}

struct TagItemModel: Identifiable {
    var id = UUID()
    var tid = ""
    var title = ""
}

enum ReportMenuItem: String, CaseIterable, Identifiable {
    case ad
    case violation
    case malicious
    case repetition

    var id: String { self.rawValue }
    var title: String {
        switch self {
        case .ad:
            return "广告垃圾"
        case .violation:
            return "违规内容"
        case .malicious:
            return "恶意灌水"
        case .repetition:
            return "重复发帖"
        }
    }
}
