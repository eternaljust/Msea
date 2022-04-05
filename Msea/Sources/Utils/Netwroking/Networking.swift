//
//  Networking.swift
//  Msea
//
//  Created by tzqiang on 2021/12/8.
//  Copyright © 2021 eternal.just. All rights reserved.
//

import Foundation
import Kanna

let kAppBaseURL = "https://www.chongbuluo.com/"

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

extension URLRequest {
    mutating func configHeaderFields() {
        if let cookies = HTTPCookieStorage.shared.cookies {
            self.allHTTPHeaderFields = HTTPCookie.requestHeaderFields(with: cookies)
            if let headerFields = self.allHTTPHeaderFields, let cookie = headerFields["Cookie"] {
                if !cookie.contains("auth") && UserInfo.shared.isLogin() {
                    let authCookie = "\(cookie); \(UserInfo.shared.auth)"
                    setValue(authCookie, forHTTPHeaderField: "Cookie")
                }
            }
        }
        addValue(UserAgentType.mac.description, forHTTPHeaderField: HTTPHeaderField.userAgent.description)
        if let headers = allHTTPHeaderFields, let headerFields = try? JSONEncoder().encode(headers) {
            UserInfo.shared.headerFields = headerFields
        }
    }
}

extension HTMLDocument {
    func getFormhash() {
        let myinfo = self.at_xpath("//div[@id='myinfo']//a[4]/@href")
        if let text = myinfo?.text, text.contains("formhash"), text.contains("&") {
            let components = text.components(separatedBy: "&")
            if let formhash = components.last, let hash = formhash.components(separatedBy: "=").last {
                UserInfo.shared.formhash = hash
            }
        }
        if let formhash = self.at_xpath("//input[@id='formhash']/@value")?.text {
            UserInfo.shared.formhash = formhash
        }
        if let href = self.at_xpath("//div[@id='toptb']//a[6]/@href")?.text, href.contains("formhash") {
            if let hash = href.components(separatedBy: "&").last, hash.contains("=") {
                UserInfo.shared.formhash = hash.components(separatedBy: "=")[1]
            }
        }
    }

    func getProfileUid() -> String {
        var id = ""
        if let src = self.at_xpath("//div[@id='profile_content']//img/@src")?.text, !src.isEmpty {
            id = src
        } else if let src = self.at_xpath("//div[@class='wp cl']//span[@class='xs0 xw0']/a[last()]/@href")?.text {
            id = src
        }
        print(id)
        id = id.replacingOccurrences(of: "&size=middle", with: "")
        id = id.replacingOccurrences(of: "&size=big", with: "")
        id = id.replacingOccurrences(of: "&size=small", with: "")
        id = id.replacingOccurrences(of: "&boan_h5avatar=yes", with: "")
        if id.contains("uid=") {
            return id.components(separatedBy: "uid=")[1]
        }
        return ""
    }
}

extension String {
    func encodeURIComponent() -> String {
        let charactersToEscape = "?!@#$^&%*+,:;='\"`<>()[]{}/\\| "
        let allowedCharacters = NSCharacterSet(charactersIn: charactersToEscape).inverted
        return self.addingPercentEncoding(withAllowedCharacters: allowedCharacters) ?? self
    }
}
