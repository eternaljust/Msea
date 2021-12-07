//
//  SignDayListContentView.swift
//  Msea
//
//  Created by tzqiang on 2021/12/7.
//  Copyright © 2021 eternal.just. All rights reserved.
//

import SwiftUI

/// 签到天数排名列表
struct SignDayListContentView: View {
    var sign = SignTab.totaldays

    var body: some View {
        Text("\(sign.title)")
    }
}

struct SignDayListContentView_Previews: PreviewProvider {
    static var previews: some View {
        SignDayListContentView()
    }
}
