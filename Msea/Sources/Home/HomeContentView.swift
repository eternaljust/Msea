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
    @State private var selectedViewTab = ViewTab.new
    @State private var navigationBarHidden = true
    @State private var isActive = false
    @EnvironmentObject private var selection: TabItemSelection
    @State private var notice = ""
    @State private var tid = ""
    @State private var isViewthread = false
    @State private var uid = ""
    @State private var isSpace = false

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    NavigationLink(destination: DaySignContentView(), isActive: $isActive) {
                        Image(systemName: "leaf.fill")
                            .foregroundColor(.theme)
                            .imageScale(.large)
                            .padding(.leading, 20)
                    }

                    NavigationLink {
                        SearchContentView()
                    } label: {
                        Label(title: {
                            Text("站内搜索")
                        }, icon: {
                            Image(systemName: "magnifyingglass")
                        })
                            .frame(width: UIScreen.main.bounds.width - 80, height: 34, alignment: .leading)
                            .padding(.leading, 5)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(.secondary, lineWidth: 1)
                            )
                    }

                    Spacer()

                    NavigationLink {
                        MyPostContentView()
                    } label: {
                        Label {
                           Text(notice)
                        } icon: {
                            Image(systemName: "bell.fill")
                                .imageScale(.large)
                        }
                        .foregroundColor(.theme)
                        .padding(.trailing, 10)
                    }
                }

                Picker("ViewTab", selection: $selectedViewTab) {
                    ForEach(ViewTab.allCases) { view in
                        Text(view.title)
                            .tag(view)
                    }
                }
                .pickerStyle(.segmented)
                .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))

                TabView(selection: $selectedViewTab) {
                    ForEach(ViewTab.allCases) { view in
                        TopicListContentView(view: view)
                            .tag(view)
                    }
                }
                .tabViewStyle(.page)
                .indexViewStyle(.page(backgroundDisplayMode: .never))

                NavigationLink(destination: TopicDetailContentView(tid: tid), isActive: $isViewthread) {
                    EmptyView()
                }
                .opacity(0.0)

                NavigationLink(destination: SpaceProfileContentView(uid: uid), isActive: $isSpace) {
                    EmptyView()
                }
                .opacity(0.0)
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarHidden(navigationBarHidden)
            .onAppear {
                navigationBarHidden = true
                TabBarTool.showTabBar(true)
                CacheInfo.shared.selectedTab = .home
            }
            .onDisappear {
                navigationBarHidden = false
            }
            .onReceive(NotificationCenter.default.publisher(for: .daysign, object: nil)) { _ in
                goDaysign()
            }
            .task {
                if UserInfo.shared.isLogin() {
                    await checkNotice()
                }
            }
        }
        .onOpenURL { url in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.urlSchemes(url)
            }
        }
    }

    private func checkNotice() async {
        Task {
            // swiftlint:disable force_unwrapping
            let url = URL(string: "https://www.chongbuluo.com")!
            // swiftlint:enble force_unwrapping
            var requset = URLRequest(url: url)
            requset.configHeaderFields()
            let (data, _) = try await URLSession.shared.data(for: requset)
            if let html = try? HTML(html: data, encoding: .utf8) {
                if let notice = html.at_xpath("//a[@id='myprompt']", namespaces: nil)?.text, notice.contains("(") {
                    self.notice = notice
                } else {
                    self.notice = ""
                }
            }
        }
    }

    private func urlSchemes(_ url: URL) {
        TabBarTool.showTabBar(true)
        CacheInfo.shared.selectedTab = .home
        selection.index = .home
        if let host = url.host, let scheme = url.scheme, scheme == "msea" {
            let item = URLSchemesItem(rawValue: host)
            switch item {
            case .daysign:
                goDaysign()
            case .viewthread:
                if let query = url.query, query.contains("tid=") {
                    tid = query.components(separatedBy: "=")[1]
                    if Int(tid) != nil {
                        isViewthread = true
                    }
                }
            case .space:
                if let query = url.query, query.contains("uid=") {
                    uid = query.components(separatedBy: "=")[1]
                    if Int(uid) != nil {
                        if UserInfo.shared.isLogin(), UserInfo.shared.uid == uid {
                            CacheInfo.shared.selectedTab = .mine
                            selection.index = .mine
                        } else {
                            isSpace = true
                        }
                    }
                }
            default:
                print(url)
            }
        }
    }

    private func goDaysign() {
        CacheInfo.shared.selectedTab = .home
        selection.index = .home
        isActive = true
    }
}

struct HomeContentView_Previews: PreviewProvider {
    static var previews: some View {
        HomeContentView()
    }
}

enum ViewTab: String, CaseIterable, Identifiable {
    case new
    case hot
    case newthread
    case sofa

    var id: String { self.rawValue }
    var title: String {
        switch self {
        case .new: return "最新回复"
        case .hot: return "热门"
        case .newthread: return "最新发表"
        case .sofa: return "前排"
        }
    }
}
