// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI
import Observation
import EJRouter

/// App 主 Tab 选项
public enum AppTab: String, CaseIterable, Identifiable {
    /// 虫部落
    case home
    /// 节点
    case node
    /// 通知
    case notice
    /// 我的
    case mine

    public var id: String { self.rawValue }
    public var icon: String {
        switch self {
        case .home: return "house"
        case .node: return "circle.grid.cross.fill"
        case .notice: return "bell.fill"
        case .mine: return "person"
        }
    }
    public var title: String {
        switch self {
        case .home: return "虫部落"
        case .node: return "节点"
        case .notice: return "通知"
        case .mine: return "我的"
        }
    }
}

/// tab 选中
@Observable
public class AppTabSelection {
    public static var shared = AppTabSelection()
    /// Tab 切换选项
    public var item: AppTab = .home
    /// 返回根视图
    public var shouldPopToRoot: Bool = false {
        didSet {
            if shouldPopToRoot {
                Router.shared.popToRoot()
            }
        }
    }

    public init() {}
}
