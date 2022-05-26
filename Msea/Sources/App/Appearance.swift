//
//  Appearance.swift
//  Msea
//
//  Created by tzqiang on 2021/12/9.
//  Copyright © 2021 eternal.just. All rights reserved.
//

import SwiftUI

struct BigButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .background(
                Capsule()
                    .foregroundColor(.theme)
                    .frame(width: 300, height: 40)
            )
            .scaleEffect(configuration.isPressed ? 0.95: 1)
            .foregroundColor(.white)
    }
}

struct LabelLeftIconRightStyle: LabelStyle {
    var spacing: CGFloat = 5

    func makeBody(configuration: Configuration) -> some View {
        HStack(alignment: .center, spacing: spacing) {
            configuration.title
            configuration.icon
        }
    }
}
