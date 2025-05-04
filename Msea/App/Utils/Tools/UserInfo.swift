//
//  UserInfo.swift
//  Msea
//
//  Created by tzqiang on 2021/12/13.
//  Copyright © 2021 eternal.just. All rights reserved.
//

import Foundation
import SwiftUI
import Common

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
        reply = "--"
        shieldUsers = []
        cacheTime = 0
    }

    func isLogin() -> Bool {
        return !auth.isEmpty
    }

    /// 网络缓存
    @AppStorage(UserKeys.groupHTTPHeaderFields, store: widgetGroup) var headerFields: Data = Data()

    /// id
    @AppStorage(UserKeys.uid) var uid = ""
    /// 个人空间
    @AppStorage(UserKeys.space) var space = ""
    /// 用户组
    @AppStorage(UserKeys.level) var level = ""
    /// 用户名
    @AppStorage(UserKeys.name) var name = ""
    /// 头像
    @AppStorage(UserKeys.avatar) var avatar = ""
    /// 用户认证
    @AppStorage(UserKeys.auth) var auth = ""
    /// 校验码
    @AppStorage(UserKeys.formhash) var formhash = ""
    /// 访问量
    @AppStorage(UserKeys.views) var views = "0"
    /// 积分
    @AppStorage(UserKeys.integral) var integral = "--"
    /// Bit
    @AppStorage(UserKeys.bits) var bits = "--"
    /// 好友
    @AppStorage(UserKeys.friend) var friend = "--"
    /// 违规
    @AppStorage(UserKeys.violation) var violation = "--"
    /// 主题
    @AppStorage(UserKeys.topic) var topic = "--"
    /// 日志
    @AppStorage(UserKeys.blog) var blog = "--"
    /// 相册
    @AppStorage(UserKeys.album) var album = "--"
    /// 分享
    @AppStorage(UserKeys.share) var share = "--"
    /// 回帖
    @AppStorage(UserKeys.reply) var reply = "--"
    /// 屏蔽用户
    @AppStorage(UserKeys.shieldUsers) var shieldUsers = [ShieldUserModel]()
    /// 缓存时间
    @AppStorage(UserKeys.cacheTime) var cacheTime: TimeInterval = 0
}
