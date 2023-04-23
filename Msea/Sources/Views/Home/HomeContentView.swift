//
//  HomeContentView.swift
//  Msea
//
//  Created by Awro on 2021/12/5.
//  Copyright © 2021 eternal.just. All rights reserved.
//

import SwiftUI
import Kanna

/// 首页列表
struct HomeContentView: View {
    @State private var selectedViewTab = TopicTab.new
    @EnvironmentObject private var selection: TabItemSelection

    @State private var isActive = false
    @State private var tid = ""
    @State private var isViewthread = false
    @State private var uid = ""
    @State private var isSpace = false
    @State private var isRanklist = false

    @StateObject private var rule = CreditRuleObject()
    @EnvironmentObject var store: AppStore

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    NavigationLink(destination: DaySignContentView(), isActive: $isActive) {
                        Image(systemName: "leaf.fill")
                            .foregroundColor(.theme)
                            .imageScale(.large)
                    }

                    NavigationLink {
                        SearchContentView()
                    } label: {
                        Label(title: {
                            Text("站内搜索")
                        }, icon: {
                            Image(systemName: "magnifyingglass")
                        })
                            .frame(maxWidth: .infinity, minHeight: 34)
                            .padding(.leading, 5)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(.secondary, lineWidth: 1)
                            )
                    }

                    NavigationLink {
                        RankListContentView()
                    } label: {
                        Image(systemName: "list.number")
                            .imageScale(.large)
                            .foregroundColor(.theme)
                    }

                    if !store.state.home.notice.isEmpty {
                        Button {
                            CacheInfo.shared.selectedTab = .notice
                            selection.index = .notice
                        } label: {
                            Label {
                               Text(store.state.home.notice)
                            } icon: {
                                Image(systemName: "bell.fill")
                                    .imageScale(.large)
                            }
                            .foregroundColor(.theme)
                        }
                    }
                }
                .frame(height: 40)
                .padding([.leading, .trailing], 20)

                Picker("TopicTab", selection: $selectedViewTab) {
                    ForEach(TopicTab.allCases) { tab in
                        Text(tab.title)
                            .tag(tab)
                    }
                }
                .pickerStyle(.segmented)
                .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))

                TabView(selection: $selectedViewTab) {
                    ForEach(TopicTab.allCases) { tab in
                        TopicListContentView(view: tab)
                            .tag(tab)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .onAppear {
                    Task {
                        await store.dispatch(.home(action: .navigationBarHidden(true)))
                    }
                    TabBarTool.showTabBar(true)
                    CacheInfo.shared.selectedTab = .home
                }
                .onDisappear {
                    Task {
                        await store.dispatch(.home(action: .navigationBarHidden(false)))
                    }
                }

                NavigationLink(destination: TopicDetailContentView(tid: tid), isActive: $isViewthread) {
                    EmptyView()
                }
                .opacity(0.0)

                NavigationLink(destination: SpaceProfileContentView(uid: uid), isActive: $isSpace) {
                    EmptyView()
                }
                .opacity(0.0)

                NavigationLink(destination: RankListContentView(), isActive: $isRanklist) {
                    EmptyView()
                }
                .opacity(0.0)
            }
            .navigationTitle("首页")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarHidden(store.state.home.navigationBarHidden)
            .ignoresSafeArea(edges: .bottom)
            .onReceive(NotificationCenter.default.publisher(for: .daysign, object: nil)) { _ in
                goDaysign()
            }
            .onReceive(NotificationCenter.default.publisher(for: .notice, object: nil)) { _ in
                goNotice()
            }
            .onAppear {
                Task {
                    if UserInfo.shared.isLogin() {
                        print("checkNotice---")
                        await store.dispatch(.home(action: .checkNotice))
                    }
                }
            }

            Text("选择你感兴趣的帖子吧")
        }
        .environmentObject(rule)
        .onOpenURL { url in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.urlSchemes(url)
            }
        }
        .onContinueUserActivity(Constants.daysignUserActivityType) { _ in
            print("continue daysignUserActivity")
            goDaysign()
        }
        .onContinueUserActivity(Constants.ranklistUserActivityType) { _ in
            print("continue ranklistUserActivity")
            goRanklist()
        }
    }

    private func urlSchemes(_ url: URL) {
        print(url)
        if let host = url.host, let scheme = url.scheme, scheme == "msea" {
            guard let item = URLSchemesItem(rawValue: host) else { return }
            TabBarTool.showTabBar(true)
            CacheInfo.shared.selectedTab = .home
            selection.index = .home

            switch item {
            case .daysign:
                goDaysign()
            case .notice:
                goNotice()
            case .ranklist:
                goRanklist()
            case .viewthread:
                if let query = url.query, query.contains("tid=") {
                    tid = query.components(separatedBy: "=")[1]
                    if Int(tid) != nil {
                        isViewthread = true
                    }
                }
            case .space:
                if let query = url.query, query.contains("uid=") {
                    uid = query.getUid()
                    if Int(uid) != nil {
                        if UserInfo.shared.isLogin(), UserInfo.shared.uid == uid {
                            CacheInfo.shared.selectedTab = .mine
                            selection.index = .mine
                        } else {
                            isSpace = true
                        }
                    }
                }
            }
        }
    }

    private func goDaysign() {
        CacheInfo.shared.selectedTab = .home
        selection.index = .home
        isActive = true
    }

    private func goNotice() {
        CacheInfo.shared.selectedTab = .notice
        selection.index = .notice
    }

    private func goRanklist() {
        CacheInfo.shared.selectedTab = .home
        selection.index = .home
        isRanklist = true
    }
}

struct HomeContentView_Previews: PreviewProvider {
    static var previews: some View {
        HomeContentView()
    }
}
