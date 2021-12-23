//
//  LocalNotification.swift
//  Msea
//
//  Created by tzqiang on 2021/12/23.
//  Copyright © 2021 eternal.just. All rights reserved.
//

import SwiftUI
import UserNotifications

/// 本地通知
struct LocalNotification {
    /// 单例
    static let shared: LocalNotification = LocalNotification()

    func isAuthorization() async -> Bool {
        return await UNUserNotificationCenter.current().notificationSettings().authorizationStatus == .authorized
    }

    func authorization() async throws -> Bool {
        return try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
    }

    func daysign() async {
        do {
            let isAuthorization = try await authorization()
            if isAuthorization {
                let content = UNMutableNotificationContent()
                content.title = "每日签到"
                content.body = "打开 Msea 签到，立即获取 Bit 奖励！"
                content.badge = 1
                content.sound = .default
                content.userInfo = [Constants.localNotificatonAction: NotificationAction.daysign.rawValue]

                var dateComponents = DateComponents(hour: 17)
                dateComponents.minute = 45

                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                let request = UNNotificationRequest(identifier: Constants.daysignIdentifier, content: content, trigger: trigger)

                try await UNUserNotificationCenter.current().add(request)
                print("LocalNotification daysign")
            }
        } catch {
            print("Notification authorization error:\(error)")
        }
    }

    func removeDaysign() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [Constants.daysignIdentifier])
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [Constants.daysignIdentifier])
    }

    func handleReceive(with userInfo: [AnyHashable: Any]) {
        if userInfo.keys.contains(Constants.localNotificatonAction) {
            if let value = userInfo[Constants.localNotificatonAction] as? String, let action = NotificationAction(rawValue: value) {
                switch action {
                case .daysign:
                    print("Router daysign")
                }
            }
        }

        clearBadge()
    }

    func clearBadge() {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
}

enum NotificationAction: String {
    case daysign
}
