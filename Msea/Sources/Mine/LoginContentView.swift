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

    var body: some View {
        Button("Login") {
            Task {
                await login()
            }
        }
        .onAppear {
            sceneDelegate.hudState = hud
        }
    }

    func login() async {
        Task {
            // swiftlint:disable force_unwrapping
            let url = URL(string: "https://www.chongbuluo.com/member.php?mod=logging&action=login&loginsubmit=yes&loginhash=LjSUS&username=dd&password=tzq1118")!
            // swiftlint:enble force_unwrapping
            var requst = URLRequest(url: url)
            requst.addValue(UserAgentType.mac.description, forHTTPHeaderField: HTTPHeaderField.userAgent.description)
            let (data, _) = try await URLSession.shared.data(for: requst)
            if let html = try? HTML(html: data, encoding: .utf8) {
                let messagetext = html.at_xpath("//div[@class='alert_error']/p", namespaces: nil)
                if let message = messagetext?.text {
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
