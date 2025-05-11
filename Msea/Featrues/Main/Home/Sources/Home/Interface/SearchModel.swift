//
//  SearchModel.swift
//  Msea
//
//  Created by tzqiang on 2023/4/21.
//  Copyright © 2023 eternal.just. All rights reserved.
//

import Foundation
import Observation

public enum SearchTab: String, CaseIterable, Identifiable {
    case post
    case user

    public var id: String { self.rawValue }
    public var title: String {
        switch self {
        case .post: return "帖子"
        case .user: return "用户"
        }
    }
}

@Observable
public class SearchState {
    public var keywrod = ""

    public init() {}
}

public struct SearchListModel: Identifiable {
    public var id = UUID()
    public var tid = ""
    public var title = ""
    public var content = ""
    public var time = ""
    public var replyViews = ""
    public var name = ""
    public var plate = ""

    public init() {}
}

public struct UserListModel: Identifiable {
    public var id = UUID()
    public var uid = ""
    public var avatar = ""
    public var content = ""
    public var name = ""

    public init() {}
}
