//
//  ContentView.swift
//  Msea
//
//  Created by tzqiang on 2021/12/3.
//

import SwiftUI
import Kanna

struct ContentView: View {
    var body: some View {
        TabView {
            HomeContentView()
                .tabItem {
                    Label("虫部落", systemImage: "house")
                }
                .tag(1)

            MineContentView()
                .tabItem {
                    Label("我的", systemImage: "person")
                }
                .tag(2)
        }
        .tint(.theme)
        .onAppear {
            UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = UIColor(named: "AccentColor")
            UIPageControl.appearance().currentPageIndicatorTintColor = .theme
            UIPageControl.appearance().pageIndicatorTintColor = .separator
            UISegmentedControl.appearance().selectedSegmentTintColor = .secondaryTheme
            UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
            UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.secondaryLabel], for: .normal)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
