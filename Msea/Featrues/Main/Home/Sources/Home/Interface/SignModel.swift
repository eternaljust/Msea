//
//  SignModel.swift
//  Msea
//
//  Created by tzqiang on 2023/4/21.
//  Copyright © 2023 eternal.just. All rights reserved.
//

import Foundation

public enum SignTab: String, CaseIterable, Identifiable {
    case daysign
    case totaldays
    case totalreward

    public var id: String { self.rawValue }
    public var title: String {
        switch self {
        case .daysign: return "今日签到列表(Bit)"
        case .totaldays: return "总天数排名(天)"
        case .totalreward: return "总奖励排名(天)"
        }
    }
}

public struct DaySignModel {
    public var today = "今日已签到 0 人"
    public var yesterday = "昨日总签到 0 人"
    public var month = "本月总签到 0 人"
    public var total = "已有 0 人参与"
    public var days = "0"
    public var bits = "0"

    public init() {}
}

public struct CalendarDayModel: Identifiable {
    public var id = UUID()

    public var title = ""
    public var isWeek = false
    public var isWeekend = false
    public var isSign = false
    public var isToday = false

    public init() {}
}

public struct SignListModel: Identifiable {
    public var id = UUID()
    public var uid = ""
    public var no = ""
    public var name = ""
    public var content = ""
    public var time = ""
    public var bits = ""

    public init() {}
}

public struct SignDayListModel: Identifiable {
    public var id = UUID()
    public var uid = ""
    public var no = ""
    public var name = ""
    public var time = ""
    public var bits = ""
    public var continuous = ""
    public var month = ""
    public var total = ""

    public init() {}
}
