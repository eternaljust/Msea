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

final class FSAppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        let sceneConfig = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        sceneConfig.delegateClass = FSSceneDelegate.self // 👈🏻
        return sceneConfig
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
