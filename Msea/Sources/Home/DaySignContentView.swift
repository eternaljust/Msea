//
//  DaySignContentView.swift
//  Msea
//
//  Created by tzqiang on 2021/12/7.
//  Copyright © 2021 eternal.just. All rights reserved.
//

import SwiftUI

struct DaySignContentView: View {
    @State private var showAlert = false

    var body: some View {
        VStack {
            Button("今日未签到，点击签到") {
            }
            .foregroundColor(.white)
            .frame(width: 200, height: 40)
            .background(Color.secondaryTheme)
            .cornerRadius(5)

            HStack(spacing: 50) {
                VStack {
                    Text("连续签到")

                    Text("0天")
                }

                Button {
                    showAlert = true
                } label: {
                    Image(systemName: "questionmark.circle")
                }
                .alert("每日福利规则", isPresented: $showAlert) {
                } message: {
                    Text("""
                        1. 活动时间：每天00:00开始，23:59结束；
                        2. 每日只能签到一次，签到即获得1 Bit 的奖励；
                        3. 连续签到3天，即第3天额外获得10 Bit 的奖励；
                        4. 连续签到7天，即第7天额外获得30 Bit 的奖励；
                        5. 每日前10名签到者可获得额外1~5 Bit 的随机奖励。
                        """)
                        .font(.callout)
                }

                VStack {
                    Text("累计获得")

                    Text("0Bit")
                }
            }

            HStack {
                Label("今日已签到0人", systemImage: "leaf.fill")
                    .foregroundColor(.theme)

                Label("昨日总签到0人", systemImage: "leaf.fill")
                    .foregroundColor(.secondaryTheme)
            }
            HStack(alignment: .center, spacing: 20) {
                Label("本月总签到0人", systemImage: "checkmark.circle")
                    .foregroundColor(.secondaryTheme)

                Label("已有0人参与", systemImage: "text.badge.checkmark")
                    .foregroundColor(.theme)
            }

            Spacer()
        }
        .navigationTitle("签到")
    }
}

struct DaySignContentView_Previews: PreviewProvider {
    static var previews: some View {
        DaySignContentView()
    }
}
