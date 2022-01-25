//
//  UserGroupContentView.swift
//  Msea
//
//  Created by tzqiang on 2022/1/25.
//  Copyright © 2022 eternal.just. All rights reserved.
//

import SwiftUI
import Kanna

/// 用户组
struct UserGroupContentView: View {
    @State private var sections = [UserGroupHeaderModel]()
    @State private var isHidden = false

    var body: some View {
        ZStack {
            if sections.isEmpty {
                Text("暂无用户组")
            } else {
                List(sections) { header in
                    Section {
                        ForEach(header.list) { userGroup in
                            HStack {
                                Text(userGroup.title)
                                    .frame(width: 100)

                                Spacer()

                                if userGroup.currentImage.isEmpty {
                                    Text(userGroup.current)
                                        .frame(minWidth: 100)
                                } else {
                                    Image(systemName: userGroup.currentImage)
                                        .foregroundColor(userGroup.currentImage == "checkmark" ? .theme : .red)
                                }

                                Spacer()

                                if userGroup.otherImage.isEmpty {
                                    Text(userGroup.other)
                                        .frame(minWidth: 100)
                                } else {
                                    Image(systemName: userGroup.otherImage)
                                        .foregroundColor(userGroup.otherImage == "checkmark" ? .theme : .red)
                                }

                                Spacer()
                            }
                            .font(.font12)
                        }
                    } header: {
                        HStack {
                            Text(header.title)
                                .frame(width: 100)

                            Spacer()

                            Text(header.current)
                                .frame(minWidth: 100)

                            Spacer()

                            Text(header.other)
                                .frame(minWidth: 100)

                            Spacer()
                        }
                        .frame(height: 40)
                        .font(.font14)
                        .foregroundColor(.white)
                        .background(Color.secondaryTheme)
                    }
                }
                .listStyle(.plain)
                .refreshable {
                    await loadData()
                }
            }

            ProgressView()
                .isHidden(isHidden)
        }
        .navigationBarTitle("用户组")
        .task {
            if !isHidden {
                await loadData()
            }
        }
    }

    private func loadData() async {
        sections = []
        Task {
            // swiftlint:disable force_unwrapping
            let url = URL(string: "https://www.chongbuluo.com/home.php?mod=spacecp&ac=usergroup&gid=")!
            // swiftlint:enble force_unwrapping
            var request = URLRequest(url: url)
            request.configHeaderFields()
            request.addValue(UserAgentType.mac.description, forHTTPHeaderField: HTTPHeaderField.userAgent.description)
            let (data, _) = try await URLSession.shared.data(for: request)
            if let html = try? HTML(html: data, encoding: .utf8) {
                let tdats = html.at_xpath("//div[@class='tdats']", namespaces: nil)
                var firstHeader = UserGroupHeaderModel()
                if let title = tdats?.at_xpath("/table[@class='tdat']//th[@class='c0']", namespaces: nil)?.text {
                    firstHeader.title = title
                }
                if let current = tdats?.at_xpath("/table[@class='tdat tfx']//th[@class='c0']", namespaces: nil)?.text {
                    firstHeader.current = current
                }
                if let other = tdats?.at_xpath("/ul[@class='tb c2']/li[@id='c2']", namespaces: nil)?.text {
                    firstHeader.other = other
                }

                var first = UserGroupListModel()
                if let title = tdats?.at_xpath("/table[@class='tdat']//th[@class='alt']", namespaces: nil)?.text {
                    first.title = title
                }
                if var current = tdats?.at_xpath("/table[@class='tdat tfx']//th[@class='alt']", namespaces: nil)?.text {
                    removeSpace(&current)
                    first.current = current
                }
                if var other = tdats?.at_xpath("/div[@class='tscr']/table[@class='tdat']//th[@class='alt h']", namespaces: nil)?.text {
                    removeSpace(&other)
                    first.other = other
                }
                firstHeader.list.append(first)
                let ca = tdats?.xpath("/table[@class='tdat']/tbody[@class='ca']/tr", namespaces: nil)
                ca?.forEach({ element in
                    var usergroup = UserGroupListModel()
                    if let title = element.at_xpath("/td", namespaces: nil)?.text {
                        usergroup.title = title
                    }
                    firstHeader.list.append(usergroup)
                })
                for index in firstHeader.list.indices where index != 0 && index != 1 {
                    let tr = tdats?.at_xpath("/table[@class='tdat tfx']/tbody[@class='ca']/tr[\(index - 1)]", namespaces: nil)
                    if let img = tr?.at_xpath("/td/img/@alt", namespaces: nil)?.text {
                        firstHeader.list[index].currentImage = img == "data_valid" ? "checkmark" : "xmark"
                    } else if var current = tr?.at_xpath("/td", namespaces: nil)?.text {
                        removeSpace(&current)
                        firstHeader.list[index].current = current
                    }
                    let tr1 = tdats?.at_xpath("/div[@class='tscr']/table[@class='tdat']/tbody[@class='ca']/tr[\(index - 1)]", namespaces: nil)
                    if let img = tr1?.at_xpath("/td/img/@alt", namespaces: nil)?.text {
                        firstHeader.list[index].otherImage = img == "data_valid" ? "checkmark" : "xmark"
                    } else if var other = tr1?.at_xpath("/td", namespaces: nil)?.text {
                        removeSpace(&other)
                        firstHeader.list[index].other = other
                    }
                }

                sections.append(firstHeader)
            }

            isHidden = true
        }
    }

    private func removeSpace(_ text: inout String) {
        if let i = text.firstIndex(of: "\r\n") {
            text.remove(at: i)
        }
        if let i = text.lastIndex(of: "\r\n") {
            text.remove(at: i)
        }
    }
}

struct UserGroupListModel: Identifiable {
    var id = UUID()
    var title = ""
    var current = ""
    var currentImage = ""
    var other = ""
    var otherImage = ""
}

struct UserGroupHeaderModel: Identifiable {
    var id = UUID()
    var title = ""
    var current = ""
    var other = ""

    var list = [UserGroupListModel]()
}
