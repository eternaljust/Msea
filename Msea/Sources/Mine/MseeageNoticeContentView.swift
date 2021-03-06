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
                Text("特别说明：新消息提醒通知需添加小组件到桌面进行辅助，会根据设置的刷新间隔时间来循环加载一次数据，若有新的提醒需要通知开关开启后才能收到系统的消息推送\n")
                    .foregroundColor(.red)

                Text("第一步，长按【桌面】空白区域，右上角或者左上角点击【+】图标\n")

                Text("第二步，点击【搜索小组件】，输入【Msea】，在列表中点击【Msea】")

                Image("MessageNotice1")
                    .resizable()
                    .scaledToFit()
                    .padding(.bottom, 15)

                Text("第三步，左滑动到【新消息提醒】小组件，点击【添加小组件】按钮")
                Image("MessageNotice2")
                    .resizable()
                    .scaledToFit()
                    .padding(.bottom, 15)

                Text("第四步，长按桌面上的【新消息提醒】小组件，可选择刷新间隔时间，默认五分钟刷新一次数据")
                Image("MessageNotice3")
                    .resizable()
                    .scaledToFit()
                    .padding(.bottom, 15)

                Text("添加到桌面并开启通知后收到新消息提醒时的系统推送通知")
                    .foregroundColor(.red)
                Image("MessageNotice4")
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
