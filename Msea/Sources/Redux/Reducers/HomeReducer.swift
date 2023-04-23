//
//  HomeReducer.swift
//  Msea
//
//  Created by tzqiang on 2023/4/23.
//  Copyright © 2023 eternal.just. All rights reserved.
//

import Foundation

func homeReducer(state: inout HomeState, action: HomeAction) {
    switch action {
    case .navigationBarHidden(let hidden):
        state.navigationBarHidden = hidden
    case .updateNotice(let notice):
        state.notice = notice
    default:
        break
    }
}
