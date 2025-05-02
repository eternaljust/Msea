//
//  TopicAction.swift
//  Msea
//
//  Created by tzqiang on 2023/4/24.
//  Copyright © 2023 eternal.just. All rights reserved.
//

import Foundation

enum TopicAction {
    case shieldUsers
    case loadList(tab: TopicTab, page: Int)
    case loadListComplete(tab: TopicTab, page: Int, list: [TopicListModel])
    case pageAdd(_ tab: TopicTab)
    case resetPage(_ tab: TopicTab)
    case loadDataError(_ error: String)
    case setTid(_ tid: String)
    case setUid(_ uid: String)
}
