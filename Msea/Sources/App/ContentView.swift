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
                .padding()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                .tag(1)

            MineContentView()
                .padding()
                .tabItem {
                    Label("Mine", systemImage: "person")
                }
                .tag(2)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
