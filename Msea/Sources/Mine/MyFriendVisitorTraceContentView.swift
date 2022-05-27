//
//  MyFriendVisitorTraceContentView.swift
//  Msea
//
//  Created by tzqiang on 2022/5/24.
//  Copyright © 2022 eternal.just. All rights reserved.
//

import SwiftUI

/// 我的好友列表、访客、足迹
struct MyFriendVisitorTraceContentView: View {
    @EnvironmentObject private var selection: MyFriendVisitorTraceSelection

    var body: some View {
        VStack {
            Picker("MyFriendVisitorTraceTab", selection: $selection.tab) {
                ForEach(MyFriendVisitorTraceTab.allCases) { tab in
                    Text(tab.title)
                        .tag(tab)
                }
            }
            .pickerStyle(.segmented)
            .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))

            TabView(selection: $selection.tab) {
                ForEach(MyFriendVisitorTraceTab.allCases) { tab in
                    getContentView(tab)
                        .tag(tab)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .edgesIgnoringSafeArea(UIDevice.current.isPad ? [] : [.bottom])
        }
        .navigationTitle("我的好友")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if !UIDevice.current.isPad {
                TabBarTool.showTabBar(false)
            }
        }
    }

    @ViewBuilder private func getContentView(_ tab: MyFriendVisitorTraceTab) -> some View {
        switch tab {
        case .friend:
            MyFriendContentView()
        case .visitor, .trace:
            MyVisitorTraceContentView(type: tab)
        }
    }
}

struct MyFriendVisitorTraceContentView_Previews: PreviewProvider {
    static var previews: some View {
        MyFriendVisitorTraceContentView()
    }
}

enum MyFriendVisitorTraceTab: String, CaseIterable, Identifiable {
    case friend
    case visitor
    case trace

    var id: String { self.rawValue }

    var title: String {
        switch self {
        case .friend: return "好友列表"
        case .visitor: return "我的访客"
        case .trace: return "我的足迹"
        }
    }

    var header: String {
        switch self {
        case .friend: return "按照好友热度排序"
        case .visitor: return "他们拜访过您，回访一下吧"
        case .trace: return "您曾经拜访过的用户列表"
        }
    }
}

class MyFriendVisitorTraceSelection: ObservableObject {
    @Published var tab: MyFriendVisitorTraceTab = MyFriendVisitorTraceTab.friend
}
