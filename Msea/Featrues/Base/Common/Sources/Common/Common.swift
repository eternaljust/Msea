// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI

/// 底部 Tab 选项
public enum TabBarItem: String, CaseIterable, Identifiable {
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

public class TabItemSelection: ObservableObject {
    @Published public var index: TabBarItem = CacheInfo.shared.selectedTab

    /// public 初始化器
    public init() {}
}

public enum ColorSchemeTab: String, CaseIterable, Identifiable {
    case unspecified
    case light
    case dark

    public var id: String { self.rawValue }
    public var title: String {
        switch self {
        case .unspecified: return "自动"
        case .light: return "浅色"
        case .dark: return "深色"
        }
    }
}
