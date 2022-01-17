//
//  LicenseContentView.swift
//  Msea
//
//  Created by tzqiang on 2022/1/17.
//  Copyright © 2022 eternal.just. All rights reserved.
//

import SwiftUI

/// 开源协议
struct LicenseContentView: View {
    @State private var selectedItem: LicenseItem?

    var body: some View {
        List {
            ForEach(LicenseItem.allCases) { item in
                Button {
                    selectedItem = item
                } label: {
                    HStack {
                        Text(item.title)

                        Spacer()

                        Indicator()
                    }
                    .foregroundColor(Color(light: .black, dark: .white))
                }
            }
        }
        .navigationTitle("开源协议")
        .sheet(item: $selectedItem, content: { item in
            Safari(url: URL(string: item.url))
        })
    }
}

struct LicenseContentView_Previews: PreviewProvider {
    static var previews: some View {
        LicenseContentView()
    }
}

enum LicenseItem: String, CaseIterable, Identifiable {
    case kanna

    var id: String { self.rawValue }

    var title: String {
        switch self {
        case .kanna:
            return "Kanna"
        }
    }

    var url: String {
        switch self {
        case .kanna:
            return "https://github.com/tid-kijyun/Kanna"
        }
    }
}
