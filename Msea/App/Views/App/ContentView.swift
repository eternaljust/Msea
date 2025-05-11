//
//  ContentView.swift
//  Msea
//
//  Created by tzqiang on 2021/12/3.
//

import SwiftUI
import Kanna
import Common
import AppTab

struct ContentView: View {
//    @StateObject private var selection = AppTabSelection()
    @State var preferredColorScheme: ColorScheme?

    var body: some View {
        @Bindable var appTab = AppTabSelection.shared
        TabView(selection: $appTab.item) {
            ForEach(AppTab.allCases) { item in
                getContentView(item)
                    .tabItem {
                        Label(item.title, systemImage: item.icon)
                    }
                    .tag(item)
            }
        }
        .preferredColorScheme(preferredColorScheme)
        .tint(.theme)
        .onReceive(NotificationCenter.default.publisher(for: .colorScheme, object: nil)) { _ in
            getColorScheme()
        }
        .onAppear {
            getColorScheme()
            UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = UIColor(named: "AccentColor")
            UIPageControl.appearance().currentPageIndicatorTintColor = .theme
            UIPageControl.appearance().pageIndicatorTintColor = .separator
            UISegmentedControl.appearance().selectedSegmentTintColor = .secondaryTheme
            UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
            UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.secondaryLabel], for: .normal)
            UITableView.appearance().sectionHeaderTopPadding = 0.1
            let appearance = UITabBarAppearance()
            appearance.configureWithDefaultBackground()
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }

    private func getColorScheme() {
        if CacheInfo.shared.colorScheme == .unspecified {
            preferredColorScheme = nil
        } else if CacheInfo.shared.colorScheme == .light {
            preferredColorScheme = .light
        } else if CacheInfo.shared.colorScheme == .dark {
            preferredColorScheme = .dark
        }
    }

    @ViewBuilder private func getContentView(_ item: AppTab) -> some View {
        switch item {
        case .home:
            HomeContentView()
        case .node:
            NodeContentView()
        case .notice:
            NoticeContentView()
        case .mine:
            MineContentView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
