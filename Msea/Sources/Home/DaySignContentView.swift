//
//  DaySignContentView.swift
//  Msea
//
//  Created by tzqiang on 2021/12/7.
//  Copyright © 2021 eternal.just. All rights reserved.
//

import SwiftUI
import Kanna
import CoreSpotlight

/// 每日签到
struct DaySignContentView: View {
    @State private var showAlert = false
    @State private var showAlertCalendar = false
    @State private var selectedSignTab = SignTab.daysign
    @State private var daySign = DaySignModel()
    @State private var isHidden = false
    @State private var signText = UserInfo.shared.isLogin() ? "今日未签到，点击签到" : "请先登录"
    @State private var isSign = false
    @State private var isPresented = false
    @State private var signMessage = ""
    @State private var signPlaceholder = CacheInfo.shared.signPlaceholder
    @FocusState private var focused: Bool
    @State private var isShowing = false
    @State private var needLogin = false
    @State private var monthTitle = ""
    @State private var calendarList = [CalendarDayModel]()
    @State private var isLogin = UserInfo.shared.isLogin()

    @EnvironmentObject private var hud: HUDState

    var body: some View {
        ZStack {
            VStack {
                Button(signText) {
                    if !UserInfo.shared.isLogin() {
                        needLogin.toggle()
                    } else {
                        focused = true
                        isPresented.toggle()
                    }
                }
                .foregroundColor(isSign ? .secondary : .white)
                .frame(minHeight: 40)
                .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                .background(isSign ? Color.backGround : Color.secondaryTheme)
                .cornerRadius(5)
                .disabled(isSign)

                HStack {
                    Spacer()

                    VStack {
                        Text("连续签到")

                        Text("\(Text(daySign.days).foregroundColor(.theme))天")
                    }

                    Spacer()

                    VStack {
                        Button {
                            showAlert = true
                        } label: {
                            Image(systemName: "questionmark.circle")
                        }
                        .alert("每日福利规则", isPresented: $showAlert) {
                        } message: {
                            Text(CacheInfo.shared.signRule)
                                .font(.font16)
                        }

                        if isLogin {
                            Spacer()

                            Button {
                                showAlertCalendar = true
                            } label: {
                                Image(systemName: "calendar.circle")
                            }
                        }
                    }
                    .frame(height: 40)

                    Spacer()

                    VStack {
                        Text("累计获得")

                        Text("\(daySign.bits)Bit")
                            .foregroundColor(.theme)
                    }

                    Spacer()
                }
                .padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))

                VStack(alignment: .center, spacing: 5) {
                    HStack {
                        Label("\(daySign.today)", systemImage: "leaf.fill")
                            .foregroundColor(.theme)
                            .font(.font15)

                        Label("\(daySign.yesterday)", systemImage: "leaf.fill")
                            .foregroundColor(.secondaryTheme)
                            .font(.font15)
                    }

                    HStack(alignment: .center, spacing: 20) {
                        Label("\(daySign.month)", systemImage: "checkmark.circle")
                            .foregroundColor(.secondaryTheme)
                            .font(.font15)

                        Label("\(daySign.total)", systemImage: "text.badge.checkmark")
                            .foregroundColor(.theme)
                            .font(.font15)
                    }
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
                .tabViewStyle(.page(indexDisplayMode: .never))
                .edgesIgnoringSafeArea(UIDevice.current.isPad ? [] : [.bottom])
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
                        .font(.font17)

                    Spacer()

                    Button {
                        closeDialog()
                    } label: {
                        Image(systemName: "xmark.circle")
                    }
                }

                ZStack {
                    TextEditor(text: $signMessage)
                        .multilineTextAlignment(.leading)
                        .font(.font15)
                        .focused($focused)
                        .onChange(of: signMessage) { newValue in
                            print(newValue)
                        }

                    if self.signMessage.isEmpty {
                        Text(signPlaceholder)
                            .multilineTextAlignment(.leading)
                            .font(.font15)
                            .foregroundColor(.secondary)
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
            .frame(width: 300, height: 200)
        }
        .dialog(isPresented: $showAlertCalendar) {
            VStack(alignment: .center, spacing: 10) {
                HStack {
                    Spacer()

                    Text(monthTitle)
                        .font(.font17)

                    Spacer()

                    Button {
                        showAlertCalendar = false
                    } label: {
                        Image(systemName: "xmark.circle")
                    }
                }

                Spacer()

                LazyVGrid(columns: [GridItem(.fixed(40)), GridItem(.fixed(40)), GridItem(.fixed(40)), GridItem(.fixed(40)), GridItem(.fixed(40)), GridItem(.fixed(40)), GridItem(.fixed(40))]) {
                    ForEach(calendarList) { date in
                        RoundedRectangle(cornerRadius: 5)
                            .frame(height: 40)
                            .foregroundColor(date.isToday ? .theme : Color(light: .white, dark: .black))
                            .overlay(
                                VStack(alignment: .center, spacing: 2) {
                                    Text(date.title)
                                        .foregroundColor(date.isToday ? .white : (date.isWeekend ? Color.theme : Color(light: .black, dark: .white)))

                                    if date.isSign {
                                        Circle()
                                            .frame(width: 5, height: 5)
                                            .foregroundColor(date.isToday ? .white : .theme)
                                    }
                                }
                            )
                    }
                }
            }
            .frame(width: 320, height: calendarList.count == 49 ? 370 : 320)
        }
        .sheet(isPresented: $needLogin) {
            LoginContentView()
        }
        .onAppear {
            if !UIDevice.current.isPad {
                TabBarTool.showTabBar(false)
            }
            isLogin = UserInfo.shared.isLogin()
        }
        .onReceive(NotificationCenter.default.publisher(for: .login, object: nil)) { _ in
            isLogin = true
            reloadData()
        }
        .onReceive(NotificationCenter.default.publisher(for: .logout, object: nil)) { _ in
            isLogin = false
            daySign.days = "0"
            daySign.bits = "0"
            signText = "请先登录"
            isSign = false
        }
        .userActivity(Constants.daysignUserActivityType, { userActivity in
            userActivity.persistentIdentifier = ""
            userActivity.isEligibleForSearch = true
            userActivity.isEligibleForPrediction = true
            userActivity.isEligibleForPublicIndexing = true
            userActivity.title = "虫部落签到"
            userActivity.suggestedInvocationPhrase = "虫部落签到"
            let attributes = CSSearchableItemAttributeSet()
            attributes.contentDescription = "点击打开 Msea，进行每日签到，立即获取虫部落 Bit 奖励！"
            userActivity.contentAttributeSet = attributes
            userActivity.becomeCurrent()
            print("set daysignUserActivity")
        })
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
                let node = html.at_xpath("//div[@class='wqpc_sign_info']")
                let nums = node?.xpath("//li")
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

                let continuity = html.xpath("//div[@class='wqpc_sign_continuity']//span")
                continuity.forEach { element in
                    if let text = element.text {
                        if let days = Int(text), days != 0 {
                            daySign.days = text
                        } else if text.contains("Bit") {
                            daySign.bits = text.replacingOccurrences(of: "Bit", with: "")
                        }
                    }
                }

                let sign_rule = html.xpath("//div[@class='wqc_sign_rule']/p")
                var rules = [String]()
                sign_rule.forEach { element in
                    if let text = element.text {
                        rules.append(text)
                    }
                }
                if !rules.isEmpty {
                    CacheInfo.shared.signRule = rules.joined(separator: "\n")
                }

                let sign = html.at_xpath("//a[@class='wqpc_sign_btn_red']")
                let sign_btn = html.at_xpath("//div[@class='wqpc_sign_btna']")
                var text_btn = signText
                if let text = sign?.text {
                    text_btn = text
                    isSign = text.contains("已签到")
                } else if let text = sign_btn?.text {
                    text_btn = text
                }
                signText = text_btn.trimmingCharacters(in: .whitespacesAndNewlines)
                isSign = signText.contains("已签到")

                let calendar = html.at_xpath("//div[@class='wqpc_sign_btn_calendar']")
                if let title = calendar?.at_xpath("/h3[@class='wqpc_title']")?.text {
                    monthTitle = title
                }
                var list = [CalendarDayModel]()
                let weeks = calendar?.xpath("/ul[@class='wq_week']/li")
                weeks?.forEach { element in
                    var model = CalendarDayModel()
                    if let text = element.text {
                        model.title = text
                    }
                    model.isWeek = true
                    if let text = element.at_xpath("/@style")?.text, !text.isEmpty {
                        model.isWeekend = true
                    }
                    list.append(model)
                }
                let dates = calendar?.xpath("/ul[@class='wq_date']/li")
                dates?.forEach { element in
                    var model = CalendarDayModel()
                    if let text = element.at_xpath("/span")?.text {
                        model.title = text
                    }
                    if let text = element.at_xpath("/span/i/@class")?.text, text == "wqsign_dot_red" || text == "wqsign_dot_white" {
                        model.isSign = true
                    }
                    if let text = element.at_xpath("/span/@class")?.text, text == "wq_sign_today" {
                        model.isToday = true
                    }
                    list.append(model)
                }

                calendarList = list

                isHidden = true
                html.getFormhash()
            }

            // swiftlint:disable force_unwrapping
            let url1 = URL(string: "https://www.chongbuluo.com/plugin.php?id=wq_sign&mod=mood&infloat=yes&handlekey=pc_click_wqsign&inajax=1&ajaxtarget=fwin_content_pc_click_wqsign")!
            // swiftlint:enble force_unwrapping
            var requset1 = URLRequest(url: url1)
            requset1.configHeaderFields()
            let (data1, _) = try await URLSession.shared.data(for: requset1)
            if let html1 = try? HTML(html: data1, encoding: .utf8) {
                let sign_expression = html1.at_xpath("//em[@id='return_pc_click_wqsign']")
                let wqpc_textarea = html1.at_xpath("//textarea[@class='wqpc_textarea']/@placeholder")
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
            if UserInfo.shared.formhash.isEmpty {
                needLogin.toggle()
                return
            }

            // swiftlint:disable force_unwrapping
            let parames = "&formhash=\(UserInfo.shared.formhash)&message=\(signMessage)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            let url = URL(string: "https://www.chongbuluo.com/plugin.php?id=wq_sign&mod=mood&infloat=yes&confirmsubmit=yes&handlekey=pc_click_wqsign&imageurl=\(parames)")!
            // swiftlint:enble force_unwrapping
            var requset = URLRequest(url: url)
            requset.httpMethod = "POST"
            requset.configHeaderFields()
            let (data, _) = try await URLSession.shared.data(for: requset)
            if let html = try? HTML(html: data, encoding: .utf8) {
                let messagetext = html.at_xpath("//div[@id='messagetext']/p[1]")
                let script = html.at_xpath("//div[@id='messagetext']/p[1]/script")
                if let message = messagetext?.text {
                    if let text = script?.text, message.contains(text) {
                        hud.show(message: message.replacingOccurrences(of: text, with: ""))
                    } else {
                        hud.show(message: message)
                    }
                }
                closeDialog()
                await loadData()
            }
        }
    }

    private func closeDialog() {
        withAnimation {
            focused = false
            isPresented.toggle()
        }
    }

    private func reloadData() {
        Task {
            await loadData()
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
    var today = "今日已签到 0 人"
    var yesterday = "昨日总签到 0 人"
    var month = "本月总签到 0 人"
    var total = "已有 0 人参与"
    var days = "0"
    var bits = "0"
}

struct CalendarDayModel: Identifiable {
    var id = UUID()

    var title = ""
    var isWeek = false
    var isWeekend = false
    var isSign = false
    var isToday = false
}
