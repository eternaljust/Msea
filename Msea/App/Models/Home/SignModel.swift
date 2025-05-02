//
//  SignModel.swift
//  Msea
//
//  Created by tzqiang on 2023/4/21.
//  Copyright © 2023 eternal.just. All rights reserved.
//

import Foundation

enum SignTab: String, CaseIterable, Identifiable {
    case daysign
    case totaldays
    case totalreward

    var id: String { self.rawValue }
    var title: String {
        switch self {
        case .daysign: return "今日签到列表(Bit)"
        case .totaldays: return "总天数排名(天)"
        case .totalreward: return "总奖励排名(天)"
        }
    }
}

struct DaySignModel {
    var today = "今日已签到 0 人"
    var yesterday = "昨日总签到 0 人"
    var month = "本月总签到 0 人"
    var total = "已有 0 人参与"
    var days = "0"
    var bits = "0"
}

struct CalendarDayModel: Identifiable {
    var id = UUID()

    var title = ""
    var isWeek = false
    var isWeekend = false
    var isSign = false
    var isToday = false
}

struct SignListModel: Identifiable {
    var id = UUID()
    var uid = ""
    var no = ""
    var name = ""
    var content = ""
    var time = ""
    var bits = ""
}

struct SignDayListModel: Identifiable {
    var id = UUID()
    var uid = ""
    var no = ""
    var name = ""
    var time = ""
    var bits = ""
    var continuous = ""
    var month = ""
    var total = ""
}
