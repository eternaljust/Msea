//
//  Constants.swift
//  Msea
//
//  Created by tzqiang on 2021/12/13.
//  Copyright © 2021 eternal.just. All rights reserved.
//

import Foundation

/// 用户属性
struct UserKeys {
    /// id
    static let uid = "uidKey"
    /// 个人空间
    static let space = "spaceKey"
    /// 用户组
    static let level = "levelKey"
    /// 用户名
    static let name = "nameKey"
    /// 头像
    static let avatar = "avatarKey"
}

/// 存储属性
struct CacheKeys {
    /// 用户认证
    static let auth = "authKey"
    /// 每日福利规则
    static let signRule = "signRuleKey"
    /// 签到表达
    static let signExpression = "signExpressionKey"
    /// 签到提示
    static let signPlaceholder = "signPlaceholderKey"
    /// 校验码
    static let formhash = "formhashKey"
}

/// 通知
extension NSNotification.Name {
    static let login = Notification.Name("LoginNotification")
}
