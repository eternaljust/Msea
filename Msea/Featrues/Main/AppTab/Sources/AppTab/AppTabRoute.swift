//
//  AppTabRoute.swift
//  Common
//
//  Created by eternaljust on 2025/5/11.
//

import SwiftUI
import EJRouter

/// 主 Tab 切换专用路由
public enum AppTabRoute: AppRoute {
    /// 切换 tab
    case switchTab(target: AppTab, shouldPopToRoot: Bool = true)

    public var pathPattern: String { "main/tab" }
    public var presentationStyle: RoutePresentationStyle { .tabSwitch }
    public var parameters: [String : String] {
        [
            "target": target.rawValue,
            "popToRoot": shouldPopToRoot.description
        ]
    }

    public var target: AppTab {
        switch self {
        case .switchTab(let target, _): return target
        }
    }

    public var shouldPopToRoot: Bool {
        switch self {
        case .switchTab(_, let shouldPopToRoot): return shouldPopToRoot
        }
    }
}

/// 首页路由器
public struct MainTabRouter: RouteParserProtocol, RouteHandlerProtocol {
    public static let moduleIdentifier = "MainTabRoute"

    // MARK: - RouteParserProtocol
    public static func parse(
        pathComponents: [String],
        parameters: [String: String]
    ) -> (any AppRoute)? {
        switch pathComponents {
        case ["switchTab"]:
            guard let target = parameters["target"] else { return nil }
            let tab = AppTab(rawValue: target) ?? .home
            return AppTabRoute.switchTab(target: tab, shouldPopToRoot: true)
        default: return nil
        }
    }

    // MARK: - RouteHandlerProtocol
    public func handle(route: any AppRoute, router: Router) {
        guard let appTabRoute = route as? AppTabRoute else { return }

        switch appTabRoute.presentationStyle {
        case .tabSwitch:
            if AppTabSelection.shared.item != appTabRoute.target {
                AppTabSelection.shared.item = appTabRoute.target
                AppTabSelection.shared.shouldPopToRoot = appTabRoute.shouldPopToRoot
            }
        default: break
        }
    }

    public func resolveView(for route: any AppRoute) -> AnyView {
        AnyView(EmptyView())
    }
}
