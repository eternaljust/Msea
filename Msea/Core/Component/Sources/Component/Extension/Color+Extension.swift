//
//  Color+Extension.swift
//  Msea
//
//  Created by tzqiang on 2021/12/7.
//  Copyright © 2021 eternal.just. All rights reserved.
//

import SwiftUI

public extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    init(
        light lightModeColor: @escaping @autoclosure () -> Color,
        dark darkModeColor: @escaping @autoclosure () -> Color
    ) {
        self.init(UIColor(
            light: UIColor(lightModeColor()),
            dark: UIColor(darkModeColor())
        ))
    }

    /// 主题色 green
    static let theme: Color = .green
    /// 第二主题色 3f51b5
    static let secondaryTheme: Color = Color(hex: "#3f51b5")
    /// 浅灰背景色 f3f3f3
    static let lightGray: Color = Color(hex: "f3f3f3")
    /// 浅黑背景色 1c1c1e
    static let lightBlack: Color = Color(hex: "1c1c1e")
    /// 背景色 f3f3f3 1c1c1e
    static let backGround: Color = Color(light: .lightGray, dark: .lightBlack)
    /// widget 浅黑背景色 2c2c2e
    static let widgetBlack: Color = Color(hex: "2c2c2e")
}

public extension UIColor {
    convenience init(
        light lightModeColor: @escaping @autoclosure () -> UIColor,
        dark darkModeColor: @escaping @autoclosure () -> UIColor
     ) {
        self.init { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .light:
                return lightModeColor()
            case .dark:
                return darkModeColor()
            case .unspecified:
                return lightModeColor()
            @unknown default:
                return lightModeColor()
            }
        }
    }
    /// 主题色 green
    static let theme: UIColor = UIColor(.theme)
    /// 第二主题色 3f51b5
    static let secondaryTheme: UIColor = UIColor(.secondaryTheme)
}
