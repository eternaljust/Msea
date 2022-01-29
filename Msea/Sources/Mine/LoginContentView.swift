//
//  LoginContentView.swift
//  Msea
//
//  Created by tzqiang on 2021/12/8.
//  Copyright © 2021 eternal.just. All rights reserved.
//

import SwiftUI
import Kanna

/// 登录界面
struct LoginContentView: View {
    @EnvironmentObject private var hud: HUDState
    @EnvironmentObject var sceneDelegate: FSSceneDelegate
    @Environment(\.dismiss) private var dismiss

    @State private var username = ""
    @State private var password = ""
    @State private var action = ""
    @State private var formhash = ""
    @State private var isShowing = false
    @State private var webURLItem: WebURLItem?

    var body: some View {
        VStack(alignment: .center) {
            TextField("邮箱", text: $username)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.emailAddress)
                .frame(width: 300, height: 40)

            SecureField("密码", text: $password)
                .textFieldStyle(.roundedBorder)
                .frame(width: 300, height: 40)

            Button(isShowing ? " " : "登录", action: {
                Task {
                    await login()
                }
            })
                .showProgress(isShowing: $isShowing, color: .white)
                .disabled(isShowing)
                .buttonStyle(BigButtonStyle())
                .padding(.top, 20)

            Button("注册", action: {
                webURLItem = WebURLItem(url: "https://www.chongbuluo.com/member.php?mod=register")
            })
                .buttonStyle(BigButtonStyle())
                .padding(.top, 20)
        }
        .sheet(item: $webURLItem, content: { item in
            Safari(url: URL(string: item.url))
        })
        .onAppear {
            sceneDelegate.hudState = hud
        }
        .task {
            await loadData()
        }
    }

    private func loadData() async {
        Task {
            // swiftlint:disable force_unwrapping
            let url = URL(string: "\(kAppBaseURL)member.php?mod=logging&action=login")!
            // swiftlint:enble force_unwrapping
            let (data, _) = try await URLSession.shared.data(from: url)
            if let html = try? HTML(html: data, encoding: .utf8) {
                let form = html.at_xpath("//form[@name='login']/@action", namespaces: nil)
                if let url = form?.text {
                    action = url
                }
                let value = html.at_xpath("//input[@name='formhash']/@value", namespaces: nil)
                if let hash = value?.text {
                    formhash = hash
                }
            }
        }
    }

    private func login() async {
        Task {
            if username.isEmpty || password.isEmpty {
                hud.show(message: "请输入邮箱或者密码")
                return
            }

            isShowing = true
            // swiftlint:disable force_unwrapping
            let parames = "&formhash=\(formhash)&loginfield=email&username=\(username)&password=\(password)&questionid=0&answer=".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            let url = URL(string: "\(kAppBaseURL)\(action)\(parames)")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            let (data, _) = try await URLSession.shared.data(for: request)
            isShowing = false
            if let html = try? HTML(html: data, encoding: .utf8) {
                let messagetext = html.at_xpath("//div[@class='alert_error']/p", namespaces: nil)
                let info = html.at_xpath("//div[@class='info']/li", namespaces: nil)
                let myinfo = html.at_xpath("//div[@id='myinfo']/p", namespaces: nil)
                if let message = messagetext?.text {
                    hud.show(message: message)
                } else if let message = info?.text {
                    hud.show(message: message)
                } else if let message = myinfo?.text, !message.isEmpty {
                    let usergroup = myinfo?.at_xpath("//a[@id='g_upmine']", namespaces: nil)
                    let blank = myinfo?.at_xpath("//a[@target='_blank']", namespaces: nil)
                    let href = myinfo?.at_xpath("//a[@target='_blank']/@href", namespaces: nil)
                    let img = html.at_xpath("//div[@id='um']//img/@src", namespaces: nil)
                    if let space = href?.text {
                        UserInfo.shared.space = space
                        let params = space.components(separatedBy: "&")
                        if let last = params.last, last.contains("uid") {
                            let uid = last.components(separatedBy: "=")[1]
                            UserInfo.shared.uid = uid
                        }
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
                    NotificationCenter.default.post(name: .login, object: nil, userInfo: nil)
                    hud.show(message: "欢迎您回来，\(UserInfo.shared.level) \(UserInfo.shared.name)")
                    html.getFormhash()
                    dismiss()
                }
            }
            if let cookies = HTTPCookieStorage.shared.cookies {
                print(cookies)
                for cookie in cookies {
                    if cookie.name.contains("auth") {
                        let auth = "\(cookie.name)=\(cookie.value);"
                        UserInfo.shared.auth = auth
                        print(auth)
                    }
                }
            }
        }
    }
}

struct LoginContentView_Previews: PreviewProvider {
    static var previews: some View {
        LoginContentView()
    }
}
