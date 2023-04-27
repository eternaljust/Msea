//
//  TopicDetailState.swift
//  Msea
//
//  Created by tzqiang on 2023/4/27.
//  Copyright © 2023 eternal.just. All rights reserved.
//

import Foundation

struct TopicDetailState {
    var header = TopicDetailHeaderModel()
    var detail = TopicDetailModel()
    var comments = [TopicCommentModel]()
}
