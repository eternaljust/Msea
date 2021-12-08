//
//  Networking.swift
//  Msea
//
//  Created by tzqiang on 2021/12/8.
//  Copyright © 2021 eternal.just. All rights reserved.
//

import Foundation

enum HTTPHeaderField: String {
    case accept
    case acceptCharset
    case acceptLanguage
    case cookie
    case userAgent

    var description: String {
        switch self {
        case .accept:
            return "Accept"
        case .acceptCharset:
            return "Accept-Charset"
        case .acceptLanguage:
            return "Accept-Language"
        case .cookie:
            return "Cookie"
        case .userAgent:
            return "User-Agent"
        }
    }
}

enum UserAgentType {
    case iPhone
    case iPad
    case mac

    var description: String {
        switch self {
        case .iPhone:
           return "Mozilla/5.0 (iPhone; CPU iPhone OS 15_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) EdgiOS/96.0.1054.49 Version/15.0 Mobile/15E148 Safari/604.1"
        case .iPad:
           return "Mozilla/5.0 (iPad; CPU OS 15_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) EdgiOS/95.0.1020.60 Version/15.0 Mobile/15E148 Safari/604.1"
        case .mac:
            return "Mozilla/5.0 (Macintosh; Intel Mac OS X 12_0_1) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.1 Safari/605.1.15"
        }
    }
}
