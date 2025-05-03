//
//  URLSchemesContentView.swift
//  Msea
//
//  Created by tzqiang on 2022/1/17.
//  Copyright © 2022 eternal.just. All rights reserved.
//

import SwiftUI
import Extension

struct URLSchemesContentView: View {
    @EnvironmentObject private var hud: HUDState

    var body: some View {
        List {
            ForEach(URLSchemesItem.allCases) { item in
                Button {
                    UIPasteboard.general.string = item.action
                    hud.show(message: "已复制")
                } label: {
                    VStack(alignment: .leading) {
                        Text(item.title)

                        Text(item.action)
                    }
                    .foregroundColor(Color(light: .black, dark: .white))
                }
            }
        }
        .navigationTitle("URL Schemes")
        .onAppear {
            if !UIDevice.current.isPad {
                TabBarTool.showTabBar(false)
            }
        }
    }
}

struct URLSchemesContentView_Previews: PreviewProvider {
    static var previews: some View {
        URLSchemesContentView()
    }
}
