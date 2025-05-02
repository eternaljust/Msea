//
//  RankModel.swift
//  Msea
//
//  Created by tzqiang on 2023/4/21.
//  Copyright © 2023 eternal.just. All rights reserved.
//

import Foundation

enum RankListTab: String, CaseIterable, Identifiable {
    case member
    case thread

    var id: String { self.rawValue }
    var title: String {
        switch self {
        case .member: return "用户"
        case .thread: return "帖子"
        }
    }
}

enum CreditPostTab: String, CaseIterable, Identifiable {
    case credit
    case post

    var id: String { self.rawValue }
    var title: String {
        switch self {
        case .credit: return "积分排行"
        case .post: return "发帖数排行"
        }
    }
}

enum MemberCreditTab: String, CaseIterable, Identifiable {
    case all
    case bit
    case violation

    var id: String { self.rawValue }

    var title: String {
        switch self {
        case .all: return "全部"
        case .bit: return "Bit"
        case .violation: return "违规"
        }
    }

    var orderby: String {
        switch self {
        case .all: return "all"
        case .bit: return "2"
        case .violation: return "4"
        }
    }
}

enum MemberPostTab: String, CaseIterable, Identifiable {
    case posts
    case digestposts
    case thismonth
    case today

    var id: String { self.rawValue }

    var title: String {
        switch self {
        case .posts: return "发帖数"
        case .digestposts: return "精华数"
        case .thismonth: return "最近30天发帖数"
        case .today: return "最近24小时发帖数"
        }
    }

    var orderby: String { self.rawValue }
}

struct CreditPostListModel: Identifiable {
    var id = UUID()
    var num = ""
    var numTop = false
    var uid = ""
    var avatar = ""
    var name = ""
    var title = ""
}

enum TreadRankTab: String, CaseIterable, Identifiable {
    case replies
    case views
    case favtimes
    case heats

    var id: String { self.rawValue }
    var title: String {
        switch self {
        case .replies: return "回复"
        case .views: return "查看"
        case .favtimes: return "收藏"
        case .heats: return "热度"
        }
    }
}

enum TreadRankOrderbyTab: String, CaseIterable, Identifiable {
    case thisweek
    case thismonth
    case today
    case all

    var id: String { self.rawValue }

    var title: String {
        switch self {
        case .thisweek: return "本周"
        case .thismonth: return "本月"
        case .today: return "今日"
        case .all: return "全部"
        }
    }
}

struct TreadRankListModel: Identifiable {
    var id = UUID()
    var tid = ""
    var uid = ""
    var fid = ""
    var num = ""
    var numTop = false
    var name = ""
    var time = ""
    var plate = ""
    var count = ""
    var title = ""
}
