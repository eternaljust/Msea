//
//  DynamicFontContentView.swift
//  Msea
//
//  Created by tzqiang on 2022/2/8.
//  Copyright © 2022 eternal.just. All rights reserved.
//

import SwiftUI

/// 动态字体大小调整
struct DynamicFontContentView: View {
    var body: some View {
        VStack(alignment: .center) {
            ScrollView {
                Text("第一步，打开【设置】-【控制中心】，添加【文字大小】")

                Image("DynamicFont1")
                    .resizable()
                    .scaledToFit()

                Text("第二步，打开【Msea】，让【Msea】处于打开的状态\n")

                Text("第三步，从屏幕底部向上轻扫来显示“控制中心”，或者从屏幕右上方边缘向下轻扫来显示“控制中心”，再点击【AA】图标")
                Image("DynamicFont2")
                    .resizable()
                    .scaledToFit()

                Text("第四步，选择【仅限Msea】，上下拖动滑块来调整字体大小比例")
                Image("DynamicFont3")
                    .resizable()
                    .scaledToFit()
            }
            .padding(EdgeInsets(top: 15, leading: 15, bottom: UIDevice.current.isPad ? 80 : 15, trailing: 15))
            .ignoresSafeArea(.all, edges: .bottom)
        }
        .navigationTitle("调整字体大小教程")
    }
}

struct DynamicFontContentView_Previews: PreviewProvider {
    static var previews: some View {
        DynamicFontContentView()
    }
}
