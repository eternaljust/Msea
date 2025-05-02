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
    @State private var gid = ""

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
                                    .frame(width: 80)

                                Spacer()

                                if userGroup.currentImage.isEmpty {
                                    Text(userGroup.current)
                                        .frame(minWidth: 100)
                                } else {
                                    Image(systemName: userGroup.currentImage)
                                        .foregroundColor(userGroup.currentImage == "checkmark" ? .theme : .red)
                                        .frame(minWidth: 100)
                                }

                                Spacer()

                                if userGroup.otherImage.isEmpty {
                                    Text(userGroup.other)
                                        .frame(minWidth: 100)
                                } else {
                                    Image(systemName: userGroup.otherImage)
                                        .foregroundColor(userGroup.otherImage == "checkmark" ? .theme : .red)
                                        .frame(minWidth: 100)
                                }

                                Spacer()
                            }
                            .font(.font16)
                            .multilineTextAlignment(.center)
                        }
                    } header: {
                        HStack {
                            Text(header.title)
                                .frame(width: 80)

                            Spacer()

                            Text(header.current)
                                .frame(minWidth: 100)

                            Spacer()

                            Text(header.other)
                                .frame(minWidth: 100)

                            Spacer()
                        }
                        .frame(minHeight: 40)
                        .font(.font16)
                        .foregroundColor(.white)
                        .background(Color.secondaryTheme)
                        .multilineTextAlignment(.center)
                    } footer: {
                        if header.id == sections.last?.id {
                            HStack {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.theme)

                                Text("表示有权操作")

                                Image(systemName: "xmark")
                                    .foregroundColor(.red)

                                Text("表示无权操作")
                            }
                            .font(.font16)
                            .frame(minHeight: 30)
                        }
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
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    ForEach(UserGroupMenu.allCases) { menu in
                        Menu(menu.title) {
                            ForEach(menu.items) { item in
                                Button {
                                    Task {
                                        gid = item.gid
                                        await loadData()
                                    }
                                } label: {
                                    Text(item.title)
                                }
                            }
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis")
                }
            }
        }
        .task {
            if !isHidden {
                await loadData()
            }
        }
        .onAppear {
            if !UIDevice.current.isPad {
                TabBarTool.showTabBar(false)
            }
        }
    }

    private func loadData() async {
        Task {
            // swiftlint:disable force_unwrapping
            let url = URL(string: "https://www.chongbuluo.com/home.php?mod=spacecp&ac=usergroup&gid=\(gid)")!
            // swiftlint:enble force_unwrapping
            var request = URLRequest(url: url)
            request.configHeaderFields()
            let (data, _) = try await URLSession.shared.data(for: request)
            if let html = try? HTML(html: data, encoding: .utf8) {
                sections = []

                let tdats = html.at_xpath("//div[@class='tdats']")
                var firstHeader = UserGroupHeaderModel()
                if let title = tdats?.at_xpath("/table[@class='tdat']//th[@class='c0']")?.text {
                    firstHeader.title = title
                }
                if let current = tdats?.at_xpath("/table[@class='tdat tfx']//th[@class='c0']")?.text {
                    firstHeader.current = current
                }
                if let other = tdats?.at_xpath("/ul[@class='tb c1']/li[@id='c1']")?.text {
                    firstHeader.other = other
                }
                if firstHeader.other.isEmpty, let other = tdats?.at_xpath("/ul[@class='tb c2']/li[@id='c2']")?.text {
                    firstHeader.other = other
                }
                if firstHeader.other.isEmpty, let other = tdats?.at_xpath("/ul[@class='tb c3']/li[@id='c3']")?.text {
                    firstHeader.other = other
                }

                var first = UserGroupListModel()
                if let title = tdats?.at_xpath("/table[@class='tdat']//th[@class='alt']")?.text {
                    first.title = title
                }
                if var current = tdats?.at_xpath("/table[@class='tdat tfx']//th[@class='alt']")?.text {
                    removeSpace(&current)
                    first.current = current
                }
                if var other = tdats?.at_xpath("/div[@class='tscr']/table[@class='tdat']//th[@class='alt h']")?.text {
                    removeSpace(&other)
                    first.other = other
                }
                firstHeader.list.append(first)
                let ca = tdats?.xpath("/table[@class='tdat']/tbody[@class='ca']/tr")
                ca?.forEach({ element in
                    var usergroup = UserGroupListModel()
                    if let title = element.at_xpath("/td")?.text {
                        usergroup.title = title
                    }
                    firstHeader.list.append(usergroup)
                })
                for index in firstHeader.list.indices where index != 0 && index != 1 {
                    let tr = tdats?.at_xpath("/table[@class='tdat tfx']/tbody[@class='ca']/tr[\(index - 1)]")
                    if let img = tr?.at_xpath("/td/img/@alt")?.text {
                        firstHeader.list[index].currentImage = img == "data_valid" ? "checkmark" : "xmark"
                    } else if var current = tr?.at_xpath("/td")?.text {
                        removeSpace(&current)
                        firstHeader.list[index].current = current
                    }
                    let tr1 = tdats?.at_xpath("/div[@class='tscr']/table[@class='tdat']/tbody[@class='ca']/tr[\(index - 1)]")
                    if let img = tr1?.at_xpath("/td/img/@alt")?.text {
                        firstHeader.list[index].otherImage = img == "data_valid" ? "checkmark" : "xmark"
                    } else if var other = tr1?.at_xpath("/td")?.text {
                        removeSpace(&other)
                        firstHeader.list[index].other = other
                    }
                }
                if !first.current.isEmpty && !firstHeader.list.isEmpty {
                    sections.append(firstHeader)
                }

                let postHeader = getHeader(index: 1, tag: "cb", html: tdats)
                if !postHeader.list.isEmpty {
                    sections.append(postHeader)
                }

                let houseHeader = getHeader(index: 2, tag: "cc", html: tdats)
                if !houseHeader.list.isEmpty {
                    sections.append(houseHeader)
                }

                let attachmentHeader = getHeader(index: 3, tag: "cd", html: tdats)
                if !attachmentHeader.list.isEmpty {
                    sections.append(attachmentHeader)
                }
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

    private func getHeader(index: Int, tag: String, html: XMLElement?) -> UserGroupHeaderModel {
        var header = UserGroupHeaderModel()
        if var title = html?.at_xpath("/table[@class='tdat']//tr[@class='alt h'][\(index)]")?.text {
            removeSpace(&title)
            header.title = title
        }
        if var current = html?.at_xpath("/table[@class='tdat tfx']//tr[@class='alt h'][\(index)]")?.text {
            removeSpace(&current)
            header.current = current
        }
        if var other = html?.at_xpath("/div[@class='tscr']/table[@class='tdat']//tr[@class='alt h'][\(index)]")?.text {
            removeSpace(&other)
            header.other = other
        }
        let cd = html?.xpath("/table[@class='tdat']/tbody[@class='\(tag)']/tr")
        cd?.forEach({ element in
            var usergroup = UserGroupListModel()
            if let title = element.at_xpath("/td")?.text {
                usergroup.title = title
            }
            header.list.append(usergroup)
        })
        for idx in header.list.indices {
            let tr = html?.at_xpath("/table[@class='tdat tfx']/tbody[@class='\(tag)']/tr[\(idx + 1)]")
            if let img = tr?.at_xpath("/td/img/@alt")?.text {
                header.list[idx].currentImage = img == "data_valid" ? "checkmark" : "xmark"
            } else if var current = tr?.at_xpath("/td")?.text {
                removeSpace(&current)
                header.list[idx].current = current
            }
            let tr1 = html?.at_xpath("/div[@class='tscr']/table[@class='tdat']/tbody[@class='\(tag)']/tr[\(idx + 1)]")
            if let img = tr1?.at_xpath("/td/img/@alt")?.text {
                header.list[idx].otherImage = img == "data_valid" ? "checkmark" : "xmark"
            } else if var other = tr1?.at_xpath("/td")?.text {
                removeSpace(&other)
                header.list[idx].other = other
            }
        }
        return header
    }
}
