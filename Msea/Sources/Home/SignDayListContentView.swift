//
//  SignDayListContentView.swift
//  Msea
//
//  Created by tzqiang on 2021/12/7.
//  Copyright © 2021 eternal.just. All rights reserved.
//

import SwiftUI
import Kanna

/// 签到天数排名列表
struct SignDayListContentView: View {
    var signTab = SignTab.totaldays

    @State private var page = 1
    @State private var signDayList = [SignDayListModel]()

    var body: some View {
        List {
            Section(header: SignDayListHeaderView()) {
                ForEach(signDayList, id: \.id) { sign in
                    HStack {
                        Text(sign.no)
                            .font(.font14.weight(.light))
                            .padding(.trailing, 10)

                        Text(sign.name)
                            .font(.font12)
                            .fixedSize(horizontal: false, vertical: true)
                            .multilineTextAlignment(.center)
                            .frame(width: 80)

                        Spacer()

                        Text(sign.continuous)
                            .font(.font12)
                            .padding(.trailing, 13)

                        Text(sign.month)
                            .font(.font12)
                            .padding(.trailing, 13)

                        Text(sign.total)
                            .font(.font12)

                        Spacer()

                        Text(sign.bits)
                            .font(.font12)
                            .foregroundColor(.theme)

                        Text(sign.time)
                            .font(.font12.weight(.thin))
                            .lineLimit(2)
                            .multilineTextAlignment(.center)
                            .onAppear {
                                if sign.id == signDayList.last?.id {
                                    print("scroll bottom")
                                    page += 1
                                    Task {
                                        await loadData()
                                    }
                                }
                            }
                    }
                }
            }
        }
        .listStyle(.plain)
        .refreshable {
            page = 1
            await loadData()
        }
        .task {
            await loadData()
        }
    }

    func loadData() async {
        Task {
            // swiftlint:disable force_unwrapping
            let url = URL(string: "https://www.chongbuluo.com/plugin.php?id=wq_sign&mod=info&ac=\(signTab)&page=\(page)")!
            // swiftlint:enble force_unwrapping
            var requst = URLRequest(url: url)
            requst.addValue(UserAgentType.mac.description, forHTTPHeaderField: HTTPHeaderField.userAgent.description)
            let (data, _) = try await URLSession.shared.data(for: requst)
            if let html = try? HTML(html: data, encoding: .utf8) {
                let table = html.at_xpath("//div[@id='sign_one_2']", namespaces: nil)
                let tr = table?.xpath("//tr", namespaces: nil)
                var list = [SignDayListModel]()
                tr?.forEach({ element in
                    if let text = element.text, text.contains("NO.") {
                        var signModel = SignDayListModel()
                        let td = element.at_xpath("//td", namespaces: nil)
                        if let no = td?.text, no.contains("NO.") {
                            signModel.no = no.replacingOccurrences(of: "NO.", with: "")
                        }
                        let a = element.at_xpath("//a", namespaces: nil)
                        if let name = a?.text {
                            signModel.name = name
                        }
                        let href = element.at_xpath("//a/@href", namespaces: nil)
                        if let uid = href?.text {
                            signModel.uid = uid
                        }
                        let td3 = element.at_xpath("//td[3]", namespaces: nil)
                        if let continuous = td3?.text {
                            signModel.continuous = continuous
                        }
                        let td4 = element.at_xpath("//td[4]", namespaces: nil)
                        if let month = td4?.text {
                            signModel.month = month
                        }
                        let td5 = element.at_xpath("//td[5]", namespaces: nil)
                        if let total = td5?.text {
                            signModel.total = total
                        }
                        let span = element.at_xpath("//span[@class='wqpc_red']", namespaces: nil)
                        if let bits = span?.text {
                            signModel.bits = bits
                        }
                        let td7 = element.at_xpath("//td[7]", namespaces: nil)
                        if let time = td7?.text {
                            signModel.time = time.replacingOccurrences(of: " ", with: "\n")
                        }

                        list.append(signModel)
                    }
                })

                if page == 1 {
                    signDayList = list
                } else {
                    signDayList += list
                }
            }
        }
    }
}

struct SignDayListContentView_Previews: PreviewProvider {
    static var previews: some View {
        SignDayListContentView()
    }
}

struct SignDayListHeaderView: View {
    var body: some View {
        HStack {
            Text("排名")
                .padding(.trailing, 15)

            Text("昵称")

            Spacer()

            Text("连续")
                .padding(.zero)

            Text("本月")
                .padding(.zero)

            Text("总")

            Spacer()

            Text("总奖励")

            Text("上次签到")
        }
    }
}

struct SignDayListModel: Identifiable {
    var id = UUID()
    var uid = ""
    var no = "''"
    var name = ""
    var time = ""
    var bits = ""
    var continuous = ""
    var month = ""
    var total = ""
}
