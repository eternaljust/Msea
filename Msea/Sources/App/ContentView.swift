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
                    Label("Home", systemImage: "house")
                }
                .tag(1)

            MineContentView()
                .tabItem {
                    Label("Mine", systemImage: "person")
                }
                .tag(2)
        }
        .tint(.theme)
        .onAppear {
            UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = UIColor(named: "AccentColor")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
