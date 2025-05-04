//
//  HomeContentView.swift
//  Msea
//
//  Created by Awro on 2021/12/5.
//  Copyright © 2021 eternal.just. All rights reserved.
//

import SwiftUI
import Kanna
import Base
import EJExtension

/// 首页列表
struct HomeContentView: View {
    @StateObject private var rule = CreditRuleObject()
    @EnvironmentObject private var selection: TabItemSelection
    @EnvironmentObject private var store: AppStore

    @State private var selectedViewTab = TopicTab.new
    @State private var isDaysign = false
    @State private var isTopicDetail = false
    @State private var isSpaceProfile = false
    @State private var isRanklist = false

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    NavigationLink {
                        DaySignContentView()
                    } label: {
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
                        let tabList = store.state.topic.tabList[tab]
                        TopicListContentView(topicData: tabList ?? .init(tab: .new))
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
            }
            .navigationTitle("首页")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarHidden(store.state.home.navigationBarHidden)
            .ignoresSafeArea(edges: .bottom)
            .navigationDestination(isPresented: $isDaysign) {
                DaySignContentView()
            }
            .navigationDestination(isPresented: $isTopicDetail) {
                TopicDetailContentView(tid: store.state.home.tid)
            }
            .navigationDestination(isPresented: $isSpaceProfile) {
                SpaceProfileContentView(uid: store.state.home.uid)
            }
            .navigationDestination(isPresented: $isRanklist) {
                RankListContentView()
            }
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
                checkCacheTime()
            }

            Text("选择你感兴趣的帖子吧")
        }
        .environmentObject(rule)
        .onOpenURL { url in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                Task {
                    await self.urlSchemes(url)
                }
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
}

extension HomeContentView {
    private func urlSchemes(_ url: URL) async {
        print("urlSchemes: \(url)")
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
                    let tid = query.components(separatedBy: "=")[1]
                    await store.dispatch(.home(action: .setTid(tid)))
                    if Int(tid) != nil {
                        isTopicDetail.toggle()
                    }
                }
            case .space:
                if let query = url.query, query.contains("uid=") {
                    let uid = query.getUid()
                    await store.dispatch(.home(action: .setUid(uid)))
                    if Int(uid) != nil {
                        if UserInfo.shared.isLogin(), UserInfo.shared.uid == uid {
                            CacheInfo.shared.selectedTab = .mine
                            selection.index = .mine
                        } else {
                            isSpaceProfile.toggle()
                        }
                    }
                }
            }
        }
    }

    private func goDaysign() {
        CacheInfo.shared.selectedTab = .home
        selection.index = .home
        isDaysign.toggle()
    }

    private func goNotice() {
        CacheInfo.shared.selectedTab = .notice
        selection.index = .notice
    }

    private func goRanklist() {
        CacheInfo.shared.selectedTab = .home
        selection.index = .home
        isRanklist.toggle()
    }

    private func checkCacheTime() {
        let nowTime = Date().timeIntervalSince1970
        let cacheTime = UserInfo.shared.cacheTime
        let time = (nowTime - cacheTime) / (24 * 60 * 60)
        if time > 20 {
            // 20 天内登录凭证失效，清理 cookie，需重新登录
            UserInfo.shared.reset()
        }
    }
}

struct HomeContentView_Previews: PreviewProvider {
    static var previews: some View {
        HomeContentView()
    }
}
