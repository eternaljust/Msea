//
//  RankListContentView.swift
//  Msea
//
//  Created by Awro on 2022/2/19.
//  Copyright © 2022 eternal.just. All rights reserved.
//

import SwiftUI
import CoreSpotlight
import EJExtension

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
        .userActivity(Constants.ranklistUserActivityType, { userActivity in
            userActivity.persistentIdentifier = ""
            userActivity.isEligibleForSearch = true
            userActivity.isEligibleForPrediction = true
            userActivity.isEligibleForPublicIndexing = true
            userActivity.title = "虫部落排行榜"
            userActivity.suggestedInvocationPhrase = "虫部落排行榜"
            let attributes = CSSearchableItemAttributeSet()
            attributes.contentDescription = "点击打开 Msea，查看虫部落积分帖子排行榜。"
            userActivity.contentAttributeSet = attributes
            userActivity.becomeCurrent()
            print("set ranklistUserActivity")
        })
    }
}

struct RankListContentView_Previews: PreviewProvider {
    static var previews: some View {
        RankListContentView()
    }
}
