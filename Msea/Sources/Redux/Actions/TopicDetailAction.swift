//
//  TopicDetailAction.swift
//  Msea
//
//  Created by tzqiang on 2023/4/27.
//  Copyright © 2023 eternal.just. All rights reserved.
//

import Foundation

enum TopicDetailAction {
    case resetList
    case shieldUsers
    case loadList(tid: String)
    case loadListComplete(header: TopicDetailHeaderModel, detail: TopicDetailModel, list: [TopicCommentModel])
    case loadDataError(_ error: String)
    case pageAdd
    case resetPage
    case selectedPage(_ page: Int)
    case replaceList(_ list: [TopicCommentModel])
    case setNodeFid125(_ value: Bool)
    case setTagId(_ id: String)
}
