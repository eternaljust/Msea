//
//  HomeAction.swift
//  Msea
//
//  Created by tzqiang on 2023/4/23.
//  Copyright © 2023 eternal.just. All rights reserved.
//

import Foundation

enum HomeAction {
    case navigationBarHidden(_ hidden: Bool)
    case checkNotice
    case updateNotice(_ notice: String)
    case loadDataError(_ error: String)
    case setTid(_ tid: String)
    case setUid(_ uid: String)
}
