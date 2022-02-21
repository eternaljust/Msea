//
//  CreditContentView.swift
//  Msea
//
//  Created by tzqiang on 2022/1/25.
//  Copyright © 2022 eternal.just. All rights reserved.
//

import SwiftUI

struct CreditContentView: View {
    @State private var selectedItem = CreditItem.mycredit
    @State private var selectedIndex = 0
    @StateObject private var rule = CreditRuleObject()
    @State private var isPresented = false
    @State private var isLogin = UserInfo.shared.isLogin()

    var body: some View {
        NavigationView {
            VStack {
                if isLogin {
                    if UIDevice.current.isPad {
                        List {
                            ForEach(CreditItem.allCases) { item in
                                ZStack(alignment: .leading) {
                                    Text(item.title)

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
                            ForEach(CreditItem.allCases) { item in
                                getContentView(item)
                                    .tag(item.index)
                            }
                        }
                        .tabViewStyle(.page(indexDisplayMode: .always))
                        .toolbar(content: {
                            ToolbarItem(placement: .principal) {
                                SegmentedControlView(selectedIndex: $selectedIndex, titles: CreditItem.allCases.map { $0.title })
                                    .frame(width: 180)
                            }
                        })
                    }
                } else {
                    Button("登录") {
                        isPresented.toggle()
                    }
                }
            }
            .navigationTitle("积分")
            .ignoresSafeArea(edges: .bottom)
            .onAppear(perform: {
                isLogin = UserInfo.shared.isLogin()
                TabBarTool.showTabBar(true)
                CacheInfo.shared.selectedTab = .credit
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
                Text("积分用户组")
            } else {
                Text("登录后可查看积分信息")
            }
        }
        .environmentObject(rule)
    }

    @ViewBuilder private func getContentView(_ item: CreditItem) -> some View {
        switch item {
        case .mycredit:
            MyCreditContentView()
        case .usergroup:
            UserGroupContentView()
        }
    }
}

struct CreditContentView_Previews: PreviewProvider {
    static var previews: some View {
        CreditContentView()
    }
}

enum CreditItem: String, CaseIterable, Identifiable {
    case mycredit
    case usergroup

    var id: String { self.rawValue }
    var title: String {
        switch self {
        case .mycredit: return "我的积分"
        case .usergroup: return "用户组"
        }
    }
    var index: Int {
        switch self {
        case .mycredit: return 0
        case .usergroup: return 1
        }
    }
}
