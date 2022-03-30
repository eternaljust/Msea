//
//  TagSearchContentView.swift
//  Msea
//
//  Created by tzqiang on 2022/3/29.
//  Copyright © 2022 eternal.just. All rights reserved.
//

import SwiftUI
import Kanna

/// 标签搜索
struct TagSearchContentView: View {
    @State private var search = ""
    @StateObject private var searchState = SearchState()
    @FocusState private var focused: Bool
    @EnvironmentObject private var hud: HUDState

    @State private var action = ""

    var body: some View {
        VStack {
            TextField("请输入标签", text: $search)
                .textFieldStyle(.roundedBorder)
                .focused($focused)
                .submitLabel(.search)
                .padding([.leading, .trailing], 10)
                .onSubmit {
                    Task {
                        if search.isEmpty {
                            hud.show(message: "请输入标签")
                        }
                        searchState.keywrod = search
                    }
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                        focused = search.isEmpty
                    }
                }

            TagListContentView(searchState: searchState)
        }
        .navigationBarTitle("标签搜索")
    }
}

struct TagSearchContentView_Previews: PreviewProvider {
    static var previews: some View {
        TagSearchContentView()
    }
}
