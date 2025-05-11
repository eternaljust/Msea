//
//  File.swift
//  Home
//
//  Created by eternaljust on 2025/5/11.
//

import SwiftUI

/// Home 首页视图工厂协议
public protocol HomeViewFactoryProtocol {
    /// 首页
    func makeHomeView() -> AnyView
}
