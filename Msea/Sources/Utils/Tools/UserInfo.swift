//
//  UserInfo.swift
//  Msea
//
//  Created by tzqiang on 2021/12/13.
//  Copyright © 2021 eternal.just. All rights reserved.
//

import Foundation
import SwiftUI

/// 用户信息
class UserInfo: NSObject {
    /// 单例
    static let shared: UserInfo = UserInfo()

    private static let widgetGroup: UserDefaults? = UserDefaults(suiteName: "group.com.eternaljust.Msea.Topic.Widget")

    func reset() {
        uid = ""
        space = ""
        level = "LV0"
        name = ""
        avatar = ""
        auth = ""
        formhash = ""
        views = "--"
        integral = "--"
        bits = "--"
        friend = "--"
        topic = "--"
        violation = "--"
        blog = "--"
        album = "--"
        share = "--"
        shieldUsers = []
    }

    func isLogin() -> Bool {
        return !auth.isEmpty
    }

    @AppStorage(UserKeys.groupHTTPHeaderFields, store: widgetGroup) var headerFields: Data = Data()

    @AppStorage(UserKeys.uid) var uid = ""
    @AppStorage(UserKeys.space) var space = ""
    @AppStorage(UserKeys.level) var level = ""
    @AppStorage(UserKeys.name) var name = ""
    @AppStorage(UserKeys.avatar) var avatar = ""
    @AppStorage(UserKeys.auth) var auth = ""
    @AppStorage(UserKeys.formhash) var formhash = ""
    @AppStorage(UserKeys.views) var views = "0"
    @AppStorage(UserKeys.integral) var integral = "--"
    @AppStorage(UserKeys.bits) var bits = "--"
    @AppStorage(UserKeys.friend) var friend = "--"
    @AppStorage(UserKeys.topic) var topic = "--"
    @AppStorage(UserKeys.violation) var violation = "--"
    @AppStorage(UserKeys.blog) var blog = "--"
    @AppStorage(UserKeys.album) var album = "--"
    @AppStorage(UserKeys.share) var share = "--"
    @AppStorage(UserKeys.shieldUsers) var shieldUsers = [ShieldUserModel]()
}
