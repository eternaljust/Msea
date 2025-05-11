//
//  File.swift
//  Home
//
//  Created by eternaljust on 2025/5/11.
//

import SwiftUI
import EJDependency
import EJRouter
import IHome

/// Home 模块实现层
public enum HomeModule {
    public static func initialize(router: Router) {
        // 注册依赖项
        DependencyContainer.shared.register(
            HomeViewFactoryProtocol.self,
            implementation: HomeViewFactoryImpl()
        )

        // 注册路由处理器
        let viewFactory = DependencyContainer.shared.resolve(HomeViewFactoryProtocol.self)
        router.registerModule(
            parser: HomeRouter.self,
            handler: HomeRouter(viewFactory: viewFactory)
        )
    }
}

/// 视图工厂实现
private struct HomeViewFactoryImpl: HomeViewFactoryProtocol {
    func makeHomeView() -> AnyView {
        AnyView(HomeView())
    }
}
