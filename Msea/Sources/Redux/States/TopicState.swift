//
//  TopicState.swift
//  Msea
//
//  Created by tzqiang on 2023/4/24.
//  Copyright © 2023 eternal.just. All rights reserved.
//

import Foundation

struct TopicState {
    var tabList: [TopicTab: TopicListTabModel] = [
        .new: .init(tab: .new),
        .hot: .init(tab: .hot),
        .newthread: .init(tab: .newthread)
    ]
    var uid = ""
    var tid = ""
}
