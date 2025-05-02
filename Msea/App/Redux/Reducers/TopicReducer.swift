//
//  TopicReducer.swift
//  Msea
//
//  Created by tzqiang on 2023/4/24.
//  Copyright © 2023 eternal.just. All rights reserved.
//

import Foundation

func topicReducer(state: inout TopicState, action: TopicAction) {
    switch action {
    case .shieldUsers:
        state.tabList.forEach { tab, list in
            let filter = list.topics.filter { model in
                !UserInfo.shared.shieldUsers.contains { $0.uid == model.uid }
            }
            state.tabList[tab]?.topics = filter
        }
    case let .loadListComplete(tab: tab, page: page, list: list):
        if page == 1 {
            state.tabList[tab]?.topics = list
        } else if let topics = state.tabList[tab]?.topics {
            state.tabList[tab]?.topics = topics + list
        }
        state.tabList[tab]?.isProgressHidden = true
    case .pageAdd(let tab):
        if let page = state.tabList[tab]?.page {
            state.tabList[tab]?.page = page + 1
        }
    case .resetPage(let tab):
        state.tabList[tab]?.page = 1
    case .setUid(let uid):
        state.uid = uid
    case .setTid(let tid):
        state.tid = tid
    default:
        break
    }
}
