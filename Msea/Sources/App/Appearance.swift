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
