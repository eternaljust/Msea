//
//  UserInfo.swift
//  Msea
//
//  Created by tzqiang on 2021/12/13.
//  Copyright © 2021 eternal.just. All rights reserved.
//

import Foundation

/// 用户信息
class UserInfo: NSObject {
    /// 单例
    static let shared: UserInfo = UserInfo()

    func reset() {
        uid = ""
        space = ""
        level = "LV0"
        name = ""
        avatar = ""
        auth = ""
        formhash = ""
    }

    func isLogin() -> Bool {
        return !auth.isEmpty
    }

    @UserDefaultsBacked(key: UserKeys.uid) var uid = ""
    @UserDefaultsBacked(key: UserKeys.space) var space = ""
    @UserDefaultsBacked(key: UserKeys.level) var level = "LV0"
    @UserDefaultsBacked(key: UserKeys.name) var name = ""
    @UserDefaultsBacked(key: UserKeys.avatar) var avatar = ""
    @UserDefaultsBacked(key: UserKeys.auth) var auth = ""
    @UserDefaultsBacked(key: UserKeys.formhash) var formhash = ""
}
