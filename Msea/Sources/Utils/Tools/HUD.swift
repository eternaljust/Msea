//
//  HUD.swift
//  Msea
//
//  Created by tzqiang on 2021/12/9.
//  Copyright © 2021 eternal.just. All rights reserved.
//

import SwiftUI

extension View {
    func hud<Content: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder content: () -> Content
    ) -> some View {
        ZStack(alignment: .top) {
            self
            if isPresented.wrappedValue {
                HUD(content: content)
                    .transition(AnyTransition.move(edge: .top).combined(with: .opacity))
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                            withAnimation {
                                isPresented.wrappedValue = false
                            }
                        }
                    }
                    .zIndex(1)
            }
        }
    }
}

struct HUD<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        content
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
            .padding()
            .background(
                Capsule()
                    .foregroundColor(.theme)
                    .shadow(color: .black.opacity(0.16), radius: 12, x: 0, y: 5)
            )
    }
}

final class HUDState: ObservableObject {
    @Published var isPresented: Bool = false
    private(set) var message: String = ""

    func show(message: String) {
        self.message = message
        withAnimation {
            isPresented = true
        }
    }
}
