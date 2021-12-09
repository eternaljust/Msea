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

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(hudState)
        }
    }
}
