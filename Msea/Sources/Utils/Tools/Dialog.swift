//
//  Dialog.swift
//  Msea
//
//  Created by tzqiang on 2021/12/14.
//  Copyright © 2021 eternal.just. All rights reserved.
//

import SwiftUI

extension View {
    func dialog<Content: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder content: () -> Content
    ) -> some View {
        ZStack(alignment: .top) {
            self
            if isPresented.wrappedValue {
                Dialog(content: content)
                    .transition(AnyTransition.scale.combined(with: .opacity))
                    .zIndex(1)
            }
        }
    }
}

struct Dialog<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        content
            .multilineTextAlignment(.center)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 25, style: .continuous)
                    .fill(Color.backGround)
            )
    }
}
