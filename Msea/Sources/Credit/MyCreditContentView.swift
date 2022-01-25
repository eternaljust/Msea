//
//  MyCreditContentView.swift
//  Msea
//
//  Created by tzqiang on 2022/1/25.
//  Copyright © 2022 eternal.just. All rights reserved.
//

import SwiftUI

struct MyCreditContentView: View {
    @State private var selectedCreditTab = MyCreditTab.list

    var body: some View {
        VStack {
            Picker("MyCreditTab", selection: $selectedCreditTab) {
                ForEach(MyCreditTab.allCases) { tab in
                    Text(tab.title)
                        .tag(tab)
                }
            }
            .pickerStyle(.segmented)
            .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))

            TabView(selection: $selectedCreditTab) {
                ForEach(MyCreditTab.allCases) { tab in
                    getContentView(tab)
                        .tag(tab)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .edgesIgnoringSafeArea(UIDevice.current.isPad ? [] : [.bottom])
        }
        .navigationTitle("我的积分")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder private func getContentView(_ tab: MyCreditTab) -> some View {
        switch tab {
        case .list:
            CreditListContentView()
        case .system:
            CreditSystemContentView(selectedCreditTab: $selectedCreditTab)
        case .rule:
            CreditRuleContentView()
        }
    }
}

struct MyCreditContentView_Previews: PreviewProvider {
    static var previews: some View {
        MyCreditContentView()
    }
}

enum MyCreditTab: String, CaseIterable, Identifiable {
    case list
    case system
    case rule

    var id: String { self.rawValue }
    var title: String {
        switch self {
        case .list:
            return "积分收益"
        case .system:
            return "系统奖励"
        case .rule:
            return "积分规则"
        }
    }
}
