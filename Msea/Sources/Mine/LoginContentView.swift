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
    @StateObject private var hud = HUDState()
    @Environment(\.dismiss) private var dismiss
    @State private var loginField: LoginField = .username
    @State private var loginQuestion: LoginQuestion = .no

    @State private var username = ""
    @State private var password = ""
    @State private var answer = ""
    @State private var action = ""
    @State private var formhash = ""
    @State private var isShowing = false
    @State private var webURLItem: WebURLItem?

    var body: some View {
        VStack(alignment: .center) {
            HStack {
                Menu {
                    ForEach(LoginField.allCases) { item in
                        Button {
                            username = ""
                            loginField = item
                        } label: {
                            Label(item.title, systemImage: item.icon)
                        }
                    }
                } label: {
                    HStack {
                        Text(loginField.title)

                        Image(systemName: "arrowtriangle.down.fill")
                            .resizable()
                            .frame(width: 8, height: 8)
                            .padding(.leading, -5)
                    }
                }

                Spacer()
            }
            .frame(width: 300)
            .padding(.bottom, -5)

            TextField(loginField.placeholder, text: $username)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.emailAddress)
                .frame(width: 300, height: 40)

            SecureField("输入密码", text: $password)
                .textFieldStyle(.roundedBorder)
                .frame(width: 300, height: 40)

            HStack {
                Text("安全提问:")

                Menu {
                    ForEach(LoginQuestion.allCases) { item in
                        Button {
                            if item == .no {
                                answer = ""
                            }
                            loginQuestion = item
                        } label: {
                            Label(item.title, systemImage: item.icon)
                        }
                    }
                } label: {
                    HStack {
                        Text(loginQuestion.title)

                        Image(systemName: "arrowtriangle.down.fill")
                            .resizable()
                            .frame(width: 8, height: 8)
                            .padding(.leading, -5)
                    }
                    .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
                    .overlay(
                        RoundedRectangle(cornerRadius: 3)
                            .stroke(Color.theme, lineWidth: 1)
                    )
                }

                Spacer()
            }
            .frame(width: 300)

            if loginQuestion != .no {
                TextField("输入答案", text: $answer)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 300, height: 40)
            }

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
        .hud(isPresented: $hud.isPresented) {
            Text(hud.message)
        }
        .sheet(item: $webURLItem, content: { item in
            Safari(url: URL(string: item.url))
        })
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
                let form = html.at_xpath("//form[@name='login']/@action")
                if let url = form?.text {
                    action = url
                }
                let value = html.at_xpath("//input[@name='formhash']/@value")
                if let hash = value?.text {
                    formhash = hash
                }
            }
        }
    }

    private func login() async {
        Task {
            if username.isEmpty || password.isEmpty {
                hud.show(message: "请输入用户名｜邮箱或者密码")
                return
            }

            if loginQuestion != .no && answer.isEmpty {
                hud.show(message: "请输入安全提问的答案")
                return
            }

            isShowing = true
            // swiftlint:disable force_unwrapping
            var parames = "&formhash=\(formhash)&loginfield=\(loginField.id)&username=\(username)&questionid=\(loginQuestion.qid)&answer=\(answer)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            parames += "&password=\(password.encodeURIComponent())"
            let url = URL(string: "\(kAppBaseURL)\(action)\(parames)")!
            print(url.absoluteString)
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            let (data, _) = try await URLSession.shared.data(for: request)
            isShowing = false
            if let html = try? HTML(html: data, encoding: .utf8) {
                let messagetext = html.at_xpath("//div[@class='alert_error']/p")
                let info = html.at_xpath("//div[@class='info']/li")
                let myinfo = html.at_xpath("//div[@id='myinfo']/p")
                if let message = messagetext?.text {
                    hud.show(message: message)
                } else if let message = info?.text {
                    hud.show(message: message)
                } else if let message = myinfo?.text, !message.isEmpty {
                    let usergroup = myinfo?.at_xpath("//a[@id='g_upmine']")
                    let blank = myinfo?.at_xpath("//a[@target='_blank']")
                    let href = myinfo?.at_xpath("//a[@target='_blank']/@href")
                    let img = html.at_xpath("//div[@id='um']//img/@src")
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

enum LoginField: String, CaseIterable, Identifiable {
    case username
    case email

    var id: String { self.rawValue }

    var icon: String {
        switch self {
        case .username:
            return "person.circle"
        case .email:
            return "envelope"
        }
    }

    var title: String {
        switch self {
        case .username:
            return "用户名"
        case .email:
            return "邮箱"
        }
    }

    var placeholder: String {
        switch self {
        case .username:
            return "输入用户名"
        case .email:
            return "输入邮箱"
        }
    }
}

enum LoginQuestion: String, CaseIterable, Identifiable {
    case no
    case mothername
    case grandpaname
    case fatherborncity
    case oneteachername
    case computermodel
    case favoriterestaurantname
    case lastfourdigitsofdriverlicense

    var id: String { self.rawValue }

    var qid: String {
        switch self {
        case .no:
            return "0"
        case .mothername:
            return "1"
        case .grandpaname:
            return "2"
        case .fatherborncity:
            return "3"
        case .oneteachername:
            return "4"
        case .computermodel:
            return "5"
        case .favoriterestaurantname:
            return "6"
        case .lastfourdigitsofdriverlicense:
            return "7"
        }
    }

    var icon: String {
        switch self {
        case .no:
            return "eye.slash"
        case .mothername:
            return "person.crop.square"
        case .grandpaname:
            return "person.crop.circle"
        case .fatherborncity:
            return "building.2"
        case .oneteachername:
            return "graduationcap"
        case .computermodel:
            return "desktopcomputer"
        case .favoriterestaurantname:
            return "fork.knife"
        case .lastfourdigitsofdriverlicense:
            return "123.rectangle"
        }
    }

    var title: String {
        switch self {
        case .no:
            return "未设置请忽略"
        case .mothername:
            return "母亲的名字"
        case .grandpaname:
            return "爷爷的名字"
        case .fatherborncity:
            return "父亲出生的城市"
        case .oneteachername:
            return "您其中一位老师的名字"
        case .computermodel:
            return "您个人计算机的型号"
        case .favoriterestaurantname:
            return "您最喜欢的餐馆名称"
        case .lastfourdigitsofdriverlicense:
            return "驾驶执照最后四位数字"
        }
    }
}
