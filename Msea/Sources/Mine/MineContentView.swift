//
//  MineContentView.swift
//  Msea
//
//  Created by Awro on 2021/12/5.
//  Copyright © 2021 eternal.just. All rights reserved.
//

import SwiftUI

struct MineContentView: View {
    @State private var showingImagePicker = false

    var body: some View {
        Button("Login") {
            showingImagePicker = true
        }
        .sheet(isPresented: $showingImagePicker) {
            LoginContentView()
        }
    }
}

struct MineContentView_Previews: PreviewProvider {
    static var previews: some View {
        MineContentView()
    }
}
