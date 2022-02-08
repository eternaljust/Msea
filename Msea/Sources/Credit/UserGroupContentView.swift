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
                            .font(.font12)
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
                        .font(.font15)
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
                            .font(.font12)
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

                let tdats = html.at_xpath("//div[@class='tdats']", namespaces: nil)
                var firstHeader = UserGroupHeaderModel()
                if let title = tdats?.at_xpath("/table[@class='tdat']//th[@class='c0']", namespaces: nil)?.text {
                    firstHeader.title = title
                }
                if let current = tdats?.at_xpath("/table[@class='tdat tfx']//th[@class='c0']", namespaces: nil)?.text {
                    firstHeader.current = current
                }
                if let other = tdats?.at_xpath("/ul[@class='tb c1']/li[@id='c1']", namespaces: nil)?.text {
                    firstHeader.other = other
                }
                if firstHeader.other.isEmpty, let other = tdats?.at_xpath("/ul[@class='tb c2']/li[@id='c2']", namespaces: nil)?.text {
                    firstHeader.other = other
                }
                if firstHeader.other.isEmpty, let other = tdats?.at_xpath("/ul[@class='tb c3']/li[@id='c3']", namespaces: nil)?.text {
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
        if var title = html?.at_xpath("/table[@class='tdat']//tr[@class='alt h'][\(index)]", namespaces: nil)?.text {
            removeSpace(&title)
            header.title = title
        }
        if var current = html?.at_xpath("/table[@class='tdat tfx']//tr[@class='alt h'][\(index)]", namespaces: nil)?.text {
            removeSpace(&current)
            header.current = current
        }
        if var other = html?.at_xpath("/div[@class='tscr']/table[@class='tdat']//tr[@class='alt h'][\(index)]", namespaces: nil)?.text {
            removeSpace(&other)
            header.other = other
        }
        let cd = html?.xpath("/table[@class='tdat']/tbody[@class='\(tag)']/tr", namespaces: nil)
        cd?.forEach({ element in
            var usergroup = UserGroupListModel()
            if let title = element.at_xpath("/td", namespaces: nil)?.text {
                usergroup.title = title
            }
            header.list.append(usergroup)
        })
        for idx in header.list.indices {
            let tr = html?.at_xpath("/table[@class='tdat tfx']/tbody[@class='\(tag)']/tr[\(idx + 1)]", namespaces: nil)
            if let img = tr?.at_xpath("/td/img/@alt", namespaces: nil)?.text {
                header.list[idx].currentImage = img == "data_valid" ? "checkmark" : "xmark"
            } else if var current = tr?.at_xpath("/td", namespaces: nil)?.text {
                removeSpace(&current)
                header.list[idx].current = current
            }
            let tr1 = html?.at_xpath("/div[@class='tscr']/table[@class='tdat']/tbody[@class='\(tag)']/tr[\(idx + 1)]", namespaces: nil)
            if let img = tr1?.at_xpath("/td/img/@alt", namespaces: nil)?.text {
                header.list[idx].otherImage = img == "data_valid" ? "checkmark" : "xmark"
            } else if var other = tr1?.at_xpath("/td", namespaces: nil)?.text {
                removeSpace(&other)
                header.list[idx].other = other
            }
        }
        return header
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

enum UserGroupItem: String, Identifiable {
    case admin
    case supermoderator
    case moderator
    case internshipmoderator
    case webeditor
    case informationinspector
    case auditor
    case vicewebmaster

    case bannedspeaking
    case forbidden
    case bannedip
    case visitor
    case waitingforverificationmembership
    case qqvisitor

    case ban
    case lv0
    case lv1
    case lv2
    case lv3
    case lv4
    case lv5
    case lv6

    var id: String { self.rawValue }
    var gid: String {
        switch self {
        case .admin:
            return "1"
        case .supermoderator:
            return "2"
        case .moderator:
            return "3"
        case .internshipmoderator:
            return "16"
        case .webeditor:
            return "17"
        case .informationinspector:
            return "18"
        case .auditor:
            return "19"
        case .vicewebmaster:
            return "21"

        case .bannedspeaking:
            return "4"
        case .forbidden:
            return "5"
        case .bannedip:
            return "6"
        case .visitor:
            return "7"
        case .waitingforverificationmembership:
            return "8"
        case .qqvisitor:
            return "20"

        case .ban:
            return "9"
        case .lv0:
            return "11"
        case .lv1:
            return "12"
        case .lv2:
            return "13"
        case .lv3:
            return "14"
        case .lv4:
            return "15"
        case .lv5:
            return "22"
        case .lv6:
            return "23"
        }
    }
    var title: String {
        switch self {
        case .admin:
            return "管理员"
        case .supermoderator:
            return "超级版主"
        case .moderator:
            return "版主"
        case .internshipmoderator:
            return "实习版主"
        case .webeditor:
            return "网站编辑"
        case .informationinspector:
            return "信息监察员"
        case .auditor:
            return "审核员"
        case .vicewebmaster:
            return "副版主"

        case .bannedspeaking:
            return "禁止发言"
        case .forbidden:
            return "禁止访问"
        case .bannedip:
            return "禁止 IP"
        case .visitor:
            return "游客"
        case .waitingforverificationmembership:
            return "等待验证会员"
        case .qqvisitor:
            return "QQ游客"

        case .ban:
            return "BAN"
        case .lv0:
            return "LV0"
        case .lv1:
            return "LV1"
        case .lv2:
            return "LV2"
        case .lv3:
            return "LV3"
        case .lv4:
            return "LV4"
        case .lv5:
            return "LV5"
        case .lv6:
            return "LV6"
        }
    }
}

enum UserGroupMenu: String, CaseIterable, Identifiable {
    case manage
    case normal
    case level

    var id: String { self.rawValue }
    var title: String {
        switch self {
        case .manage:
            return "站点管理组"
        case .normal:
            return "普通用户组"
        case .level:
            return "晋级用户组"
        }
    }

    var items: [UserGroupItem] {
        switch self {
        case .manage:
            return [
                .admin,
                .supermoderator,
                .moderator,
                .internshipmoderator,
                .webeditor,
                .informationinspector,
                .auditor,
                .vicewebmaster
            ]
        case .normal:
            return [
                .bannedspeaking,
                .forbidden,
                .bannedip,
                .visitor,
                .waitingforverificationmembership,
                .qqvisitor
            ]
        case .level:
            return [
                .ban,
                .lv0,
                .lv1,
                .lv2,
                .lv3,
                .lv4,
                .lv5,
                .lv6
            ]
        }
    }
}
