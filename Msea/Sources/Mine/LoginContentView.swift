//
//  LoginContentView.swift
//  Msea
//
//  Created by tzqiang on 2021/12/8.
//  Copyright © 2021 eternal.just. All rights reserved.
//

import SwiftUI
import Kanna

struct LoginContentView: View {
    @EnvironmentObject private var hud: HUDState
    @EnvironmentObject var sceneDelegate: FSSceneDelegate

    @State private var username = ""
    @State private var password = ""
    @State private var formhash = ""
    @State private var action = ""
    @State private var referer = ""
    @State private var cookietime = ""

    var body: some View {
        VStack(alignment: .center) {
            TextField("用户名", text: $username)
                .textFieldStyle(.roundedBorder)
                .frame(width: 300, height: 40)

            SecureField("密码", text: $password)
                .textFieldStyle(.roundedBorder)
                .frame(width: 300, height: 40)

            Button("Login") {
                Task {
                    await login()
                }
            }
            .buttonStyle(BigButtonStyle())
            .padding(.top, 10)
        }
        .onAppear {
            sceneDelegate.hudState = hud
        }
        .task {
            await loadData()
        }
    }

    func loadData() async {
        Task {
            // swiftlint:disable force_unwrapping
            let url = URL(string: "\(kAppBaseURL)member.php?mod=logging&action=login")!
            // swiftlint:enble force_unwrapping
            let (data, _) = try await URLSession.shared.data(from: url)
            if let html = try? HTML(html: data, encoding: .utf8) {
                let value = html.at_xpath("//input[@name='formhash']/@value", namespaces: nil)
                if let hash = value?.text {
                    formhash = hash
                    print(formhash)
                }
                let value1 = html.at_xpath("//input[@name='referer']/@value", namespaces: nil)
                if let url = value1?.text {
                    referer = url
                    print(referer)
                }
                let value2 = html.at_xpath("//input[@name='cookietime']/@value", namespaces: nil)
                if let time = value2?.text {
                    cookietime = time
                    print(cookietime)
                }
                let form = html.at_xpath("//form[@name='login']/@action", namespaces: nil)
                if let url = form?.text {
                    action = url
                    print(action)
                }
            }
        }
    }

    func login() async {
        Task {
            // swiftlint:disable force_unwrapping
            let url = URL(string: "\(kAppBaseURL)\(action)")!
            // swiftlint:enble force_unwrapping
            let parameters = [
                "username": username,
                "password": password,
                "formhash": formhash,
                "referer": referer,
                "cookietime": cookietime,
                "loginfield": "email",
                "questionid": "0",
                "answer": ""
            ]
//            var urlComponents: URLComponents {
//                var urlComponents = URLComponents()
//                urlComponents.scheme = "https"
//                urlComponents.host = "www.chongbuluo.com"
//                urlComponents.path = "/member.php"
//                urlComponents.queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
//                return urlComponents
//            }
//            var requst = URLRequest(url: urlComponents.url ?? url)
            print(url.absoluteString)
            var requst = URLRequest(url: url)
            let body = try JSONSerialization.data(withJSONObject: parameters, options: [.fragmentsAllowed] )
            requst.httpBody = body
            requst.httpMethod = "POST"
            requst.addValue(UserAgentType.mac.description, forHTTPHeaderField: HTTPHeaderField.userAgent.description)
            let (data, _) = try await URLSession.shared.data(for: requst)
            if let html = try? HTML(html: data, encoding: .utf8) {
                print(html.toHTML)
                let messagetext = html.at_xpath("//div[@class='alert_error']/p", namespaces: nil)
                let info = html.at_xpath("//div[@class='info']/li", namespaces: nil)
                if let message = messagetext?.text {
                    hud.show(message: message)
                } else if let message = info?.text {
                    hud.show(message: message)
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
