//
//  RankModel.swift
//  Msea
//
//  Created by tzqiang on 2023/4/21.
//  Copyright © 2023 eternal.just. All rights reserved.
//

import Foundation

public enum RankListTab: String, CaseIterable, Identifiable {
    case member
    case thread

    public var id: String { self.rawValue }
    public var title: String {
        switch self {
        case .member: return "用户"
        case .thread: return "帖子"
        }
    }
}

public enum CreditPostTab: String, CaseIterable, Identifiable {
    case credit
    case post

    public var id: String { self.rawValue }
    public var title: String {
        switch self {
        case .credit: return "积分排行"
        case .post: return "发帖数排行"
        }
    }
}

public enum MemberCreditTab: String, CaseIterable, Identifiable {
    case all
    case bit
    case violation

    public var id: String { self.rawValue }

    public var title: String {
        switch self {
        case .all: return "全部"
        case .bit: return "Bit"
        case .violation: return "违规"
        }
    }

    public var orderby: String {
        switch self {
        case .all: return "all"
        case .bit: return "2"
        case .violation: return "4"
        }
    }
}

public enum MemberPostTab: String, CaseIterable, Identifiable {
    case posts
    case digestposts
    case thismonth
    case today

    public var id: String { self.rawValue }

    public var title: String {
        switch self {
        case .posts: return "发帖数"
        case .digestposts: return "精华数"
        case .thismonth: return "最近30天发帖数"
        case .today: return "最近24小时发帖数"
        }
    }

    public var orderby: String { self.rawValue }
}

public struct CreditPostListModel: Identifiable {
    public var id = UUID()
    public var num = ""
    public var numTop = false
    public var uid = ""
    public var avatar = ""
    public var name = ""
    public var title = ""

    public init() {}
}

public enum TreadRankTab: String, CaseIterable, Identifiable {
    case replies
    case views
    case favtimes
    case heats

    public var id: String { self.rawValue }
    public var title: String {
        switch self {
        case .replies: return "回复"
        case .views: return "查看"
        case .favtimes: return "收藏"
        case .heats: return "热度"
        }
    }
}

public enum TreadRankOrderbyTab: String, CaseIterable, Identifiable {
    case thisweek
    case thismonth
    case today
    case all

    public var id: String { self.rawValue }

    public var title: String {
        switch self {
        case .thisweek: return "本周"
        case .thismonth: return "本月"
        case .today: return "今日"
        case .all: return "全部"
        }
    }
}

public struct TreadRankListModel: Identifiable {
    public var id = UUID()
    public var tid = ""
    public var uid = ""
    public var fid = ""
    public var num = ""
    public var numTop = false
    public var name = ""
    public var time = ""
    public var plate = ""
    public var count = ""
    public var title = ""

    public init() {}
}
