//
//  ApplicationDelegate.swift
//  Msea
//
//  Created by tzqiang on 2021/12/9.
//  Copyright © 2021 eternal.just. All rights reserved.
//

import SwiftUI

final class FSSceneDelegate: UIResponder, UIWindowSceneDelegate, ObservableObject {
    var hudState: HUDState? {
        didSet {
            setupHudWindow()
        }
    }
    var toastWindow: UIWindow?
    weak var windowScene: UIWindowScene?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        windowScene = scene as? UIWindowScene
    }

    func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem) async -> Bool {
        FSAppDelegate.shortcutItem = shortcutItem
        return true
    }

    func setupHudWindow() {
        guard let windowScene = windowScene, let toastState = hudState else {
            return
        }

        let toastViewController = UIHostingController(rootView: HudSceneView().environmentObject(toastState))
        toastViewController.view.backgroundColor = .clear

        let toastWindow = PassThroughWindow(windowScene: windowScene)
        toastWindow.rootViewController = toastViewController
        toastWindow.isHidden = false
        self.toastWindow = toastWindow
    }
}

final class FSAppDelegate: NSObject, UIApplicationDelegate, UIWindowSceneDelegate {
    static var shortcutItem: UIApplicationShortcutItem?
    var window: UIWindow?

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        let sceneConfig = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        sceneConfig.delegateClass = FSSceneDelegate.self // 👈🏻
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

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        if scene is UIWindowScene, let windowScene = scene as? UIWindowScene {
            window = UIWindow(windowScene: windowScene)
            window?.makeKeyAndVisible()
        }
    }

    private func configSDK() {
        UMConfigure.initWithAppkey("5dbb9469570df3e553000449", channel: "App Store")
        UMCrashConfigure.setCrashCBBlock {
            return ""
        }
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

class PassThroughWindow: UIWindow {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let hitView = super.hitTest(point, with: event) else { return nil }
        return rootViewController?.view == hitView ? nil : hitView
    }
}
