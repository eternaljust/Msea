//
//  AboutContentView.swift
//  Msea
//
//  Created by tzqiang on 2022/1/17.
//  Copyright © 2022 eternal.just. All rights reserved.
//

import SwiftUI

/// 关于
struct AboutContentView: View {
    @State private var selectedItem: AboutItem?

    var body: some View {
        VStack {
            List {
                Section {
                    ForEach(AboutItem.allCases) { item in
                        ZStack(alignment: .leading) {
                            if item != .sourceCode {
                                NavigationLink(destination: getContentView(item)) {
                                    Text(item.title)
                                }
                            } else {
                                Button {
                                    selectedItem = item
                                } label: {
                                    HStack {
                                        Text(item.title)

                                        Spacer()

                                        Indicator()
                                    }
                                }
                                .foregroundColor(Color(light: .black, dark: .white))
                            }
                        }
                    }
                } header: {
                    VStack(alignment: .center) {
                        Image("Icon")
                            .frame(width: 76, height: 76)
                            .cornerRadius(10)

                        Text("\(UIApplication.appVersion)(\(UIApplication.appBuild))")

                        Spacer()
                    }
                    .frame(width: UIScreen.main.bounds.width)
                }
            }
        }
        .navigationTitle("关于 Msea")
        .sheet(item: $selectedItem, content: { item in
            Safari(url: URL(string: item.url))
        })
    }

    @ViewBuilder private func getContentView(_ item: AboutItem) -> some View {
        switch item {
        case .license:
            LicenseContentView()
        case .sourceCode:
            EmptyView()
        case .sdklist:
            SDKListContentView()
        }
    }
}

struct AboutContentView_Previews: PreviewProvider {
    static var previews: some View {
        AboutContentView()
    }
}
