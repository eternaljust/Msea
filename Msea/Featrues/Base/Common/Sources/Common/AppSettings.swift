//
//  AppSettings.swift
//  Common
//
//  Created by eternaljust on 2025/5/11.
//

import Foundation

/// App 主题模式选择
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
