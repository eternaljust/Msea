//
//  CreditListContentView.swift
//  Msea
//
//  Created by tzqiang on 2022/1/25.
//  Copyright © 2022 eternal.just. All rights reserved.
//

import SwiftUI
import Kanna

/// 积分收益
struct CreditListContentView: View {
    @State private var page = 1
    @State private var creditList = [CreditListModel]()
    @State private var isHidden = false

    var body: some View {
        ZStack {
            if creditList.isEmpty {
                Text("暂时没有积分收益")
            } else {
                List {
                    Section {
                        ForEach(creditList) { credit in
                            HStack {
                                Text(credit.action)
                                    .font(.font15)
                                    .frame(minWidth: 60)

                                Text(credit.bit)
                                    .font(.font15)
                                    .foregroundColor(credit.isAdd ? .red : .gray)
                                    .frame(minWidth: 40)

                                Text(credit.content)
                                    .font(.font15)

                                Spacer()

                                Text(credit.time)
                                    .frame(width: 70)
                                    .font(.font15.weight(.thin))
                                    .lineLimit(3)
                                    .multilineTextAlignment(.center)
                                    .onAppear {
                                        if credit.id == creditList.last?.id {
                                            page += 1
                                            Task {
                                                await loadData()
                                            }
                                        }
                                    }
                            }
                        }
                    } header: {
                        VStack(alignment: .leading) {
                            VStack(alignment: .leading) {
                                Text("\(Text("Bit: \(UserInfo.shared.bits)").foregroundColor(.red)) \(Text("违规: \(UserInfo.shared.violation)"))")

                                Text("积分: \(UserInfo.shared.integral) ( 总积分=发帖数 X 0.2 + 精华帖数 X 5 + Bit X 1.5 - 违规 X 10 )")
                            }

                            HStack {
                                Text("操作")
                                    .frame(width: 60)

                                Text("Bit")
                                    .frame(width: 40)

                                Text("详情")

                                Spacer()

                                Text("变更时间")
                            }
                        }
                    }
                }
                .listStyle(.plain)
                .refreshable {
                    page = 1
                    await loadData()
                }
            }

            ProgressView()
                .isHidden(isHidden)
        }
        .navigationTitle("积分收益")
        .task {
            if !isHidden {
                await loadUser()
                await loadData()
            }
        }
    }

    private func loadData() async {
        Task {
            // swiftlint:disable force_unwrapping
            let url = URL(string: "https://www.chongbuluo.com/home.php?mod=spacecp&op=log&ac=credit&page=\(page)")!
            // swiftlint:enble force_unwrapping
            var request = URLRequest(url: url)
            request.configHeaderFields()
            let (data, _) = try await URLSession.shared.data(for: request)
            if let html = try? HTML(html: data, encoding: .utf8) {
                let dl = html.xpath("//table[@class='dt']/tr", namespaces: nil)
                var list = [CreditListModel]()
                dl.forEach({ element in
                    if let toHTML = element.toHTML, toHTML.contains("td") {
                        var system = CreditListModel()
                        if let action = element.at_xpath("/td[1]", namespaces: nil)?.text {
                            system.action = action
                        }
                        if let bit = element.at_xpath("/td[2]/span", namespaces: nil)?.text {
                            system.bit = bit
                            system.isAdd = bit.hasPrefix("+")
                        }
                        if let content = element.at_xpath("/td[3]", namespaces: nil)?.text {
                            system.content = content
                        }
                        if let time = element.at_xpath("/td[4]", namespaces: nil)?.text {
                            system.time = time
                        }

                        list.append(system)
                    }
                })

                if page == 1 {
                    creditList = list
                } else {
                    creditList += list
                }
            }

            isHidden = true
        }
    }

    private func loadUser() async {
        if UserInfo.shared.isLogin() {
            Task {
                // swiftlint:disable force_unwrapping
                let url = URL(string: "https://www.chongbuluo.com/home.php?mod=spacecp&ac=credit")!
                // swiftlint:enble force_unwrapping
                var request = URLRequest(url: url)
                request.configHeaderFields()
                let (data, _) = try await URLSession.shared.data(for: request)
                if let html = try? HTML(html: data, encoding: .utf8) {
                    let li1 = html.at_xpath("//ul[@class='creditl mtm bbda cl']/li[1]", namespaces: nil)
                    if let bits = li1?.text, bits.contains(":") {
                        let bit = bits.replacingOccurrences(of: " ", with: "")
                        UserInfo.shared.bits = bit.components(separatedBy: ":")[1]
                    }
                    let li2 = html.at_xpath("//ul[@class='creditl mtm bbda cl']/li[2]", namespaces: nil)
                    if let violation = li2?.text, violation.contains(":") {
                        let v = violation.replacingOccurrences(of: " ", with: "")
                        UserInfo.shared.violation = v.components(separatedBy: ":")[1]
                    }
                    let li3 = html.at_xpath("//ul[@class='creditl mtm bbda cl']/li[3]", namespaces: nil)
                    if let integral = li3?.text, integral.contains("("), integral.contains(":") {
                        let i = integral.replacingOccurrences(of: " ", with: "")
                        UserInfo.shared.integral = i.components(separatedBy: "(")[0].components(separatedBy: ":")[1]
                    }
                    html.getFormhash()
                }
            }
        }
    }
}

struct CreditListContentView_Previews: PreviewProvider {
    static var previews: some View {
        CreditListContentView()
    }
}

struct CreditListModel: Identifiable {
    var id = UUID()
    var action = ""
    var bit = ""
    var content = ""
    var time = ""
    var isAdd = true
}
