//
//  CacheInfo.swift
//  Msea
//
//  Created by tzqiang on 2021/12/14.
//  Copyright © 2021 eternal.just. All rights reserved.
//

import Foundation
import SwiftUI

/// 存储信息
public class CacheInfo: NSObject {
    /// 单例
    public static let shared: CacheInfo = CacheInfo()

    private static let widgetGroup: UserDefaults? = UserDefaults(suiteName: "group.com.eternaljust.Msea.Topic.Widget")

    @AppStorage(CacheKeys.groupNoticeIsOn, store: widgetGroup) public var groupNoticeIsOn = false

    @AppStorage(CacheKeys.signRule) public var signRule = """
                            1. 活动时间：每天00:00开始，23:59结束；
                            2. 每日只能签到一次，签到即获得1 Bit 的奖励；
                            3. 连续签到3天，即第3天额外获得10 Bit 的奖励；
                            4. 连续签到7天，即第7天额外获得30 Bit 的奖励；
                            5. 每日前10名签到者可获得额外1~5 Bit 的随机奖励。
                            """
    @AppStorage(CacheKeys.signExpression) public var signExpression = "签到留言，你的心情随笔，愿望清单...今天吃啥？"
    @AppStorage(CacheKeys.signPlaceholder) public var signPlaceholder = "提倡沿袭古法的纯手工打卡，反对自动签到，自动签到每次将被扣除 10 倍于所得积分 :)"
    @AppStorage(CacheKeys.daysignHour) public var daysignHour = 8
    @AppStorage(CacheKeys.daysignMinute) public var daysignMinute = 0
    @AppStorage(CacheKeys.daysignIsOn) public var daysignIsOn = false
    @AppStorage(CacheKeys.defaultUid) public var defaultUid = "4"
    @AppStorage(CacheKeys.agreeTermsOfService) public var agreeTermsOfService = false
    @AppStorage(CacheKeys.reviewCount) public var reviewCount = 0
    @AppStorage(CacheKeys.clickedImageUrl) public var clickedImageUrl = ""

    @AppStorage(CacheKeys.selectedTab) public var selectedTab: TabBarItem = .home
    @AppStorage(CacheKeys.colorScheme) public var colorScheme: ColorSchemeTab = .unspecified
}
