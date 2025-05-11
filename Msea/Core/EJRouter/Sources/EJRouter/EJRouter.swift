// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI

/// 定义路由展示方式
public enum RoutePresentationStyle {
    case push
    case sheet
    case fullScreenCover
    case tabSwitch
}

/// 增强路由协议
public protocol AppRoute: Hashable {
    /// 路由路径模式（如 "home/detail"）
    var pathPattern: String { get }
    /// 路由方式
    var presentationStyle: RoutePresentationStyle { get }
    /// 参数字典
    var parameters: [String: String] { get }
}

/// 路由处理器协议
public protocol RouteHandler {
    associatedtype Route: AppRoute
    func handle(route: Route, navigationPath: Binding<NavigationPath>)
}

/// 定义路由解析协议
public protocol RouteParserProtocol {
    /// 模块标识符（如 "home"）
    static var moduleIdentifier: String { get }

    /// 解析路径到具体路由
    static func parse(pathComponents: [String], parameters: [String: String]) -> (any AppRoute)?
}

/// 定义路由处理协议
public protocol RouteHandlerProtocol {
    /// 处理路由导航
    func handle(route: any AppRoute, router: Router)

    /// 生成对应视图
    func resolveView(for route: any AppRoute) -> AnyView
}

/// 统一路由管理器
@Observable
open class Router {
    /// 单例
    public static var shared = Router()

    /// 多导航状态管理，主栈导航
    public var mainNavigationPath = NavigationPath()
    /// 当前模态展示
    public var presentedRoute: (any AppRoute)?

    /// 存储注册的解析器 [模块标识符: 解析器类型]
    private var routeParsers: [String: RouteParserProtocol.Type] = [:]
    /// 存储注册的处理器 [模块标识符: 处理器实例]
    private var routeHandlers: [String: RouteHandlerProtocol] = [:]

    /// 注册模块路由系统
    public func registerModule<T: RouteParserProtocol & RouteHandlerProtocol>(
        parser: T.Type,
        handler: T
    ) {
        let identifier = T.moduleIdentifier
        routeParsers[identifier] = parser
        routeHandlers[identifier] = handler
    }

    /// 统一路由处理方法
    open func navigate(to route: any AppRoute) {
        guard let handler = findHandler(for: route) else {
            print("未找到路由处理器")
            return
        }
        handler.handle(route: route, router: self)
    }

    /// 处理返回逻辑
    public func pop() {
        if !mainNavigationPath.isEmpty {
            mainNavigationPath.removeLast()
        }
    }

    /// 返回根视图
    public func popToRoot() {
        if !mainNavigationPath.isEmpty {
            mainNavigationPath.removeLast(mainNavigationPath.count)
        }
    }

    /// 解析深度链接
    public func handleDeepLink(url: URL) {
        guard let route = DeepLinkParser.parse(
            url: url,
            parsers: routeParsers
        ) else { return }
        navigate(to: route)
    }

    private func findHandler(for route: any AppRoute) -> RouteHandlerProtocol? {
        let typeString = String(describing: type(of: route))
        guard let moduleIdentifier = typeString.split(separator: ".").first else {
            return nil
        }
        return routeHandlers[String(moduleIdentifier)]
    }
}

/// 深度链接解析器
struct DeepLinkParser {
    static func parse(
        url: URL,
        parsers: [String: RouteParserProtocol.Type]
    ) -> (any AppRoute)? {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            return nil
        }

        // 解析路径格式：myapp://home/detail?id=123 → ["home", "detail"]
        let pathComponents = components.path.split(separator: "/").map(String.init)
        guard !pathComponents.isEmpty else { return nil }

        // 获取模块标识符
        let moduleIdentifier = pathComponents[0]
        guard let parserType = parsers[moduleIdentifier] else {
            print("未注册的模块路由：\(moduleIdentifier)")
            return nil
        }

        // 交给对应模块解析器处理剩余路径
        let remainingComponents = Array(pathComponents.dropFirst())
        let params = components.queryItems?.reduce(into: [:]) { $0[$1.name] = $1.value } ?? [:]

        return parserType.parse(
            pathComponents: remainingComponents,
            parameters: params
        )
    }
}
