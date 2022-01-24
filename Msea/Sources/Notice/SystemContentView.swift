//
//  SystemContentView.swift
//  Msea
//
//  Created by tzqiang on 2022/1/24.
//  Copyright © 2022 eternal.just. All rights reserved.
//

import SwiftUI
import Kanna

struct SystemContentView: View {
    @State private var page = 1
    @State private var systemList = [SystemListModel]()
    @State private var isHidden = false

    var body: some View {
        ZStack {
            if systemList.isEmpty {
                Text("暂时没有提醒内容")
            } else {
                List(systemList) { system in
                    HStack(alignment: .top) {
                        Image(systemName: "note.text")
                            .imageScale(.large)
                            .frame(width: 40, height: 40)

                        VStack(alignment: .leading) {
                            Text(system.time)
                                .font(.footnote)
                                .padding(.bottom, 1)

                            Text(system.content)
                                .font(.font14)
                                .fixedSize(horizontal: false, vertical: true)
                                .onAppear {
                                    if system.id == systemList.last?.id {
                                        page += 1
                                        Task {
                                            await loadData()
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
            }

            ProgressView()
                .isHidden(isHidden)
        }
        .navigationTitle("系统提醒")
        .task {
            if !isHidden {
                await loadData()
            }
        }
    }

    private func loadData() async {
        Task {
            // swiftlint:disable force_unwrapping
            let url = URL(string: "https://www.chongbuluo.com/home.php?mod=space&do=notice&view=system&page=\(page)")!
            // swiftlint:enble force_unwrapping
            var request = URLRequest(url: url)
            request.configHeaderFields()
            request.addValue(UserAgentType.mac.description, forHTTPHeaderField: HTTPHeaderField.userAgent.description)
            let (data, _) = try await URLSession.shared.data(for: request)
            if let html = try? HTML(html: data, encoding: .utf8) {
                let dl = html.xpath("//div[@class='nts']/dl", namespaces: nil)
                var list = [SystemListModel]()
                dl.forEach({ element in
                    var system = SystemListModel()
                    if let time = element.at_xpath("//span[@class='xg1 xw0']", namespaces: nil)?.text {
                        system.time = time
                    }
                    if var content = element.at_xpath("//dd[@class='ntc_body']", namespaces: nil)?.text {
                        if let i = content.firstIndex(of: "\r\n") {
                            content.remove(at: i)
                        }
                        system.content = content
                    }
                    list.append(system)
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

struct SystemContentView_Previews: PreviewProvider {
    static var previews: some View {
        SystemContentView()
    }
}

struct SystemListModel: Identifiable {
    var id = UUID()
    var time = ""
    var content = ""
}
