//
//  SearchContentView.swift
//  Msea
//
//  Created by tzqiang on 2022/1/19.
//  Copyright © 2022 eternal.just. All rights reserved.
//

import SwiftUI
import Kanna

/// 站内搜索
struct SearchContentView: View {
    @State private var search = ""
    @StateObject private var searchState = SearchState()

    @Environment(\.dismiss) private var dismiss
    @FocusState private var focused: Bool
    @EnvironmentObject private var hud: HUDState
    @State private var needLogin = false
    @State private var showAlert = false
    @State private var selectedSearchTab = SearchTab.post

    var body: some View {
        VStack {
            Picker("SearchTab", selection: $selectedSearchTab) {
                ForEach(SearchTab.allCases) { tab in
                    Text(tab.title)
                        .tag(tab)
                }
            }
            .pickerStyle(.segmented)
            .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))

            TabView(selection: $selectedSearchTab) {
                ForEach(SearchTab.allCases) { tab in
                    switch tab {
                    case .post:
                        SearchPostConentView(searchState: searchState)
                            .tag(tab)
                    case .user:
                        SearchUserContentView(searchState: searchState)
                            .tag(tab)
                    }
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .edgesIgnoringSafeArea(UIDevice.current.isPad ? [] : [.bottom])
        }
        .toolbar(content: {
            ToolbarItem(placement: .principal) {
                TextField("站内搜索", text: $search)
                    .textFieldStyle(.roundedBorder)
                    .focused($focused)
                    .submitLabel(.search)
                    .onSubmit {
                        Task {
                            if search.isEmpty {
                                hud.show(message: "请输入内容")
                                return
                            }
                            if !UserInfo.shared.isLogin() {
                                showAlert.toggle()
                            }
                            searchState.keywrod = search
                        }
                    }
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                if !UIDevice.current.isPad {
                    Button {
                        dismiss()
                    } label: {
                        Text("取消")
                    }
                }
            }
        })
        .navigationBarBackButtonHidden(true)
        .navigationBarTitle("站内搜索")
        .onAppear {
            if !UIDevice.current.isPad {
                TabBarTool.showTabBar(false)
            }
        }
        .sheet(isPresented: $needLogin) {
            LoginContentView()
        }
        .alert("提示", isPresented: $showAlert) {
            Button("取消", role: .cancel) {
            }

            Button("登录") {
                needLogin.toggle()
            }
        } message: {
            Text("站内搜索必须先登录")
        }
    }
}

struct SearchContentView_Previews: PreviewProvider {
    static var previews: some View {
        SearchContentView()
    }
}

enum SearchTab: String, CaseIterable, Identifiable {
    case post
    case user

    var id: String { self.rawValue }
    var title: String {
        switch self {
        case .post: return "帖子"
        case .user: return "用户"
        }
    }
}

class SearchState: ObservableObject {
    @Published var keywrod = ""
}
