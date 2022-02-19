//
//  SearchUserContentView.swift
//  Msea
//
//  Created by tzqiang on 2022/1/20.
//  Copyright © 2022 eternal.just. All rights reserved.
//

import SwiftUI
import Kanna

struct SearchUserContentView: View {
    @StateObject var searchState: SearchState

    @State private var search = ""
    @State private var userList = [UserListModel]()
    @EnvironmentObject private var hud: HUDState

    var body: some View {
        VStack {
            if userList.isEmpty {
                Text("没有找到相关用户")
            } else {
                List {
                    Section {
                        ForEach(userList) { user in
                            NavigationLink(destination: SpaceProfileContentView(uid: user.uid)) {
                                HStack {
                                    AsyncImage(url: URL(string: user.avatar)) { image in
                                        image.resizable()
                                    } placeholder: {
                                        ProgressView()
                                    }
                                    .frame(width: 45, height: 45)
                                    .cornerRadius(5)

                                    VStack(alignment: .leading, spacing: 10) {
                                        Text(user.name)
                                            .font(.font17Blod)

                                        Text(user.content)
                                            .font(.font16)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .padding([.top, .bottom], 5)
                            }
                        }
                    } header: {
                        Text("以下是查找到的用户列表(\(userList.count) 个)")
                    }
                }
            }
        }
        .onChange(of: searchState.keywrod) { newValue in
            Task {
                if newValue != search {
                    search = newValue
                    await loadData()
                }
            }
        }
        .onAppear {
            Task {
                if !search.isEmpty && userList.isEmpty {
                    await loadData()
                }
            }
        }
    }

    private func loadData() async {
        Task {
            // swiftlint:disable force_unwrapping
            let parames = "&formhash=\(UserInfo.shared.formhash)&username=\(search)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            let url = URL(string: "https://www.chongbuluo.com/home.php?mod=spacecp&ac=search&searchsubmit=yes\(parames)")!
            print(url.absoluteString)
            // swiftlint:enble force_unwrapping
            var requset = URLRequest(url: url)
            requset.configHeaderFields()
            let (data, _) = try await URLSession.shared.data(for: requset)
            if let html = try? HTML(html: data, encoding: .utf8) {
                var list = [UserListModel]()
                let li = html.xpath("//li[@class='bbda cl']", namespaces: nil)
                li.forEach { element in
                    var user = UserListModel()
                    if let avatar = element.at_xpath("/div[@class='avt']/a/img/@src", namespaces: nil)?.text {
                        user.avatar = avatar.replacingOccurrences(of: "&size=small", with: "")
                    }
                    if let name = element.at_xpath("/h4/a/@title", namespaces: nil)?.text {
                        user.name = name
                    }
                    if let content = element.at_xpath("/p[@class='maxh']", namespaces: nil)?.text {
                        user.content = content.replacingOccurrences(of: "\r\n", with: "")
                    }
                    if let uid = element.at_xpath("/h4/a/@href", namespaces: nil)?.text {
                        let uids = uid.components(separatedBy: "uid=")
                        if uid.contains("uid"), uids.count == 2 {
                            user.uid = uids[1]
                        }
                    }

                    list.append(user)
                }
                userList = list
            }
        }
    }
}

struct SearchUserContentView_Previews: PreviewProvider {
    static var previews: some View {
        SearchUserContentView(searchState: SearchState())
    }
}

struct UserListModel: Identifiable {
    var id = UUID()
    var uid = ""
    var avatar = ""
    var content = ""
    var name = ""
}
