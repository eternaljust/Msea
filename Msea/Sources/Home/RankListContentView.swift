//
//  RankListContentView.swift
//  Msea
//
//  Created by Awro on 2022/2/19.
//  Copyright © 2022 eternal.just. All rights reserved.
//

import SwiftUI

/// 排行榜
struct RankListContentView: View {
    @State private var selectedTab = RankListTab.member

    var body: some View {
        VStack {
            Picker("RankListTab", selection: $selectedTab) {
                ForEach(RankListTab.allCases) { tab in
                    Text(tab.title)
                        .tag(tab)
                }
            }
            .pickerStyle(.segmented)
            .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))

            TabView(selection: $selectedTab) {
                ForEach(RankListTab.allCases) { tab in
                    switch tab {
                    case .member:
                        MemberCreditPostContentView()
                            .tag(tab)
                    case .thread:
                        TreadRankContentView()
                            .tag(tab)
                    }
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .edgesIgnoringSafeArea(UIDevice.current.isPad ? [] : [.bottom])
        }
        .navigationBarTitle("排行榜")
        .onAppear {
            if !UIDevice.current.isPad {
                TabBarTool.showTabBar(false)
            }
        }
    }
}

struct RankListContentView_Previews: PreviewProvider {
    static var previews: some View {
        RankListContentView()
    }
}

enum RankListTab: String, CaseIterable, Identifiable {
    case member
    case thread

    var id: String { self.rawValue }
    var title: String {
        switch self {
        case .member: return "用户"
        case .thread: return "帖子"
        }
    }
}
