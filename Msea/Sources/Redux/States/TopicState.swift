//
//  TopicState.swift
//  Msea
//
//  Created by tzqiang on 2023/4/24.
//  Copyright © 2023 eternal.just. All rights reserved.
//

import Foundation

struct TopicState {
    var newData = TopicListTabModel(tab: .new)
    var hotData = TopicListTabModel(tab: .hot)
    var newthreadData = TopicListTabModel(tab: .newthread)
    var uid = ""
    var tid = ""
}
