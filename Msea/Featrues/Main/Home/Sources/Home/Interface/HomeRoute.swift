//
//  File.swift
//  Home
//
//  Created by eternaljust on 2025/5/11.
//

import SwiftUI
import EJRouter
import Common
import AppTab

/// Home 模块路由
public enum HomeRoute: AppRoute {
    case home

    public var pathPattern: String {
        switch self {
        case .home: return "home"
        }
    }

    public var presentationStyle: RoutePresentationStyle {
        switch self {
        case .home: return .tabSwitch
        }
    }

    public var parameters: [String : String] {
        switch self {
        case .home: return [:]
        }
    }
}

/// 首页路由器
public struct HomeRouter: RouteParserProtocol, RouteHandlerProtocol {
    public static let moduleIdentifier = "HomeRoute"
    private let viewFactory: any HomeViewFactoryProtocol

    // 通过依赖注入初始化
    public init(viewFactory: some HomeViewFactoryProtocol) {
        self.viewFactory = viewFactory
    }

    // MARK: - RouteParserProtocol
    public static func parse(
        pathComponents: [String],
        parameters: [String: String]
    ) -> (any AppRoute)? {
        switch pathComponents {
        case ["home"]: return HomeRoute.home
        default: return nil
        }
    }

    // MARK: - RouteHandlerProtocol
    public func handle(route: any AppRoute, router: Router) {
        guard let homeRoute = route as? HomeRoute else { return }

        switch homeRoute.presentationStyle {
        case .push:
            router.mainNavigationPath.append(homeRoute)
        case .sheet:
            router.presentedRoute = homeRoute
        case .tabSwitch:
            router.navigate(to: AppTabRoute.switchTab(target: .home))
        default: break
        }
    }

    public func resolveView(for route: any AppRoute) -> AnyView {
        guard let homeRoute = route as? HomeRoute else {
            return AnyView(Text("Invalid Route"))
        }

        switch homeRoute {
        case .home:
            return viewFactory.makeHomeView()
        }
    }
}
