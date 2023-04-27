//
//  TopicDetailReducer.swift
//  Msea
//
//  Created by tzqiang on 2023/4/27.
//  Copyright © 2023 eternal.just. All rights reserved.
//

import Foundation

func topicDetailReducer(state: inout TopicDetailState, action: TopicDetailAction) {
    switch action {
    case .resetList:
        state.header = TopicDetailHeaderModel()
        state.detail = TopicDetailModel()
        state.comments = []
    case .shieldUsers:
        state.comments = state.comments.filter { model in
            !UserInfo.shared.shieldUsers.contains { $0.uid == model.uid }
        }
    case let .loadListComplete(header: header, detail: detail, list: list):
        state.header = header
        state.detail = detail
        state.comments = state.detail.page == 1 ? list : (state.comments + list)
    case .pageAdd:
        state.detail.page += 1
        state.detail.isSelectedPage = false
    case .resetPage:
        state.detail.page = 1
        state.detail.isSelectedPage = false
    case .selectedPage(let page):
        state.detail.page = page
        state.detail.isSelectedPage = true
    case .replaceList(let list):
        state.comments = list
    case .setNodeFid125(let value):
        state.detail.isNodeFid125 = value
    case .setTagId(let id):
        state.header.tagId = id
    default:
        break
    }
}
