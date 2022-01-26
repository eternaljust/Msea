//
//  NoticeContentView.swift
//  Msea
//
//  Created by tzqiang on 2022/1/24.
//  Copyright © 2022 eternal.just. All rights reserved.
//

import SwiftUI

struct NoticeContentView: View {
    @State private var selectedItem = NoticeItem.mypost
    @State private var selectedIndex = 0
    @State private var isPresented = false
    @State private var isLogin = UserInfo.shared.isLogin()

    var body: some View {
        NavigationView {
            VStack {
                if isLogin {
                    if UIDevice.current.isPad {
                        List {
                            ForEach(NoticeItem.allCases) { item in
                                ZStack(alignment: .leading) {
                                    HStack {
                                        Image(systemName: item.icon)

                                        Text(item.title)
                                    }

                                    NavigationLink(destination: getContentView(item)) {
                                        EmptyView()
                                    }
                                    .opacity(0.0)
                                }
                            }
                        }
                        .listStyle(.inset)
                    } else {
                        TabView(selection: $selectedIndex) {
                            ForEach(NoticeItem.allCases) { item in
                                getContentView(item)
                                    .tag(item.index)
                            }
                        }
                        .tabViewStyle(.page(indexDisplayMode: .always))
                        .toolbar(content: {
                            ToolbarItem(placement: .principal) {
                                SegmentedControlView(selectedIndex: $selectedIndex, titles: NoticeItem.allCases.map { $0.title })
                            }
                        })
                    }
                } else {
                    Button("登录") {
                        isPresented.toggle()
                    }
                }
            }
            .navigationTitle("通知")
            .onAppear(perform: {
                isLogin = UserInfo.shared.isLogin()
                TabBarTool.showTabBar(true)
                CacheInfo.shared.selectedTab = .notice
            })
            .sheet(isPresented: $isPresented) {
                LoginContentView()
            }
            .onReceive(NotificationCenter.default.publisher(for: .login, object: nil)) { _ in
                isLogin = true
            }
            .onReceive(NotificationCenter.default.publisher(for: .logout, object: nil)) { _ in
                isLogin = false
            }

            if isLogin {
                Text("通知提醒")
            } else {
                Text("登录后可查看通知提醒")
            }
        }
    }

    @ViewBuilder private func getContentView(_ item: NoticeItem) -> some View {
        switch item {
        case .mypost:
            MyPostContentView()
        case .interactive:
            InteractiveContentView()
        case .system:
            SystemContentView()
        case .app:
            AppContentView()
        }
    }
}

struct NoticeContentView_Previews: PreviewProvider {
    static var previews: some View {
        NoticeContentView()
    }
}

enum NoticeItem: String, CaseIterable, Identifiable {
    case mypost
    case interactive
    case system
    case app

    var id: String { self.rawValue }
    var icon: String {
        switch self {
        case .mypost: return "newspaper"
        case .interactive: return "repeat.circle"
        case .system: return "gearshape"
        case .app: return "app.badge"
        }
    }
    var title: String {
        switch self {
        case .mypost: return "我的帖子"
        case .interactive: return "坛友互动"
        case .system: return "系统提醒"
        case .app: return "应用提醒"
        }
    }
    var index: Int {
        switch self {
        case .mypost: return 0
        case .interactive: return 1
        case .system: return 2
        case .app: return 3
        }
    }
}
