//
//  InteractiveContentView.swift
//  Msea
//
//  Created by tzqiang on 2022/1/24.
//  Copyright © 2022 eternal.just. All rights reserved.
//

import SwiftUI

/// 坛友互动
struct InteractiveContentView: View {
    @State private var selectedInteractiveTab = InteractiveTab.friend

    var body: some View {
        VStack {
            Picker("InteractiveTab", selection: $selectedInteractiveTab) {
                ForEach(InteractiveTab.allCases) { tab in
                    Text(tab.title)
                        .tag(tab)
                }
            }
            .pickerStyle(.segmented)
            .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))

            TabView(selection: $selectedInteractiveTab) {
                ForEach(InteractiveTab.allCases) { tab in
                    switch tab {
                    case .poke:
                        InteractivePokeContentView()
                            .tag(tab)
                    case.friend:
                        InteractiveFriendContentView()
                            .tag(tab)
                    }
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .edgesIgnoringSafeArea(UIDevice.current.isPad ? [] : [.bottom])
        }
        .navigationTitle("坛友互动")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct InteractiveContentView_Previews: PreviewProvider {
    static var previews: some View {
        InteractiveContentView()
    }
}
