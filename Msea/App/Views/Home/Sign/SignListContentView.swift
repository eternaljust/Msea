//
//  SignListContentView.swift
//  Msea
//
//  Created by tzqiang on 2021/12/7.
//  Copyright © 2021 eternal.just. All rights reserved.
//

import SwiftUI
import Kanna
import IHome

/// 今日签到列表
struct SignListContentView: View {
    @State private var page = 1
    @State private var signList = [SignListModel]()
    @State private var uid = ""
    @State private var isSpace = false

    var body: some View {
        List {
            Section {
                ForEach(signList, id: \.id) { sign in
                    ZStack {
                        HStack {
                            Text(sign.no)
                                .padding(.trailing, 10)
                                .font(.font15.weight(.light))

                            Text(sign.name)
                                .fixedSize(horizontal: false, vertical: true)
                                .font(.font13)
                                .multilineTextAlignment(.center)
                                .frame(width: 60)

                            Spacer()

                            Text(sign.content)
                                .padding(.trailing, 15)
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                                .font(.font13)

                            Spacer()

                            Text(sign.bits)
                                .padding(.trailing, 10)
                                .foregroundColor(.theme)
                                .font(.font15)

                            Text(sign.time)
                                .font(.font15.weight(.thin))
                                .onAppear {
                                    if sign.id == signList.last?.id {
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
                    }
                }
            } header: {
                SignListHeaderView()
            }
        }
        .listStyle(.plain)
        .navigationDestination(isPresented: $isSpace, destination: {
            SpaceProfileContentView(uid: uid)
        })
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
            let url = URL(string: "https://www.chongbuluo.com/plugin.php?id=wq_sign&mod=info&ac=daysign&page=\(page)")!
            // swiftlint:enble force_unwrapping
            var requst = URLRequest(url: url)
            requst.addValue(UserAgentType.mac.description, forHTTPHeaderField: HTTPHeaderField.userAgent.description)
            let (data, _) = try await URLSession.shared.data(for: requst)
            if let html = try? HTML(html: data, encoding: .utf8) {
                let table = html.at_xpath("//div[@class='wqpc_sign_table']")
                let tr = table?.xpath("//tr")
                var list = [SignListModel]()
                tr?.forEach({ element in
                    if let text = element.text, text.contains("NO.") {
                        var signModel = SignListModel()
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
                        let con = element.at_xpath("//p[@class='wqpc_con']")
                        if let content = con?.text {
                            signModel.content = content
                        }
                        let span = element.at_xpath("//span[@class='wqpc_red']")
                        if let bits = span?.text {
                            signModel.bits = bits
                        }
                        let spanTitle = element.at_xpath("//span[@title]")
                        if let time = spanTitle?.text {
                            signModel.time = time.replacingOccurrences(of: " ", with: "")
                        }

                        list.append(signModel)
                    }
                })

                if page == 1 {
                    signList = list
                } else {
                    signList += list
                }
            }
        }
    }
}

struct SignListContentView_Previews: PreviewProvider {
    static var previews: some View {
        SignListContentView()
    }
}

struct SignListHeaderView: View {
    var body: some View {
        HStack {
            Text("排名")
                .padding(.trailing, 10)

            Text("昵称")

            Spacer()

            Text("签到内容")

            Spacer()

            Text("奖励")
                .padding(.trailing, 5)

            Text("签到时间")
        }
    }
}
