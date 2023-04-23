//
//  HomeMiddleware.swift
//  Msea
//
//  Created by tzqiang on 2023/4/21.
//  Copyright © 2023 eternal.just. All rights reserved.
//

import Foundation
import Combine

func homeMiddleware() -> Middleware<AppState, AppAction> {
    return { _, action in
        switch action {
        case .home(action: .navigationBarHidden):
            break
        }
        return Empty().eraseToAnyPublisher()
    }
}
