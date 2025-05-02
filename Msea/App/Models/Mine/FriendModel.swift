//
//  FriendModel.swift
//  Msea
//
//  Created by tzqiang on 2023/4/21.
//  Copyright © 2023 eternal.just. All rights reserved.
//

import Foundation

struct FriendVisitorListModel: Identifiable {
    var id = UUID()
    var type: FriendVisitor
    var persons: [FriendVisitorModel]
}

struct FriendVisitorModel: Identifiable {
    var id = UUID()
    var name = ""
    var uid = ""
    var avatar = ""
    var time = ""
}

enum FriendVisitor: String, CaseIterable, Identifiable {
    case friend
    case visitor

    var id: String { self.rawValue }
    var title: String {
        switch self {
        case .friend: return "好友"
        case .visitor: return "访客"
        }
    }
}

enum MyFriendVisitorTraceTab: String, CaseIterable, Identifiable {
    case friend
    case visitor
    case trace

    var id: String { self.rawValue }

    var title: String {
        switch self {
        case .friend: return "好友列表"
        case .visitor: return "我的访客"
        case .trace: return "我的足迹"
        }
    }

    var header: String {
        switch self {
        case .friend: return "按照好友热度排序"
        case .visitor: return "他们拜访过您，回访一下吧"
        case .trace: return "您曾经拜访过的用户列表"
        }
    }
}

class MyFriendVisitorTraceSelection: ObservableObject {
    @Published var tab: MyFriendVisitorTraceTab = MyFriendVisitorTraceTab.friend
}

struct MyFriendListModel: Identifiable {
    var id = UUID()
    var name = ""
    var uid = ""
    var avatar = ""
    var hot = ""
    var topic = ""
    var integral = ""
}
