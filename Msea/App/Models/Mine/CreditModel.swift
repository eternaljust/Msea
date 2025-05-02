//
//  CreditModel.swift
//  Msea
//
//  Created by tzqiang on 2023/4/21.
//  Copyright © 2023 eternal.just. All rights reserved.
//

import Foundation

enum CreditItem: String, CaseIterable, Identifiable {
    case mycredit
    case usergroup

    var id: String { self.rawValue }
    var title: String {
        switch self {
        case .mycredit: return "我的积分"
        case .usergroup: return "用户组"
        }
    }
    var index: Int {
        switch self {
        case .mycredit: return 0
        case .usergroup: return 1
        }
    }
}

enum MyCreditTab: String, CaseIterable, Identifiable {
    case list
    case system
    case rule

    var id: String { self.rawValue }
    var title: String {
        switch self {
        case .list:
            return "积分收益"
        case .system:
            return "系统奖励"
        case .rule:
            return "积分规则"
        }
    }
}

struct CreditListModel: Identifiable {
    var id = UUID()
    var action = ""
    var bit = ""
    var content = ""
    var time = ""
    var isAdd = true
}

struct CreditSystemListModel: Identifiable {
    var id = UUID()
    var rid = ""
    var action = ""
    var count = ""
    var cycles = ""
    var bit = ""
    var violation = ""
    var time = ""
}

struct CreditRuleListModel: Identifiable {
    var id = UUID()
    var action = ""
    var count = ""
    var cycles = ""
    var bit = ""
    var violation = ""
}

class CreditRuleObject: ObservableObject {
    @Published var rid = ""
}

struct UserGroupListModel: Identifiable {
    var id = UUID()
    var title = ""
    var current = ""
    var currentImage = ""
    var other = ""
    var otherImage = ""
}

struct UserGroupHeaderModel: Identifiable {
    var id = UUID()
    var title = ""
    var current = ""
    var other = ""

    var list = [UserGroupListModel]()
}

enum UserGroupItem: String, Identifiable {
    case admin
    case supermoderator
    case moderator
    case internshipmoderator
    case webeditor
    case informationinspector
    case auditor
    case vicewebmaster

    case bannedspeaking
    case forbidden
    case bannedip
    case visitor
    case waitingforverificationmembership
    case qqvisitor

    case ban
    case lv0
    case lv1
    case lv2
    case lv3
    case lv4
    case lv5
    case lv6

    var id: String { self.rawValue }
    var gid: String {
        switch self {
        case .admin:
            return "1"
        case .supermoderator:
            return "2"
        case .moderator:
            return "3"
        case .internshipmoderator:
            return "16"
        case .webeditor:
            return "17"
        case .informationinspector:
            return "18"
        case .auditor:
            return "19"
        case .vicewebmaster:
            return "21"

        case .bannedspeaking:
            return "4"
        case .forbidden:
            return "5"
        case .bannedip:
            return "6"
        case .visitor:
            return "7"
        case .waitingforverificationmembership:
            return "8"
        case .qqvisitor:
            return "20"

        case .ban:
            return "9"
        case .lv0:
            return "11"
        case .lv1:
            return "12"
        case .lv2:
            return "13"
        case .lv3:
            return "14"
        case .lv4:
            return "15"
        case .lv5:
            return "22"
        case .lv6:
            return "23"
        }
    }
    var title: String {
        switch self {
        case .admin:
            return "管理员"
        case .supermoderator:
            return "超级版主"
        case .moderator:
            return "版主"
        case .internshipmoderator:
            return "实习版主"
        case .webeditor:
            return "网站编辑"
        case .informationinspector:
            return "信息监察员"
        case .auditor:
            return "审核员"
        case .vicewebmaster:
            return "副版主"

        case .bannedspeaking:
            return "禁止发言"
        case .forbidden:
            return "禁止访问"
        case .bannedip:
            return "禁止 IP"
        case .visitor:
            return "游客"
        case .waitingforverificationmembership:
            return "等待验证会员"
        case .qqvisitor:
            return "QQ游客"

        case .ban:
            return "BAN"
        case .lv0:
            return "LV0"
        case .lv1:
            return "LV1"
        case .lv2:
            return "LV2"
        case .lv3:
            return "LV3"
        case .lv4:
            return "LV4"
        case .lv5:
            return "LV5"
        case .lv6:
            return "LV6"
        }
    }
}

enum UserGroupMenu: String, CaseIterable, Identifiable {
    case manage
    case normal
    case level

    var id: String { self.rawValue }
    var title: String {
        switch self {
        case .manage:
            return "站点管理组"
        case .normal:
            return "普通用户组"
        case .level:
            return "晋级用户组"
        }
    }

    var items: [UserGroupItem] {
        switch self {
        case .manage:
            return [
                .admin,
                .supermoderator,
                .moderator,
                .internshipmoderator,
                .webeditor,
                .informationinspector,
                .auditor,
                .vicewebmaster
            ]
        case .normal:
            return [
                .bannedspeaking,
                .forbidden,
                .bannedip,
                .visitor,
                .waitingforverificationmembership,
                .qqvisitor
            ]
        case .level:
            return [
                .ban,
                .lv0,
                .lv1,
                .lv2,
                .lv3,
                .lv4,
                .lv5,
                .lv6
            ]
        }
    }
}
