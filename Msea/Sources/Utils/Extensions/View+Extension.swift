//
//  View+Extension.swift
//  Msea
//
//  Created by tzqiang on 2021/12/3.
//  Copyright © 2021 eternal.just. All rights reserved.
//

import SwiftUI

extension View {
    /// Hide or show the view based on a boolean value.
    ///
    /// Example for visibility:
    ///
    ///     Text("Label")
    ///         .isHidden(true)
    ///
    /// Example for complete removal:
    ///
    ///     Text("Label")
    ///         .isHidden(true, remove: true)
    ///
    /// - Parameters:
    ///   - hidden: Set to `false` to show the view. Set to `true` to hide the view.
    ///   - remove: Boolean value indicating whether or not to remove the view.
    @ViewBuilder func isHidden(_ hidden: Bool, remove: Bool = false) -> some View {
        if hidden {
            if !remove {
                self.hidden()
            }
        } else {
            self
        }
    }
}

struct AdaptiveForegroundColorModifier: ViewModifier {
    var lightModeColor: Color
    var darkModeColor: Color

    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content.foregroundColor(resolvedColor)
    }

    private var resolvedColor: Color {
        switch colorScheme {
        case .light:
            return lightModeColor
        case .dark:
            return darkModeColor
        @unknown default:
            return lightModeColor
        }
    }
}

extension View {
    func foregroundColor(
        light lightModeColor: Color,
        dark darkModeColor: Color
    ) -> some View {
        modifier(AdaptiveForegroundColorModifier(
            lightModeColor: lightModeColor,
            darkModeColor: darkModeColor
        ))
    }
}

extension Button {
    func showProgress(isShowing: Binding<Bool>, color: Color = .theme) -> some View {
        ZStack(alignment: .top) {
            self
            if isShowing.wrappedValue {
                ProgressView()
                    .tint(color)
                    .zIndex(1)
            }
        }
    }
}

extension UIApplication {
    var key: UIWindow? {
        self.connectedScenes
            .map({ $0 as? UIWindowScene })
            .compactMap({ $0 })
            .first?
            .windows
            .first(where: { $0.isKeyWindow })
    }
}

extension UIView {
    func allSubviews() -> [UIView] {
        var subs = self.subviews
        for subview in self.subviews {
            let rec = subview.allSubviews()
            subs.append(contentsOf: rec)
        }
        return subs
    }
}

struct TabBarTool {
    static func showTabBar(_ isShow: Bool) {
        UIApplication.shared.key?.allSubviews().forEach({ subView in
            if let view = subView as? UITabBar {
                view.isHidden = !isShow
            }
        })
    }
}
