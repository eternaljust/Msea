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
    /// 用户认证
    static let auth = "authKey"
    /// 校验码
    static let formhash = "formhashKey"
    /// 访问量
    static let views = "viewsKey"
    /// 积分
    static let integral = "integralKey"
    /// Bit
    static let bits = "bitsKey"
    /// 好友
    static let friend = "friendKey"
    /// 违规
    static let violation = "violationKey"
    /// 主题
    static let topic = "topicKey"
    /// 日志
    static let blog = "blogKey"
    /// 相册
    static let album = "albumKey"
    /// 分享
    static let share = "shareKey"
}

/// 存储属性
struct CacheKeys {
    /// 每日福利规则
    static let signRule = "signRuleKey"
    /// 签到表达
    static let signExpression = "signExpressionKey"
    /// 签到提示
    static let signPlaceholder = "signPlaceholderKey"
    /// 签到时间小时
    static let daysignHour = "daysignHourKey"
    /// 签到时间分钟
    static let daysignMinute = "daysignMinuteKey"
    /// 签到开关
    static let daysignIsOn = "daysignIsOnKey"
    /// 选中 tab
    static let selectedTab = "selectedTabKey"
}

/// 通知
extension NSNotification.Name {
    static let login = Notification.Name("LoginNotification")
    static let logout = Notification.Name("LogoutNotification")
    static let daysign = Notification.Name("LogoutNotification")
}

/// 常量
struct Constants {
    /// 每日签到标识
    static let daysignIdentifier = "daysignIdentifier"
    /// 本地通知操作
    static let localNotificatonAction = "localNotificatonAction"
    /// 本地通知参数值
    static let localNotificatonJSONString = "localNotificatonJSONString"
}
