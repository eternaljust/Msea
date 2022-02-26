//
//  ContentView.swift
//  Msea
//
//  Created by tzqiang on 2021/12/3.
//

import SwiftUI
import Kanna

struct ContentView: View {
    @StateObject private var selection = TabItemSelection()
    @State var preferredColorScheme: ColorScheme?

    var body: some View {
        TabView(selection: $selection.index) {
            ForEach(TabBarItem.allCases) { item in
                getContentView(item)
                    .tabItem {
                        Label(item.title, systemImage: item.icon)
                    }
                    .tag(item)
            }
        }
        .environmentObject(selection)
        .onChange(of: selection.index, perform: { newValue in
            print(newValue)
        })
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

    @ViewBuilder private func getContentView(_ item: TabBarItem) -> some View {
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

enum TabBarItem: String, CaseIterable, Identifiable {
    case home
    case node
    case notice
    case mine

    var id: String { self.rawValue }
    var icon: String {
        switch self {
        case .home: return "house"
        case .node: return "circle.grid.cross.fill"
        case .notice: return "bell.fill"
        case .mine: return "person"
        }
    }
    var title: String {
        switch self {
        case .home: return "虫部落"
        case .node: return "节点"
        case .notice: return "通知"
        case .mine: return "我的"
        }
    }
}

class TabItemSelection: ObservableObject {
    @Published var index: TabBarItem = CacheInfo.shared.selectedTab
}
