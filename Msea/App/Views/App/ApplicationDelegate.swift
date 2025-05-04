//
//  ApplicationDelegate.swift
//  Msea
//
//  Created by tzqiang on 2021/12/9.
//  Copyright © 2021 eternal.just. All rights reserved.
//

import SwiftUI
import UMCommon
import Common

final class FSAppDelegate: NSObject, UIApplicationDelegate, UIWindowSceneDelegate {
    static var shortcutItem: UIApplicationShortcutItem?
    var window: UIWindow?

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        let sceneConfig = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        UNUserNotificationCenter.current().delegate = self
        UIApplication.shared.shortcutItems = [UIApplicationShortcutItem(type: "签到", localizedTitle: "签到", localizedSubtitle: nil, icon: UIApplicationShortcutIcon(systemImageName: "leaf.fill"), userInfo: nil)]
        if let shortcutItem = options.shortcutItem {
            FSAppDelegate.shortcutItem = shortcutItem
        }
        configSDK()
        return sceneConfig
    }

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        if UIDevice.current.isPad {
            return .all
        }
        return .portrait
    }

    func applicationWillTerminate(_ application: UIApplication) {
        CacheInfo.shared.selectedTab = .home
    }

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        if scene is UIWindowScene, let windowScene = scene as? UIWindowScene {
            window = UIWindow(windowScene: windowScene)
            window?.makeKeyAndVisible()
        }
    }

    private func configSDK() {
        var channel: String?
        #if DEBUG
          channel = "Debug"
        #else
          channel = Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt" ? "TestFlight" : nil
        #endif
        UMConfigure.initWithAppkey("5dbb9469570df3e553000449", channel: channel)
//        UMCrashConfigure.setCrashCBBlock {
//            return ""
//        }
    }
}

extension FSAppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("didReceive LocalNotification")
        LocalNotification.shared.handleReceive(with: response.notification.request.content.userInfo)
    }
}

struct HudSceneView: View {
    @EnvironmentObject var hudState: HUDState

    var body: some View {
        Color.clear
            .ignoresSafeArea(.all)
            .hud(isPresented: $hudState.isPresented) {
                Text(hudState.message)
            }
    }
}
