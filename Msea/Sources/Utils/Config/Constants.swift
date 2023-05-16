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
    /// 回帖
    static let reply = "replyKey"
    /// 屏蔽用户
    static let shieldUsers = "shieldUsersKey"
    /// 缓存时间
    static let cacheTime = "cacheTimeKey"

    /// 网络缓存
    static let groupHTTPHeaderFields = "groupHTTPHeaderFieldsKey"
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
    /// 默认 uid
    static let defaultUid = "defaultUidKey"
    ///  同意使用条款
    static let agreeTermsOfService = "agreeTermsOfServiceKey"

    /// 消息提醒开关
    static let groupNoticeIsOn = "groupNoticeIsOnKey"
    /// 主题风格设置
    static let colorScheme = "colorSchemeKey"
    /// 评分弹框间隔
    static let reviewCount = "reviewCountKey"
    /// 图片点击 url
    static let clickedImageUrl = "clickedImageUrlKey"
}

/// 通知
extension NSNotification.Name {
    static let login = Notification.Name("LoginNotification")
    static let logout = Notification.Name("LogoutNotification")
    static let daysign = Notification.Name("DaysignNotification")
    static let notice = Notification.Name("NoticeNotification")
    static let shieldUser = Notification.Name("ShieldUserNotification")
    static let colorScheme = Notification.Name("ColorSchemeNotification")
    static let postPublish = Notification.Name("PostPublishNotification")
}

/// 常量
struct Constants {
    /// 每日签到标识
    static let daysignIdentifier = "daysignIdentifier"
    /// 本地通知操作
    static let localNotificatonAction = "localNotificatonAction"
    /// 本地通知参数值
    static let localNotificatonJSONString = "localNotificatonJSONString"
    /// 虫部落签到
    static let daysignUserActivityType = "com.eternaljust.Msea.daysign"
    /// 虫部落排行榜
    static let ranklistUserActivityType = "com.eternaljust.Msea.ranklist"
}
