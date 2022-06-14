//
//  URLSchemesContentView.swift
//  Msea
//
//  Created by tzqiang on 2022/1/17.
//  Copyright © 2022 eternal.just. All rights reserved.
//

import SwiftUI

struct URLSchemesContentView: View {
    @EnvironmentObject private var hud: HUDState

    var body: some View {
        List {
            ForEach(URLSchemesItem.allCases) { item in
                Button {
                    UIPasteboard.general.string = item.action
                    hud.show(message: "已复制")
                } label: {
                    VStack(alignment: .leading) {
                        Text(item.title)

                        Text(item.action)
                    }
                    .foregroundColor(Color(light: .black, dark: .white))
                }
            }
        }
        .navigationTitle("URL Schemes")
        .onAppear {
            if !UIDevice.current.isPad {
                TabBarTool.showTabBar(false)
            }
        }
    }
}

struct URLSchemesContentView_Previews: PreviewProvider {
    static var previews: some View {
        URLSchemesContentView()
    }
}

enum URLSchemesItem: String, CaseIterable, Identifiable {
    case daysign
    case ranklist
    case notice
    case space
    case viewthread

    var id: String { self.rawValue }

    var title: String {
        switch self {
        case .daysign:
            return "每日签到"
        case .ranklist:
            return "排行榜"
        case .notice:
            return "消息提醒"
        case .space:
            return "个人空间"
        case .viewthread:
            return "帖子内容页"
        }
    }

    var action: String {
        switch self {
        case .daysign:
            return "msea://daysign"
        case .ranklist:
            return "msea://ranklist"
        case .notice:
            return "msea://notice"
        case .space:
            return "msea://space?uid=id"
        case .viewthread:
            return "msea://viewthread?tid=id"
        }
    }
}
