//
//  HomeContentView.swift
//  Msea
//
//  Created by Awro on 2021/12/5.
//  Copyright © 2021 eternal.just. All rights reserved.
//

import SwiftUI

struct HomeContentView: View {
    @State private var search = ""
    @State private var selectedViewTab = ViewTab.new
    @StateObject private var scrollHidden = ListScrollHidden()

    var body: some View {
        VStack {
            if !scrollHidden.hidden {
                HStack {
                    Image(systemName: "leaf.fill")
                        .symbolRenderingMode(.multicolor)
                        .imageScale(.large)
                        .padding(.leading, 20)
                    TextField("搜索", text: $search)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Spacer()
                }
                .transition(.opacity)
            }

            Picker("ViewTab", selection: $selectedViewTab) {
                ForEach(ViewTab.allCases) { view in
                    Text(view.title)
                        .tag(view)
                }
            }
            .pickerStyle(.segmented)
            .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
            .onAppear {
                UISegmentedControl.appearance().selectedSegmentTintColor = .systemGreen
                UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
                    UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.black], for: .normal)
            }

            TabView(selection: $selectedViewTab) {
                ForEach(ViewTab.allCases) { view in
                    TopicListContentView(view: view, scrollHidden: scrollHidden)
                        .tag(view)
                }
            }
            .tabViewStyle(.page)
            .indexViewStyle(.page(backgroundDisplayMode: .never))
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
