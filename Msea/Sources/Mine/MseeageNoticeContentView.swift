//
//  MseeageNoticeContentView.swift
//  Msea
//
//  Created by tzqiang on 2022/2/9.
//  Copyright © 2022 eternal.just. All rights reserved.
//

import SwiftUI

/// 新消息提醒通知
struct MseeageNoticeContentView: View {
    var body: some View {
        VStack(alignment: .center) {
            ScrollView {
                Text("第一步，长按【桌面】空白区域，右上角点击【+】图标\n")

                Text("第二步，点击【搜索小组件】，输入【Msea】，在列表中点击【Msea】\n")

                Image("MessageNotice1")
                    .resizable()
                    .scaledToFit()

                Text("第三步，左滑动到【新消息提醒】小组件，点击【添加小组件】按钮")
                Image("MessageNotice2")
                    .resizable()
                    .scaledToFit()
            }
            .padding(EdgeInsets(top: 15, leading: 15, bottom: UIDevice.current.isPad ? 80 : 15, trailing: 15))
            .ignoresSafeArea(.all, edges: .bottom)
        }
        .navigationTitle("消息提醒通知教程")
    }
}

struct MseeageNoticeContentView_Previews: PreviewProvider {
    static var previews: some View {
        MseeageNoticeContentView()
    }
}
