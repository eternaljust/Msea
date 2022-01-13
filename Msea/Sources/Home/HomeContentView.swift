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
    @State private var search = ""
    @State private var selectedViewTab = ViewTab.new
    @State private var navigationBarHidden = true
    @State private var isActive = false
    @ObservedObject private var selection = TabItemSelection()
    @State private var notice = ""

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

                    TextField("搜索", text: $search)
                        .textFieldStyle(.roundedBorder)

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
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarHidden(navigationBarHidden)
            .onAppear {
                navigationBarHidden = true
                TabBarTool.showTabBar(true)
            }
            .onDisappear {
                navigationBarHidden = false
            }
            .onReceive(NotificationCenter.default.publisher(for: .daysign, object: nil)) { _ in
                selection.index = .home
                isActive = true
            }
            .task {
                if UserInfo.shared.isLogin() {
                    await checkNotice()
                }
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
