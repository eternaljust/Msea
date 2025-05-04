//
//  Constants.swift
//  Msea
//
//  Created by tzqiang on 2021/12/13.
//  Copyright © 2021 eternal.just. All rights reserved.
//

import Foundation

/// 用户属性
public struct UserKeys {
    /// id
    public static let uid = "uidKey"
    /// 个人空间
    public static let space = "spaceKey"
    /// 用户组
    public static let level = "levelKey"
    /// 用户名
    public static let name = "nameKey"
    /// 头像
    public static let avatar = "avatarKey"
    /// 用户认证
    public static let auth = "authKey"
    /// 校验码
    public static let formhash = "formhashKey"
    /// 访问量
    public static let views = "viewsKey"
    /// 积分
    public static let integral = "integralKey"
    /// Bit
    public static let bits = "bitsKey"
    /// 好友
    public static let friend = "friendKey"
    /// 违规
    public static let violation = "violationKey"
    /// 主题
    public static let topic = "topicKey"
    /// 日志
    public static let blog = "blogKey"
    /// 相册
    public static let album = "albumKey"
    /// 分享
    public static let share = "shareKey"
    /// 回帖
    public static let reply = "replyKey"
    /// 屏蔽用户
    public static let shieldUsers = "shieldUsersKey"
    /// 缓存时间
    public static let cacheTime = "cacheTimeKey"

    /// 网络缓存
    public static let groupHTTPHeaderFields = "groupHTTPHeaderFieldsKey"
}

/// 存储属性
public struct CacheKeys {
    /// 每日福利规则
    public static let signRule = "signRuleKey"
    /// 签到表达
    public static let signExpression = "signExpressionKey"
    /// 签到提示
    public static let signPlaceholder = "signPlaceholderKey"
    /// 签到时间小时
    public static let daysignHour = "daysignHourKey"
    /// 签到时间分钟
    public static let daysignMinute = "daysignMinuteKey"
    /// 签到开关
    public static let daysignIsOn = "daysignIsOnKey"
    /// 选中 tab
    public static let selectedTab = "selectedTabKey"
    /// 默认 uid
    public static let defaultUid = "defaultUidKey"
    ///  同意使用条款
    public static let agreeTermsOfService = "agreeTermsOfServiceKey"

    /// 消息提醒开关
    public static let groupNoticeIsOn = "groupNoticeIsOnKey"
    /// 主题风格设置
    public static let colorScheme = "colorSchemeKey"
    /// 评分弹框间隔
    public static let reviewCount = "reviewCountKey"
    /// 图片点击 url
    public static let clickedImageUrl = "clickedImageUrlKey"
}

/// 通知
public extension NSNotification.Name {
    static let login = Notification.Name("LoginNotification")
    static let logout = Notification.Name("LogoutNotification")
    static let daysign = Notification.Name("DaysignNotification")
    static let notice = Notification.Name("NoticeNotification")
    static let shieldUser = Notification.Name("ShieldUserNotification")
    static let colorScheme = Notification.Name("ColorSchemeNotification")
    static let postPublish = Notification.Name("PostPublishNotification")
}

/// 常量
public struct Constants {
    /// 每日签到标识
    public static let daysignIdentifier = "daysignIdentifier"
    /// 本地通知操作
    public static let localNotificatonAction = "localNotificatonAction"
    /// 本地通知参数值
    public static let localNotificatonJSONString = "localNotificatonJSONString"
    /// 虫部落签到
    public static let daysignUserActivityType = "com.eternaljust.Msea.daysign"
    /// 虫部落排行榜
    public static let ranklistUserActivityType = "com.eternaljust.Msea.ranklist"
}
