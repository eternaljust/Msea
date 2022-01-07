//
//  MseaApp.swift
//  Msea
//
//  Created by tzqiang on 2021/12/3.
//

import SwiftUI

@main
struct MseaApp: App {
    @StateObject var hudState = HUDState()
    @UIApplicationDelegateAdaptor var delegate: FSAppDelegate
    @Environment(\.scenePhase) var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView()
                .hud(isPresented: $hudState.isPresented) {
                    Text(hudState.message)
                }
                .environmentObject(hudState)
        }
        .onChange(of: scenePhase) { value in
            switch value {
            case .active:
                print("App is active")
                guard let shortcutItem = FSAppDelegate.shortcutItem else { return }
                if shortcutItem.type == "签到" {
                    LocalNotification.shared.routingDaysign()
                    FSAppDelegate.shortcutItem = nil
                }
            case .inactive:
                print("App is inactive")
            case .background:
                print("App is in background")
                LocalNotification.shared.clearBadge()
            @unknown default:
                print("ScenePhase received an unexpected new value")
            }
        }
    }
}
