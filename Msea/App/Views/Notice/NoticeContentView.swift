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
    @State private var paddingTop: CGFloat = 0

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
                        TabView(selection: $selectedItem) {
                            ForEach(NoticeItem.allCases) { item in
                                getContentView(item)
                                    .tag(item)
                                    .padding(.top, paddingTop)
                            }
                        }
                        .tabViewStyle(.page(indexDisplayMode: .always))
                        .toolbar(content: {
                            ToolbarItem(placement: .principal) {
                                Picker("NoticeItem", selection: $selectedItem) {
                                    ForEach(NoticeItem.allCases) { view in
                                        Text(view.title)
                                            .tag(view)
                                    }
                                }
                                .pickerStyle(.segmented)
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
            .navigationBarTitleDisplayMode(.inline)
            .ignoresSafeArea(edges: .bottom)
            .onAppear(perform: {
                isLogin = UserInfo.shared.isLogin()
                TabBarTool.showTabBar(true)
                CacheInfo.shared.selectedTab = .notice
                if #available(iOS 16.0, *) {
                    paddingTop = 50
                }
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
            PostListContentView()
        case .interactive:
            InteractiveContentView()
        case .system:
            SystemContentView()
//        case .app:
//            AppContentView()
        }
    }
}

struct NoticeContentView_Previews: PreviewProvider {
    static var previews: some View {
        NoticeContentView()
    }
}
