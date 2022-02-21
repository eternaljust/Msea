//
//  CreditRuleContentView.swift
//  Msea
//
//  Created by tzqiang on 2022/1/25.
//  Copyright © 2022 eternal.just. All rights reserved.
//

import SwiftUI
import Kanna

/// 积分规则
struct CreditRuleContentView: View {
    @State private var ruleList = [CreditRuleListModel]()
    @State private var isHidden = false
    @EnvironmentObject private var rule: CreditRuleObject

    var body: some View {
        ZStack {
            if ruleList.isEmpty {
                Text("暂时没有积分规则")
            } else {
                List {
                    Section {
                        ForEach(ruleList) { rule in
                            HStack {
                                Text(rule.action)
                                    .frame(minWidth: 65)

                                Text(rule.cycles)
                                    .frame(minWidth: 60)

                                Text(rule.count)

                                Spacer()

                                Text(rule.bit)
                                    .frame(width: 40)

                                Text(rule.violation)
                                    .frame(width: 20)
                            }
                            .font(.font15)
                        }
                    } header: {
                        Text("进行以下事件动作，会得到积分奖励。不过，在一个周期内，您最多得到的奖励次数有限制")
                            .padding(0)

                        HStack {
                            Text("动作名称")

                            Text("周期范围")

                            Text("周期内最多奖励次数")

                            Spacer()

                            Text("Bit")

                            Text("违规")
                        }
                    }
                }
                .listStyle(.plain)
                .refreshable {
                    rule.rid = ""
                    await loadData()
                }
            }

            ProgressView()
                .isHidden(isHidden)
        }
        .navigationTitle("积分规则")
        .task {
            if !isHidden {
                await loadData()
            }
        }
        .onChange(of: rule.rid, perform: { newValue in
            print(newValue)
            Task {
                await loadData()
            }
        })
    }

    private func loadData() async {
        Task {
            // swiftlint:disable force_unwrapping
            let url = URL(string: "https://www.chongbuluo.com/home.php?mod=spacecp&ac=credit&op=rule&rid=\(rule.rid)")!
            // swiftlint:enble force_unwrapping
            var request = URLRequest(url: url)
            request.configHeaderFields()
            let (data, _) = try await URLSession.shared.data(for: request)
            if let html = try? HTML(html: data, encoding: .utf8) {
                let tr = html.xpath("//table[@class='dt valt']/tr")
                var list = [CreditRuleListModel]()
                tr.forEach({ element in
                    if let toHTML = element.toHTML, toHTML.contains("td") {
                        var rule = CreditRuleListModel()
                        if let action = element.at_xpath("/td[1]")?.text {
                            rule.action = action
                        }
                        if let cycles = element.at_xpath("/td[2]")?.text {
                            rule.cycles = cycles
                        }
                        if let count = element.at_xpath("/td[3]")?.text {
                            rule.count = count
                        }
                        if let bit = element.at_xpath("/td[4]")?.text {
                            rule.bit = bit
                        }
                        if let violation = element.at_xpath("/td[5]")?.text {
                            rule.violation = violation
                        }

                        list.append(rule)
                    }
                })

                ruleList = list
            }

            isHidden = true
        }
    }
}

struct CreditRuleContentView_Previews: PreviewProvider {
    static var previews: some View {
        CreditRuleContentView()
    }
}

struct CreditRuleListModel: Identifiable {
    var id = UUID()
    var action = ""
    var count = ""
    var cycles = ""
    var bit = ""
    var violation = ""
}

class CreditRuleObject: ObservableObject {
    @Published var rid = ""
}
