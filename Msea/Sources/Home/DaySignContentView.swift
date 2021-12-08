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

    var body: some View {
        ZStack {
            VStack {
                Button("今日未签到，点击签到") {
                }
                .foregroundColor(.white)
                .frame(width: 200, height: 40)
                .background(Color.secondaryTheme)
                .cornerRadius(5)

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
                        Text("""
                            1. 活动时间：每天00:00开始，23:59结束；
                            2. 每日只能签到一次，签到即获得1 Bit 的奖励；
                            3. 连续签到3天，即第3天额外获得10 Bit 的奖励；
                            4. 连续签到7天，即第7天额外获得30 Bit 的奖励；
                            5. 每日前10名签到者可获得额外1~5 Bit 的随机奖励。
                            """)
                            .font(.callout)
                    }

                    VStack {
                        Text("累计获得")

                        Text("\(daySign.bits)Bit")
                    }
                }

                HStack {
                    Label("\(daySign.today)", systemImage: "leaf.fill")
                        .foregroundColor(.theme)

                    Label("\(daySign.yesterday)", systemImage: "leaf.fill")
                        .foregroundColor(.secondaryTheme)
                }

                HStack(alignment: .center, spacing: 20) {
                    Label("\(daySign.month)", systemImage: "checkmark.circle")
                        .foregroundColor(.secondaryTheme)

                    Label("\(daySign.total)", systemImage: "text.badge.checkmark")
                        .foregroundColor(.theme)
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
    }

    func loadData() async {
        Task {
            // swiftlint:disable force_unwrapping
            let url = URL(string: "https://www.chongbuluo.com/plugin.php?id=wq_sign")!
            // swiftlint:enble force_unwrapping
            let (data, _) = try await URLSession.shared.data(from: url)
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

                let continuity = html.at_xpath("//div[@class='wqpc_sign_continuity']", namespaces: nil)
                let dayNums = continuity?.at_xpath("//li[@class='wqpc_borderright']//span[@class='wqpc_red']", namespaces: nil)
                if let days = dayNums?.text {
                    daySign.days = days
                }
                let bitNums = continuity?.at_xpath("//span[@class='wqpc_red']", namespaces: nil)
                if let bits = bitNums?.text {
                    daySign.bits = bits
                }

                isHidden = true
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
