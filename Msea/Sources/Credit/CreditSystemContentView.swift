//
//  CreditSystemContentView.swift
//  Msea
//
//  Created by tzqiang on 2022/1/25.
//  Copyright © 2022 eternal.just. All rights reserved.
//

import SwiftUI
import Kanna

/// 系统奖励
struct CreditSystemContentView: View {
    @State private var page = 1
    @State private var systemList = [CreditSystemListModel]()
    @State private var isHidden = false
    @EnvironmentObject private var rule: CreditRuleObject
    @Binding var selectedCreditTab: MyCreditTab

    var body: some View {
        ZStack {
            if systemList.isEmpty {
                Text("暂时没有系统奖励")
            } else {
                List {
                    Section {
                        ForEach(systemList) { system in
                            HStack {
                                Text(system.action)
                                    .frame(minWidth: 65)

                                Text(system.count)
                                    .frame(minWidth: 45)

                                Text(system.cycles)
                                    .frame(width: 60)

                                Text(system.bit)
                                    .frame(width: 40)

                                Spacer()

                                Text(system.violation)

                                Spacer()

                                Text(system.time)
                                    .frame(width: 70)
                                    .font(.font15.weight(.thin))
                                    .lineLimit(3)
                                    .multilineTextAlignment(.center)
                                    .onAppear {
                                        if system.id == systemList.last?.id {
                                            page += 1
                                            Task {
                                                await loadData()
                                            }
                                        }
                                    }
                            }
                            .font(.font15)
                            .onTapGesture {
                                rule.rid = system.rid
                                selectedCreditTab = .rule
                            }
                        }
                    } header: {
                        HStack {
                            Text("动作名称")

                            Text("总次数")

                            Text("周期次数")

                            Text("Bit")

                            Spacer()

                            Text("违规")

                            Spacer()

                            Text("最后奖励")
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
        .navigationTitle("系统奖励")
        .task {
            if !isHidden {
                await loadData()
            }
        }
    }

    private func loadData() async {
        Task {
            // swiftlint:disable force_unwrapping
            let url = URL(string: "https://www.chongbuluo.com/home.php?mod=spacecp&ac=credit&op=log&suboperation=creditrulelog&page=\(page)")!
            // swiftlint:enble force_unwrapping
            var request = URLRequest(url: url)
            request.configHeaderFields()
            let (data, _) = try await URLSession.shared.data(for: request)
            if let html = try? HTML(html: data, encoding: .utf8) {
                let dl = html.xpath("//table[@class='dt']/tr", namespaces: nil)
                var list = [CreditSystemListModel]()
                dl.forEach({ element in
                    if let toHTML = element.toHTML, toHTML.contains("td") {
                        var system = CreditSystemListModel()
                        if let action = element.at_xpath("/td[1]/a", namespaces: nil)?.text {
                            system.action = action
                            if let href = element.at_xpath("/td[1]/a/@href", namespaces: nil)?.text, href.contains("rid=") {
                                let rids = href.components(separatedBy: "rid=")
                                if rids.count == 2 {
                                    system.rid = rids[1]
                                }
                            }
                        }
                        if let count = element.at_xpath("/td[2]", namespaces: nil)?.text {
                            system.count = count
                        }
                        if let cycles = element.at_xpath("/td[3]", namespaces: nil)?.text {
                            system.cycles = cycles
                        }
                        if let bit = element.at_xpath("/td[4]", namespaces: nil)?.text {
                            system.bit = bit
                        }
                        if let violation = element.at_xpath("/td[5]", namespaces: nil)?.text {
                            system.violation = violation
                        }
                        if let time = element.at_xpath("/td[6]", namespaces: nil)?.text {
                            system.time = time
                        }

                        list.append(system)
                    }
                })

                if page == 1 {
                    systemList = list
                } else {
                    systemList += list
                }
            }

            isHidden = true
        }
    }
}

struct CreditSystemContentView_Previews: PreviewProvider {
    @State static private var selectedCreditTab = MyCreditTab.system

    static var previews: some View {
        CreditSystemContentView(selectedCreditTab: $selectedCreditTab)
    }
}

struct CreditSystemListModel: Identifiable {
    var id = UUID()
    var rid = ""
    var action = ""
    var count = ""
    var cycles = ""
    var bit = ""
    var violation = ""
    var time = ""
}
