//
//  NodeContentView.swift
//  Msea
//
//  Created by Awro on 2022/2/26.
//  Copyright © 2022 eternal.just. All rights reserved.
//

import SwiftUI

/// 节点分区导航
struct NodeContentView: View {
    var body: some View {
        NavigationView {
            VStack {
            }
            .navigationBarTitle("节点")

            Text("选择你感兴趣的分区吧")
        }
    }
}

struct NodeContentView_Previews: PreviewProvider {
    static var previews: some View {
        NodeContentView()
    }
}
