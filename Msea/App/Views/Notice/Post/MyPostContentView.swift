//
//  MyPostContentView.swift
//  Msea
//
//  Created by tzqiang on 2022/1/13.
//  Copyright © 2022 eternal.just. All rights reserved.
//

import SwiftUI
import WidgetKit

/// 我的帖子
struct MyPostContentView: View {
    @State private var selectedPostTab = MyPostTab.post

    var body: some View {
        VStack {
            Picker("MyPostTab", selection: $selectedPostTab) {
                ForEach(MyPostTab.allCases) { tab in
                    Text(tab.title)
                        .tag(tab)
                }
            }
            .pickerStyle(.segmented)
            .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))

            TabView(selection: $selectedPostTab) {
                ForEach(MyPostTab.allCases) { tab in
                    PostListContentView(type: tab)
                        .tag(tab)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .edgesIgnoringSafeArea(UIDevice.current.isPad ? [] : [.bottom])
        }
        .navigationTitle("我的帖子")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            WidgetCenter.shared.reloadTimelines(ofKind: "NoticeWidget")
        }
    }
}

struct MyPostContentView_Previews: PreviewProvider {
    static var previews: some View {
        MyPostContentView()
    }
}
