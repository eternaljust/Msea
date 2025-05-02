//
//  InteractiveModel.swift
//  Msea
//
//  Created by tzqiang on 2023/4/21.
//  Copyright © 2023 eternal.just. All rights reserved.
//

import Foundation

enum InteractiveTab: String, CaseIterable, Identifiable {
    case friend
    case poke

    var id: String { self.rawValue }
    var title: String {
        switch self {
        case .poke:
            return "打招呼"
        case .friend:
            return "好友"
        }
    }
}

struct InteractivePokeListModel: Identifiable {
    var id = UUID()
    var uid = ""
    var avatar = ""
    var name = ""
    var time = ""
    var gif = ""
    var content = ""
    var action = ""
    var actionURL = ""
    var ignore = ""
    var ignoreURL = ""
}

struct PokeGroupModel: Identifiable {
    var id = UUID()
    var pid = ""
    var name = ""
    var gif = ""
}

struct InteractiveFriendListModel: Identifiable {
    var id = UUID()
    var uid = ""
    var avatar = ""
    var name = ""
    var time = ""
    var content = ""
    var action = ""
    var actionURL = ""
}

struct FriendGroupModel: Identifiable {
    var id = UUID()
    var gid = ""
    var name = ""
}
