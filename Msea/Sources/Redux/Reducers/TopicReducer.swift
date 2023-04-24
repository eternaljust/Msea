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
    case let .loadListComplete(tab: tab, page: page, list: list):
        switch tab {
        case .new:
            state.newData.topics = page == 1 ? list : (state.newData.topics + list)
            state.newData.isHidden = true
        case .hot:
            state.hotData.topics = page == 1 ? list : (state.hotData.topics + list)
            state.hotData.isHidden = true
        case .newthread:
            state.newthreadData.topics = page == 1 ? list : (state.newthreadData.topics + list)
            state.newthreadData.isHidden = true
        }
    case .pageAdd(let tab):
        switch tab {
        case .new:
            state.newData.page += 1
        case .hot:
            state.hotData.page += 1
        case .newthread:
            state.newthreadData.page += 1
        }
    case .resetPage(let tab):
        switch tab {
        case .new:
            state.newData.page = 1
        case .hot:
            state.hotData.page = 1
        case .newthread:
            state.newthreadData.page = 1
        }
    case .setUid(let uid):
        state.uid = uid
    case .setTid(let tid):
        state.tid = tid
    default:
        break
    }
}
