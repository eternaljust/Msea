//
//  CustomView.swift
//  Msea
//
//  Created by tzqiang on 2022/1/17.
//  Copyright © 2022 eternal.just. All rights reserved.
//

import SwiftUI

struct Indicator: View {
    var body: some View {
        NavigationLink(destination: EmptyView()) {
            EmptyView()
        }
    }
}

struct Indicator_Previews: PreviewProvider {
    static var previews: some View {
        Indicator()
    }
}
