//
//  SearchModel.swift
//  Msea
//
//  Created by tzqiang on 2023/4/21.
//  Copyright © 2023 eternal.just. All rights reserved.
//

import Foundation

enum SearchTab: String, CaseIterable, Identifiable {
    case post
    case user

    var id: String { self.rawValue }
    var title: String {
        switch self {
        case .post: return "帖子"
        case .user: return "用户"
        }
    }
}

class SearchState: ObservableObject {
    @Published var keywrod = ""
}

struct SearchListModel: Identifiable {
    var id = UUID()
    var tid = ""
    var title = ""
    var content = ""
    var time = ""
    var replyViews = ""
    var name = ""
    var plate = ""
}

struct UserListModel: Identifiable {
    var id = UUID()
    var uid = ""
    var avatar = ""
    var content = ""
    var name = ""
}
