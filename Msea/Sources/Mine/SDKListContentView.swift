//
//  SDKListContentView.swift
//  Msea
//
//  Created by Awro on 2022/2/2.
//  Copyright © 2022 eternal.just. All rights reserved.
//

import SwiftUI

struct SDKListContentView: View {
    private var text = """
                       友盟+（umeng）SDK

                       使用目的：统计分析、性能监控

                       数据类型：设备Mac地址、唯一设备识别码（IMEI/android ID/IDFA/OPENUDID/IP地址/GUID、SIM 卡 IMSI 信息）以提供统计分析服务，并通过地理位置校准报表数据准确性，提供基础反作弊能力。

                       隐私政策/官网链接：https://www.umeng.com/policy

                       公司全称：友盟同欣（北京）科技有限公司
                       """
    var body: some View {
        VStack {
            ScrollView {
                Text(text)
                    .padding()
            }
        }
        .navigationTitle("第三方 SDK 目录")
    }
}

struct SDKListContentView_Previews: PreviewProvider {
    static var previews: some View {
        SDKListContentView()
    }
}
