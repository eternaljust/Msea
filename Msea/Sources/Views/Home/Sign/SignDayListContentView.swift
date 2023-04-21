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
    @State private var uid = ""
    @State private var isSpace = false

    var body: some View {
        List {
            Section {
                ForEach(signDayList, id: \.id) { sign in
                    ZStack {
                        HStack {
                            Text(sign.no)
                                .font(.font15.weight(.light))
                                .padding(.trailing, 10)

                            Text(sign.name)
                                .font(.font13)
                                .fixedSize(horizontal: false, vertical: true)
                                .multilineTextAlignment(.center)
                                .frame(width: 80)

                            Spacer()

                            Text(sign.continuous)
                                .font(.font13)
                                .padding(.trailing, 13)

                            Text(sign.month)
                                .font(.font13)
                                .padding(.trailing, 13)

                            Text(sign.total)
                                .font(.font13)

                            Spacer()

                            Text(sign.bits)
                                .font(.font13)
                                .foregroundColor(.theme)

                            Text(sign.time)
                                .font(.font13.weight(.thin))
                                .lineLimit(4)
                                .multilineTextAlignment(.center)
                                .minimumScaleFactor(0.5)
                                .onAppear {
                                    if sign.id == signDayList.last?.id {
                                        page += 1
                                        Task {
                                            await loadData()
                                        }
                                    }
                                }
                        }
                        .onTapGesture {
                            if !sign.uid.isEmpty {
                                uid = sign.uid
                                isSpace.toggle()
                            }
                        }

                        NavigationLink(destination: SpaceProfileContentView(uid: uid), isActive: $isSpace) {
                            EmptyView()
                        }
                        .opacity(0.0)
                    }
                }
            } header: {
                SignDayListHeaderView()
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

    private func loadData() async {
        Task {
            // swiftlint:disable force_unwrapping
            let url = URL(string: "https://www.chongbuluo.com/plugin.php?id=wq_sign&mod=info&ac=\(signTab)&page=\(page)")!
            // swiftlint:enble force_unwrapping
            var requst = URLRequest(url: url)
            requst.addValue(UserAgentType.mac.description, forHTTPHeaderField: HTTPHeaderField.userAgent.description)
            let (data, _) = try await URLSession.shared.data(for: requst)
            if let html = try? HTML(html: data, encoding: .utf8) {
                let table = html.at_xpath("//div[@id='sign_one_2']")
                let tr = table?.xpath("//tr")
                var list = [SignDayListModel]()
                tr?.forEach({ element in
                    if let text = element.text, text.contains("NO.") {
                        var signModel = SignDayListModel()
                        let td = element.at_xpath("//td")
                        if let no = td?.text, no.contains("NO.") {
                            signModel.no = no.replacingOccurrences(of: "NO.", with: "")
                        }
                        let a = element.at_xpath("//a")
                        if let name = a?.text {
                            signModel.name = name
                        }
                        let href = element.at_xpath("//a/@href")
                        if let uid = href?.text, uid.contains("uid-") {
                            let uids = uid.components(separatedBy: "uid-")[1]
                            if uids.contains(".html") {
                                signModel.uid = uids.components(separatedBy: ".")[0]
                            }
                        }
                        let td3 = element.at_xpath("//td[3]")
                        if let continuous = td3?.text {
                            signModel.continuous = continuous
                        }
                        let td4 = element.at_xpath("//td[4]")
                        if let month = td4?.text {
                            signModel.month = month
                        }
                        let td5 = element.at_xpath("//td[5]")
                        if let total = td5?.text {
                            signModel.total = total
                        }
                        let span = element.at_xpath("//span[@class='wqpc_red']")
                        if let bits = span?.text {
                            signModel.bits = bits
                        }
                        let td7 = element.at_xpath("//td[7]")
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
