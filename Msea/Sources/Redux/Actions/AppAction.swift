//
//  AppAction.swift
//  Msea
//
//  Created by tzqiang on 2023/4/21.
//  Copyright © 2023 eternal.just. All rights reserved.
//

import Foundation

enum AppAction {
    case home(action: HomeAction)
    case topic(action: TopicAction)
    case topicDetail(action: TopicDetailAction)
}
