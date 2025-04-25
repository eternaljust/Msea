//
//  LoginViewModel.swift
//  Msea
//
//  Created by taozongqiang on 2025/4/24.
//  Copyright © 2025 eternal.just. All rights reserved.
//

import SwiftUI
import Observation
import Kanna

/// 登录 VM
@Observable
class LoginViewModel: ViewModelState {
    var isToast: Bool = false

    var isLoading: Bool = false

    var toastMessage: String = ""

    /// 用户名
    var username = ""
    /// 密码
    var password = ""
    /// 答案
    var answer = ""
    /// 动作
    var action = ""
    var formhash = ""
    var loginField: LoginField = .username
    var loginQuestion: LoginQuestion = .no

    func loadData() async {
        Task {
            // swiftlint:disable force_unwrapping
            let url = URL(string: "\(kAppBaseURL)/member.php?mod=logging&action=login")!
            // swiftlint:enble force_unwrapping
            let (data, _) = try await URLSession.shared.data(from: url)
            if let html = try? HTML(html: data, encoding: .utf8) {
                let form = html.at_xpath("//form[@name='login']/@action")
                if let url = form?.text {
                    action = url
                    if !action.hasPrefix("/") {
                        action = "/\(action)"
                    }
                }
                let value = html.at_xpath("//input[@name='formhash']/@value")
                if let hash = value?.text {
                    formhash = hash
                }
            }
        }
    }

    func login() async -> Bool {
        if username.isEmpty || password.isEmpty {
            toastMessage = "请输入用户名｜邮箱或者密码"
            isToast = true
            return false
        }

        if loginQuestion != .no && answer.isEmpty {
            toastMessage = "请输入安全提问的答案"
            isToast = true
            return false
        }

        isLoading = true
        // swiftlint:disable force_unwrapping
        var parames = "&formhash=\(formhash)&loginfield=\(loginField.id)&username=\(username)&questionid=\(loginQuestion.qid)&answer=\(self.answer)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        parames += "&password=\(password.encodeURIComponent())"
        let url = URL(string: "\(kAppBaseURL)\(action)\(parames)")!
        print(url.absoluteString)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            if let html = try? HTML(html: data, encoding: .utf8) {
                isLoading = false

                let messagetext = html.at_xpath("//div[@class='alert_error']/p")
                let info = html.at_xpath("//div[@class='info']/li")
                let myinfo = html.at_xpath("//div[@id='myinfo']/p")
                if let message = messagetext?.text {
                    toastMessage = message
                    isToast = true
                    return false
                } else if let message = info?.text {
                    toastMessage = message
                    isToast = true
                    return false
                } else if let message = myinfo?.text, !message.isEmpty {
                    let usergroup = myinfo?.at_xpath("//a[@id='g_upmine']")
                    let blank = myinfo?.at_xpath("//a[@target='_blank']")
                    let href = myinfo?.at_xpath("//a[@target='_blank']/@href")
                    let img = html.at_xpath("//div[@id='um']//img/@src")
                    if let space = href?.text {
                        UserInfo.shared.space = space
                        print("space=", space)
                        let params = space.components(separatedBy: "&")
                        if let last = params.last, last.contains("uid") {
                            UserInfo.shared.uid = last.getUid()
                        }
                        print("uid=", UserInfo.shared.uid)
                    }
                    if let name = blank?.text {
                        UserInfo.shared.name = name
                    }
                    if let level = usergroup?.text {
                        UserInfo.shared.level = level
                    }
                    if let avatar = img?.text {
                        UserInfo.shared.avatar = avatar
                    }
                    let time = Date().timeIntervalSince1970
                    print("cacheTime = \(time)")
                    UserInfo.shared.cacheTime = time
                    NotificationCenter.default.post(name: .login, object: nil, userInfo: nil)
                    toastMessage = "欢迎您回来，\(UserInfo.shared.level) \(UserInfo.shared.name)"
                    isToast = true
                    html.getFormhash()

                    if let cookies = HTTPCookieStorage.shared.cookies {
                        for cookie in cookies where cookie.name.contains("auth") {
                            let auth = "\(cookie.name)=\(cookie.value);"
                            UserInfo.shared.auth = auth
                            print(auth)
                        }
                    }
                    return true
                } else {
                    return false
                }
            } else {
                toastMessage = "网络异常"
                isToast = true
                isLoading = false
                return false
            }
        } catch {
            toastMessage = error.localizedDescription
            return false
        }
    }
}
