//
//  DaySignContentView.swift
//  Msea
//
//  Created by tzqiang on 2021/12/7.
//  Copyright © 2021 eternal.just. All rights reserved.
//

import SwiftUI
import Kanna

/// 每日签到
struct DaySignContentView: View {
    @State private var showAlert = false
    @State private var selectedSignTab = SignTab.daysign
    @State private var daySign = DaySignModel()
    @State private var isHidden = false
    @State private var signText = "今日未签到，点击签到"
    @State private var isSign = false
    @State private var isPresented = false
    @State private var signMessage = ""
    @State private var signPlaceholder = CacheInfo.shared.signPlaceholder
    @FocusState private var focused: Bool
    @State private var isShowing = false
    @State private var needLogin = false
    @EnvironmentObject private var hud: HUDState

    var body: some View {
        ZStack {
            VStack {
                Button(signText) {
                    if signText.contains("登录") {
                        needLogin.toggle()
                    } else {
                        focused = true
                        isPresented.toggle()
                    }
                }
                .foregroundColor(.white)
                .frame(height: 40)
                .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                .background(isSign ? Color.backGround : Color.secondaryTheme)
                .cornerRadius(5)
                .disabled(isSign)

                HStack(spacing: 50) {
                    VStack {
                        Text("连续签到")

                        Text("\(daySign.days)天")
                    }

                    Button {
                        showAlert = true
                    } label: {
                        Image(systemName: "questionmark.circle")
                    }
                    .alert("每日福利规则", isPresented: $showAlert) {
                    } message: {
                        Text(CacheInfo.shared.signRule)
                            .font(.callout)
                    }

                    VStack {
                        Text("累计获得")

                        Text("\(daySign.bits)Bit")
                    }
                }
                .padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))

                HStack {
                    Label("\(daySign.today)", systemImage: "leaf.fill")
                        .foregroundColor(.theme)
                        .font(.font14)

                    Label("\(daySign.yesterday)", systemImage: "leaf.fill")
                        .foregroundColor(.secondaryTheme)
                        .font(.font14)
                }

                HStack(alignment: .center, spacing: 20) {
                    Label("\(daySign.month)", systemImage: "checkmark.circle")
                        .foregroundColor(.secondaryTheme)
                        .font(.font14)

                    Label("\(daySign.total)", systemImage: "text.badge.checkmark")
                        .foregroundColor(.theme)
                        .font(.font14)
                }

                Picker("SignTab", selection: $selectedSignTab) {
                    ForEach(SignTab.allCases) { view in
                        Text(view.title)
                            .tag(view)
                    }
                }
                .pickerStyle(.segmented)
                .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))

                TabView(selection: $selectedSignTab) {
                    ForEach(SignTab.allCases) { sign in
                        switch sign {
                        case .daysign:
                            SignListContentView()
                                .tag(sign)
                        case .totaldays, .totalreward:
                            SignDayListContentView(signTab: sign)
                                .tag(sign)
                        }
                    }
                }
                .tabViewStyle(.page)
                .indexViewStyle(.page(backgroundDisplayMode: .never))

                Spacer()
            }
            .navigationTitle("签到")
            .task {
                if !isHidden {
                    await loadData()
                }
            }

            ProgressView()
                .isHidden(isHidden)
        }
        .dialog(isPresented: $isPresented) {
            VStack {
                HStack {
                    Text(CacheInfo.shared.signExpression)
                        .multilineTextAlignment(.leading)
                        .font(.font14)

                    Spacer()

                    Button {
                        withAnimation {
                            focused = false
                            isPresented.toggle()
                        }
                    } label: {
                        Image(systemName: "xmark.circle")
                    }
                }

                ZStack {
                    TextEditor(text: $signMessage)
                        .multilineTextAlignment(.leading)
                        .font(.font12)
                        .focused($focused)
                        .onChange(of: signMessage) { newValue in
                            print(newValue)
                        }

                    if self.signMessage.isEmpty {
                        Text(signPlaceholder)
                            .multilineTextAlignment(.leading)
                            .font(.font12)
                            .padding(.top, -10)
                    }
                }

                Button(isShowing ? " " : "发表签到", action: {
                    Task {
                        await sign()
                    }
                })
                    .showProgress(isShowing: $isShowing, color: .white)
                    .disabled(isShowing)
                    .buttonStyle(BigButtonStyle())
                    .padding(EdgeInsets(top: 20, leading: 0, bottom: 10, trailing: 0))
            }
            .frame(width: 300, height: 160)
        }
        .sheet(isPresented: $needLogin) {
            LoginContentView()
        }
        .onReceive(NotificationCenter.default.publisher(for: .login, object: nil)) { _ in
            Task {
                await loadData()
            }
        }
    }

    private func loadData() async {
        Task {
            // swiftlint:disable force_unwrapping
            let url = URL(string: "https://www.chongbuluo.com/plugin.php?id=wq_sign")!
            // swiftlint:enble force_unwrapping
            var requset = URLRequest(url: url)
            requset.configHeaderFields()
            let (data, _) = try await URLSession.shared.data(for: requset)
            if let html = try? HTML(html: data, encoding: .utf8) {
                let node = html.at_xpath("//div[@class='wqpc_sign_info']", namespaces: nil)
                let nums = node?.xpath("//li", namespaces: nil)
                nums?.forEach({ element in
                    if let toHTML = element.toHTML, let text = element.text {
                        if toHTML.contains("today") {
                            daySign.today = text
                        } else if toHTML.contains("yesterday") {
                            daySign.yesterday = text
                        } else if toHTML.contains("month") {
                            daySign.month = text
                        } else if toHTML.contains("total") {
                            daySign.total = text
                        }
                    }
                })

                let continuity = html.xpath("//div[@class='wqpc_sign_continuity']//span", namespaces: nil)
                continuity.forEach { element in
                    if let text = element.text {
                        if let days = Int(text), days != 0 {
                            daySign.days = text
                        } else if text.contains("Bit") {
                            daySign.bits = text.replacingOccurrences(of: "Bit", with: "")
                        }
                    }
                }

                let sign_rule = html.xpath("//div[@class='wqc_sign_rule']/p", namespaces: nil)
                var rules = [String]()
                sign_rule.forEach { element in
                    if let text = element.text {
                        rules.append(text)
                    }
                }
                if !rules.isEmpty {
                    CacheInfo.shared.signRule = rules.joined(separator: "\n")
                }

                let sign = html.at_xpath("//a[@class='wqpc_sign_btn_red']", namespaces: nil)
                let sign_btn = html.at_xpath("//div[@class='wqpc_sign_btna']", namespaces: nil)
                var text_btn = signText
                if let text = sign?.text {
                    text_btn = text
                    isSign = text.contains("已签到")
                } else if let text = sign_btn?.text {
                    text_btn = text
                }
                signText = text_btn.trimmingCharacters(in: .whitespacesAndNewlines)
                isSign = signText.contains("已签到")

                isHidden = true
                let myinfo = html.at_xpath("//div[@id='myinfo']//a[4]/@href", namespaces: nil)
                if let text = myinfo?.text, text.contains("formhash"), text.contains("&") {
                    let components = text.components(separatedBy: "&")
                    if let formhash = components.last, let hash = formhash.components(separatedBy: "=").last {
                        CacheInfo.shared.formhash = hash
                    }
                }
            }

            // swiftlint:disable force_unwrapping
            let url1 = URL(string: "https://www.chongbuluo.com/plugin.php?id=wq_sign&mod=mood&infloat=yes&handlekey=pc_click_wqsign&inajax=1&ajaxtarget=fwin_content_pc_click_wqsign")!
            // swiftlint:enble force_unwrapping
            var requset1 = URLRequest(url: url1)
            requset1.configHeaderFields()
            let (data1, _) = try await URLSession.shared.data(for: requset1)
            if let html1 = try? HTML(html: data1, encoding: .utf8) {
                let sign_expression = html1.at_xpath("//em[@id='return_pc_click_wqsign']", namespaces: nil)
                let wqpc_textarea = html1.at_xpath("//textarea[@class='wqpc_textarea']/@placeholder", namespaces: nil)
                if let expression = sign_expression?.text {
                    CacheInfo.shared.signExpression = expression
                }
                if let placeholder = wqpc_textarea?.text {
                    CacheInfo.shared.signPlaceholder = placeholder
                }
            }
        }
    }

    private func sign() async {
        Task {
            if CacheInfo.shared.formhash.isEmpty {
                needLogin.toggle()
                return
            }

            let message = signMessage.replacingOccurrences(of: " ", with: "")
            // swiftlint:disable force_unwrapping
            let url = URL(string: "https://www.chongbuluo.com/plugin.php?id=wq_sign&mod=mood&infloat=yes&confirmsubmit=yes&handlekey=pc_click_wqsign&imageurl=&message=\(message)&formhash=\(CacheInfo.shared.formhash)")!
            // swiftlint:enble force_unwrapping
            var requset = URLRequest(url: url)
            requset.httpMethod = "POST"
            requset.configHeaderFields()
            let (data, _) = try await URLSession.shared.data(for: requset)
            if let html = try? HTML(html: data, encoding: .utf8) {
                let messagetext = html.at_xpath("//div[@id='messagetext']/p[1]", namespaces: nil)
                let script = html.at_xpath("//div[@id='messagetext']/p[1]/script", namespaces: nil)
                if let message = messagetext?.text {
                    if let text = script?.text, message.contains(text) {
                        hud.show(message: message.replacingOccurrences(of: text, with: ""))
                    } else {
                        hud.show(message: message)
                    }
                }
            }
        }
    }
}

struct DaySignContentView_Previews: PreviewProvider {
    static var previews: some View {
        DaySignContentView()
    }
}

enum SignTab: String, CaseIterable, Identifiable {
    case daysign
    case totaldays
    case totalreward

    var id: String { self.rawValue }
    var title: String {
        switch self {
        case .daysign: return "今日签到列表(Bit)"
        case .totaldays: return "总天数排名(天)"
        case .totalreward: return "总奖励排名(天)"
        }
    }
}

struct DaySignModel {
    var today = "0"
    var yesterday = "0"
    var month = "0"
    var total = "0"
    var days = "0"
    var bits = "0"
}
