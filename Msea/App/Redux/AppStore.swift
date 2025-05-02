//
//  AppStore.swift
//  Msea
//
//  Created by tzqiang on 2023/4/23.
//  Copyright © 2023 eternal.just. All rights reserved.
//

import Foundation
import Combine

typealias Middleware<State, Action> = (State, Action) -> AnyPublisher<Action, Never>?
typealias AppStore = Store<AppState, AppAction>

@MainActor
final class Store<State, Action>: ObservableObject {
    // Read only access to app state
    @Published private(set) var state: State

    var tasks = [AnyCancellable]()
    private let reducer: Reducer<State, Action>
    let middlewares: [Middleware<State, Action>]
    private var middlewareCancellables: Set<AnyCancellable> = []

    init(state: State,
         reducer: @escaping Reducer<State, Action>,
         middlewares: [Middleware<State, Action>] = []) {
        self.state = state
        self.reducer = reducer
        self.middlewares = middlewares
    }

    // The dispatch function.
    func dispatch(_ action: Action) async {
        reducer(&state, action)

        // Dispatch all middleware functions
        for mw in middlewares {
            guard let middleware = mw(state, action) else {
                break
            }

            for await action in middleware.values {
                await dispatch(action)
            }
        }
    }
}
