//
//  HomeMiddleware.swift
//  Msea
//
//  Created by tzqiang on 2023/4/21.
//  Copyright © 2023 eternal.just. All rights reserved.
//

import Foundation
import Combine
import Kanna

func homeMiddleware() -> Middleware<AppState, AppAction> {
    return { _, action in
        switch action {
        case .home(action: .checkNotice):
            return Network.instance.getRequset(HTMLURL.notice)
                .map {
                    if let notice = $0.at_xpath("//a[@id='myprompt']")?.text, notice.contains("(") {
                        return AppAction.home(action: .updateNotice($0.at_xpath("//a[@id='myprompt']")?.text ?? "1"))
                    } else {
                        return AppAction.home(action: .updateNotice(""))
                    }
                }
                .catch { (error: NetworkError) -> Just<AppAction> in
                    return Just(AppAction.home(action: .loadDataError(error.localizedDescription)))
                }
                .eraseToAnyPublisher()
        default :
            break
        }
        return Empty().eraseToAnyPublisher()
    }
}
