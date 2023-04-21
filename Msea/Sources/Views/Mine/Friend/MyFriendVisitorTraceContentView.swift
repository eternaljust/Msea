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
//        .onAppear {
//            if !UIDevice.current.isPad {
//                TabBarTool.showTabBar(false)
//            }
//        }
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
