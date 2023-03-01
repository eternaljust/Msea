//
//  MemberCreditPostContentView.swift
//  Msea
//
//  Created by Awro on 2022/2/19.
//  Copyright © 2022 eternal.just. All rights reserved.
//

import SwiftUI
import Kanna

/// 用户排行榜
struct MemberCreditPostContentView: View {
    @State private var selectedTab = CreditPostTab.credit
    @State private var orderby = "all"
    @State private var orderbyTitle = "全部"

    @State private var userList = [CreditPostListModel]()
    @State private var headerTitle = ""
    @State private var creditTitle = ""
    @State private var creditRank = ""

    var body: some View {
        VStack {
            List {
                Section {
                    ForEach(userList) { user in
                        NavigationLink(destination: SpaceProfileContentView(uid: user.uid)) {
                            HStack {
                                Image(systemName: "\(user.num).circle.fill")
                                    .resizable()
                                    .symbolRenderingMode(.palette)
                                    .foregroundStyle(.white, user.numTop ? .red : Color.theme)
                                    .frame(width: 20, height: 20)

                                AsyncImage(url: URL(string: user.avatar)) { image in
                                    image.resizable()
                                } placeholder: {
                                    ProgressView()
                                }
                                .frame(width: 45, height: 45)
                                .cornerRadius(5)
                                .padding(.leading, 5)

                                VStack(alignment: .leading, spacing: 5) {
                                    Text(user.name)
                                        .font(.font17Blod)

                                    Text(user.title)
                                        .font(.font16)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding([.top, .bottom], 5)
                        }
                    }
                } header: {
                    if !creditTitle.isEmpty && !creditRank.isEmpty {
                        NavigationLink(destination: MyCreditContentView()) {
                            VStack(alignment: .leading) {
                                Text(creditTitle)
                                    .foregroundColor(.secondaryTheme)

                                Text("当前排名 \(Text(creditRank).foregroundColor(.red).font(.font20)) ,再接再厉!")
                            }
                            .font(.font15)
                        }
                    } else {
                        HStack {
                            Text(headerTitle)
                        }
                    }
                } footer: {
                    if !creditTitle.isEmpty && !creditRank.isEmpty {
                        HStack {
                            Text(headerTitle)
                                .font(.font15)
                        }
                    }
                }
            }
        }
        .navigationTitle("\(selectedTab.title) • \(orderbyTitle)")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Menu(CreditPostTab.credit.title) {
                        ForEach(MemberCreditTab.allCases) { item in
                            Button {
                                selectedTab = .credit
                                orderby = item.orderby
                                orderbyTitle = item.title

                                Task {
                                    await loadData()
                                }
                            } label: {
                                Text(item.title)
                            }
                        }
                    }

                    Menu(CreditPostTab.post.title) {
                        ForEach(MemberPostTab.allCases) { item in
                            Button {
                                selectedTab = .post
                                orderby = item.orderby
                                orderbyTitle = item.title
                                creditTitle = ""
                                creditRank = ""

                                Task {
                                    await loadData()
                                }
                            } label: {
                                Text(item.title)
                            }
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis")
                }
            }
        }
        .task {
            if userList.isEmpty {
                await loadData()
            }
        }
    }

    private func loadData() async {
        headerTitle = ""
        creditTitle = ""
        creditRank = ""
        Task {
            // swiftlint:disable force_unwrapping
            let url = URL(string: "https://www.chongbuluo.com/misc.php?mod=ranklist&type=member&view=\(selectedTab.id)&orderby=\(orderby)")!
            // swiftlint:enble force_unwrapping
            var requset = URLRequest(url: url)
            requset.configHeaderFields()
            let (data, _) = try await URLSession.shared.data(for: requset)
            if let html = try? HTML(html: data, encoding: .utf8) {
                let dl = html.xpath("//div[@class='xld xlda hasrank']/dl[@class='bbda cl']")
                var list = [CreditPostListModel]()
                dl.forEach { element in
                    var model = CreditPostListModel()
                    if let num = element.at_xpath("/dd[@class='ranknum']")?.text {
                        model.num = num
                    }
                    if let num = element.at_xpath("/dd[@class='ranknum']/img/@alt")?.text {
                        model.num = num
                        model.numTop = true
                    }
                    if let name = element.at_xpath("/dt[last()]/a")?.text {
                        model.name = name
                    }
                    if let uid = element.at_xpath("/dt[last()]/a/@href")?.text {
                        model.uid = uid.getUid()
                        model.avatar = "https://www.chongbuluo.com/uc_server/avatar.php?uid=\(model.uid)"
                    }
                    if let title = element.at_xpath("/dd[last()]/p")?.text {
                        model.title = title.replacingOccurrences(of: "\r\n ", with: "")
                    }
                    list.append(model)
                }

                if let notice = html.at_xpath("//div[@class='notice']")?.text {
                    headerTitle = notice
                }
                if let title = html.at_xpath("//div[@class='tbmu']/a")?.text {
                    creditTitle = title
                }
                if let rank = html.at_xpath("//div[@class='tbmu']/span")?.text {
                    creditRank = rank
                }
                userList = list
            }
        }
    }
}

struct MemberCreditPostContentView_Previews: PreviewProvider {
    static var previews: some View {
        MemberCreditPostContentView()
    }
}

enum CreditPostTab: String, CaseIterable, Identifiable {
    case credit
    case post

    var id: String { self.rawValue }
    var title: String {
        switch self {
        case .credit: return "积分排行"
        case .post: return "发帖数排行"
        }
    }
}

enum MemberCreditTab: String, CaseIterable, Identifiable {
    case all
    case bit
    case violation

    var id: String { self.rawValue }

    var title: String {
        switch self {
        case .all: return "全部"
        case .bit: return "Bit"
        case .violation: return "违规"
        }
    }

    var orderby: String {
        switch self {
        case .all: return "all"
        case .bit: return "2"
        case .violation: return "4"
        }
    }
}

enum MemberPostTab: String, CaseIterable, Identifiable {
    case posts
    case digestposts
    case thismonth
    case today

    var id: String { self.rawValue }

    var title: String {
        switch self {
        case .posts: return "发帖数"
        case .digestposts: return "精华数"
        case .thismonth: return "最近30天发帖数"
        case .today: return "最近24小时发帖数"
        }
    }

    var orderby: String { self.rawValue }
}

struct CreditPostListModel: Identifiable {
    var id = UUID()
    var num = ""
    var numTop = false
    var uid = ""
    var avatar = ""
    var name = ""
    var title = ""
}
